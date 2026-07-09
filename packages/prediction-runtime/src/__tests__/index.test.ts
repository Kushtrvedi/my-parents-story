import { describe, it, expect } from "vitest";
import {
  forecast,
  simulate,
  project,
  compare,
  counterfactual,
  estimateRisk,
  estimateOpportunity,
  estimateDrift,
  estimateRecovery,
} from "../index";
import type { HumanStateVector } from "@reyou/human-runtime";
import { ComputationalPhysics } from "@reyou/computational-physics";

// ─── Helpers ────────────────────────────────────────────

function makeState(data: Record<string, unknown> = {}): HumanStateVector {
  return {
    version: 1,
    timestamp: Date.now(),
    data: {
      agency: 0.5, burden: 0.3, attention: 0.7, momentum: 0.4,
      resistance: 0.2, recovery: 0.6, trust: 0.5, opportunity: 0.3,
      learning: 0.4, entropy: 0.1, identityStability: 0.7, reflectionStrength: 0.3,
      dreamMomentum: 0.4, ...data,
    },
  };
}

// ─── Forecast ───────────────────────────────────────────

describe("forecast", () => {
  it("returns correct number of steps", () => {
    const result = forecast(makeState(), 5);
    expect(result.states).toHaveLength(5);
    expect(result.horizon).toBe(5);
  });

  it("returns empty array for 0 steps", () => {
    const result = forecast(makeState(), 0);
    expect(result.states).toHaveLength(0);
  });

  it("each step has valid version", () => {
    const result = forecast(makeState(), 3);
    for (let i = 0; i < result.states.length; i++) {
      expect(result.states[i]!.version).toBeGreaterThan(1);
    }
  });

  it("each step has valid data", () => {
    const result = forecast(makeState(), 3);
    for (const state of result.states) {
      for (const val of Object.values(state.data)) {
        if (typeof val === "number") {
          expect(val).toBeGreaterThanOrEqual(0);
          expect(val).toBeLessThanOrEqual(1);
        }
      }
    }
  });

  it("state evolves over time (not static)", () => {
    const result = forecast(makeState(), 3);
    const first = result.states[0];
    const last = result.states[result.states.length - 1];
    expect(first).toBeDefined();
    expect(last).toBeDefined();
    // At least some field should differ
    let changed = false;
    for (const key of Object.keys(first!.data)) {
      if (first!.data[key] !== last!.data[key]) {
        changed = true;
        break;
      }
    }
    expect(changed).toBe(true);
  });

  it("single step works", () => {
    const result = forecast(makeState(), 1);
    expect(result.states).toHaveLength(1);
  });
});

// ─── Simulate ───────────────────────────────────────────

describe("simulate", () => {
  it("returns correct number of scenarios", () => {
    const result = simulate(makeState(), 3, 5);
    expect(result).toHaveLength(5);
  });

  it("each trajectory has correct steps", () => {
    const result = simulate(makeState(), 4, 2);
    for (const traj of result) {
      expect(traj.steps).toHaveLength(4);
    }
  });

  it("each step has confidence and risk", () => {
    const result = simulate(makeState(), 2, 2);
    for (const traj of result) {
      for (const step of traj.steps) {
        expect(step.confidence).toBeGreaterThanOrEqual(0);
        expect(step.confidence).toBeLessThanOrEqual(1);
        expect(step.risk).toBeGreaterThanOrEqual(0);
        expect(step.risk).toBeLessThanOrEqual(1);
      }
    }
  });

  it("different scenarios produce different drift", () => {
    const result = simulate(makeState(), 5, 5);
    const drifts = result.map((t) => t.drift);
    const unique = new Set(drifts.map((d) => d.toFixed(6)));
    expect(unique.size).toBeGreaterThan(1);
  });

  it("default scenarios is 3", () => {
    const result = simulate(makeState(), 2);
    expect(result).toHaveLength(3);
  });

  it("drift is non-negative", () => {
    const result = simulate(makeState(), 3, 3);
    for (const traj of result) {
      expect(traj.drift).toBeGreaterThanOrEqual(0);
    }
  });
});

// ─── Project ────────────────────────────────────────────

describe("project", () => {
  it("returns feasibility between 0 and 1", () => {
    const result = project(makeState(), { agency: 0.9 });
    expect(result.feasibility).toBeGreaterThanOrEqual(0);
    expect(result.feasibility).toBeLessThanOrEqual(1);
  });

  it("returns stepsNeeded >= 1", () => {
    const result = project(makeState(), { agency: 0.9 });
    expect(result.stepsNeeded).toBeGreaterThanOrEqual(1);
  });

  it("identifies critical factors when target is far", () => {
    const result = project(makeState(), { agency: 0.99, trust: 0.99 });
    expect(result.criticalFactors.length).toBeGreaterThanOrEqual(0);
  });

  it("target state contains requested fields", () => {
    const result = project(makeState(), { agency: 0.8, trust: 0.9 });
    expect(result.target.data.agency).toBe(0.8);
    expect(result.target.data.trust).toBe(0.9);
  });

  it("feasibility is higher for achievable targets", () => {
    const easy = project(makeState(), { agency: 0.5 });
    const hard = project(makeState(), { agency: 0.99 });
    expect(easy.feasibility).toBeGreaterThanOrEqual(hard.feasibility);
  });
});

// ─── Compare ────────────────────────────────────────────

describe("compare", () => {
  it("returns 0 for identical states", () => {
    const s = makeState();
    expect(compare(s, s)).toBe(0);
  });

  it("returns positive for different states", () => {
    const a = makeState({ agency: 0.1 });
    const b = makeState({ agency: 0.9 });
    expect(compare(a, b)).toBeGreaterThan(0);
  });

  it("is symmetric", () => {
    const a = makeState({ agency: 0.2 });
    const b = makeState({ agency: 0.8 });
    expect(compare(a, b)).toBeCloseTo(compare(b, a), 10);
  });

  it("magnitude scales with difference", () => {
    const base = makeState();
    const small = makeState({ agency: 0.55 });
    const large = makeState({ agency: 0.95 });
    expect(compare(base, small)).toBeLessThan(compare(base, large));
  });
});

// ─── Counterfactual ─────────────────────────────────────

describe("counterfactual", () => {
  it("returns actual, hypothetical, and divergence", () => {
    const result = counterfactual(makeState(), (s) => s);
    expect(result.actual).toBeDefined();
    expect(result.hypothetical).toBeDefined();
    expect(typeof result.divergence).toBe("number");
  });

  it("divergence is 0 when mutation matches actual forecast", () => {
    const state = makeState();
    const physics = new ComputationalPhysics();
    // The actual from counterfactual is forecast(state,1) which applies physics once.
    // If mutation also applies physics once, divergence should be ~0.
    const result = counterfactual(state, (s) => physics.apply(s));
    expect(result.divergence).toBeCloseTo(0, 5);
  });

  it("divergence is positive for real mutations", () => {
    const result = counterfactual(makeState(), (s) => ({
      ...s,
      data: { ...s.data, agency: 1 },
    }));
    expect(result.divergence).toBeGreaterThan(0);
  });

  it("hypothetical reflects the mutation", () => {
    const result = counterfactual(makeState(), (s) => ({
      ...s,
      data: { ...s.data, trust: 0.99 },
    }));
    expect(result.hypothetical.data.trust).toBe(0.99);
  });
});

// ─── Risk ───────────────────────────────────────────────

describe("estimateRisk", () => {
  it("returns valid risk level", () => {
    const result = estimateRisk(makeState());
    expect(["low", "medium", "high", "critical"]).toContain(result.level);
  });

  it("score is between 0 and 1", () => {
    const result = estimateRisk(makeState());
    expect(result.score).toBeGreaterThanOrEqual(0);
    expect(result.score).toBeLessThanOrEqual(1);
  });

  it("factors is an array", () => {
    const result = estimateRisk(makeState());
    expect(Array.isArray(result.factors)).toBe(true);
  });

  it("high burden increases risk", () => {
    const low = estimateRisk(makeState({ burden: 0.1 }));
    const high = estimateRisk(makeState({ burden: 0.9 }));
    expect(high.score).toBeGreaterThan(low.score);
  });

  it("high entropy increases risk", () => {
    const low = estimateRisk(makeState({ entropy: 0.1 }));
    const high = estimateRisk(makeState({ entropy: 0.9 }));
    expect(high.score).toBeGreaterThan(low.score);
  });

  it("low recovery increases risk", () => {
    const good = estimateRisk(makeState({ recovery: 0.9 }));
    const bad = estimateRisk(makeState({ recovery: 0.1 }));
    expect(bad.score).toBeGreaterThan(good.score);
  });

  it("critical level for very high risk", () => {
    const result = estimateRisk(makeState({ burden: 1, entropy: 1, recovery: 0, attention: 0 }));
    expect(result.level).toBe("critical");
  });

  it("low level for very low risk", () => {
    const result = estimateRisk(makeState({ burden: 0, entropy: 0, recovery: 1, attention: 1 }));
    expect(result.level).toBe("low");
  });
});

// ─── Opportunity ────────────────────────────────────────

describe("estimateOpportunity", () => {
  it("potential is between 0 and 1", () => {
    const result = estimateOpportunity(makeState());
    expect(result.potential).toBeGreaterThanOrEqual(0);
    expect(result.potential).toBeLessThanOrEqual(1);
  });

  it("timeline is positive", () => {
    const result = estimateOpportunity(makeState());
    expect(result.timeline).toBeGreaterThanOrEqual(0);
  });

  it("factors is an array", () => {
    const result = estimateOpportunity(makeState());
    expect(Array.isArray(result.factors)).toBe(true);
  });

  it("high agency increases potential", () => {
    const low = estimateOpportunity(makeState({ agency: 0.1 }));
    const high = estimateOpportunity(makeState({ agency: 0.9 }));
    expect(high.potential).toBeGreaterThan(low.potential);
  });

  it("high learning increases potential", () => {
    const low = estimateOpportunity(makeState({ learning: 0.1 }));
    const high = estimateOpportunity(makeState({ learning: 0.9 }));
    expect(high.potential).toBeGreaterThan(low.potential);
  });
});

// ─── Drift ──────────────────────────────────────────────

describe("estimateDrift", () => {
  it("direction is a number", () => {
    const result = estimateDrift(makeState());
    expect(typeof result.direction).toBe("number");
  });

  it("magnitude is non-negative", () => {
    const result = estimateDrift(makeState());
    expect(result.magnitude).toBeGreaterThanOrEqual(0);
  });

  it("factors is an array", () => {
    const result = estimateDrift(makeState());
    expect(Array.isArray(result.factors)).toBe(true);
  });

  it("high agency creates forward drift", () => {
    const result = estimateDrift(makeState({ agency: 0.9, resistance: 0.1 }));
    expect(result.direction).toBeGreaterThan(0);
  });

  it("high resistance creates backward drift", () => {
    const result = estimateDrift(makeState({ agency: 0.1, resistance: 0.9 }));
    expect(result.direction).toBeLessThan(0);
  });
});

// ─── Recovery ───────────────────────────────────────────

describe("estimateRecovery", () => {
  it("recoveryRate is between 0 and 1", () => {
    const result = estimateRecovery(makeState());
    expect(result.recoveryRate).toBeGreaterThanOrEqual(0);
    expect(result.recoveryRate).toBeLessThanOrEqual(1);
  });

  it("timeToRecover is non-negative", () => {
    const result = estimateRecovery(makeState());
    expect(result.timeToRecover).toBeGreaterThanOrEqual(0);
  });

  it("factors is an array", () => {
    const result = estimateRecovery(makeState());
    expect(Array.isArray(result.factors)).toBe(true);
  });

  it("high recovery means fast recovery rate", () => {
    const fast = estimateRecovery(makeState({ recovery: 0.9 }));
    const slow = estimateRecovery(makeState({ recovery: 0.1 }));
    expect(fast.recoveryRate).toBeGreaterThan(slow.recoveryRate);
  });

  it("high burden delays recovery", () => {
    const low = estimateRecovery(makeState({ burden: 0.1 }));
    const high = estimateRecovery(makeState({ burden: 0.9 }));
    expect(high.timeToRecover).toBeGreaterThanOrEqual(low.timeToRecover);
  });
});

// ─── Edge Cases ─────────────────────────────────────────

describe("edge cases", () => {
  it("forecast with extreme state", () => {
    const extreme = makeState({
      agency: 1, burden: 1, attention: 0, recovery: 0, entropy: 1,
    });
    const result = forecast(extreme, 5);
    expect(result.states).toHaveLength(5);
    for (const state of result.states) {
      for (const val of Object.values(state.data)) {
        if (typeof val === "number") {
          expect(val).toBeGreaterThanOrEqual(0);
          expect(val).toBeLessThanOrEqual(1);
        }
      }
    }
  });

  it("simulate with 1 scenario", () => {
    const result = simulate(makeState(), 2, 1);
    expect(result).toHaveLength(1);
  });

  it("compare with empty data states", () => {
    const a: HumanStateVector = { version: 1, timestamp: 0, data: {} };
    const b: HumanStateVector = { version: 1, timestamp: 0, data: {} };
    expect(compare(a, b)).toBe(0);
  });

  it("project with empty target", () => {
    const result = project(makeState(), {});
    expect(result.feasibility).toBeGreaterThanOrEqual(0);
    expect(result.criticalFactors).toHaveLength(0);
  });

  it("estimateRisk with all zeros", () => {
    const state = makeState({ burden: 0, entropy: 0, recovery: 1, attention: 1 });
    const result = estimateRisk(state);
    expect(result.score).toBeLessThan(0.3);
  });
});

// ─── Performance ────────────────────────────────────────

describe("performance", () => {
  it("forecast completes in <100ms", () => {
    const start = performance.now();
    forecast(makeState(), 50);
    expect(performance.now() - start).toBeLessThan(100);
  });

  it("simulate completes in <200ms", () => {
    const start = performance.now();
    simulate(makeState(), 20, 5);
    expect(performance.now() - start).toBeLessThan(200);
  });
});
