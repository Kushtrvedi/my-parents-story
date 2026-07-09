import { describe, it, expect } from "vitest";
import {
  ComputationalPhysics,
  ZERO_STATE,
  MAX_STATE,
  DEFAULT_STATE,
  validateState,
  computeModel,
  computeModelSafe,
  computeAllSafe,
  listModels,
  hasModel,
  benchmarkModel,
  benchmarkAll,
} from "../index";
import type { ModelName, ModelInput, HumanStateVector } from "../index";

// ─── Class Interface ────────────────────────────────────

describe("ComputationalPhysics class", () => {
  const makeState = (data: ModelInput | Record<string, unknown> = {}): HumanStateVector => ({
    version: 1,
    timestamp: Date.now(),
    data: data as Record<string, unknown>,
  });

  it("should be constructable", () => {
    const cp = new ComputationalPhysics();
    expect(cp).toBeDefined();
  });

  it("apply() returns a valid merged state", () => {
    const cp = new ComputationalPhysics();
    const result = cp.apply(makeState({ ...DEFAULT_STATE }));
    expect(result.data.agency).toBeGreaterThanOrEqual(0);
    expect(result.data.agency).toBeLessThanOrEqual(1);
    expect(result.data.momentum).toBeGreaterThanOrEqual(0);
    expect(result.data.trust).toBeGreaterThanOrEqual(0);
  });

  it("apply() with zero state returns valid output", () => {
    const cp = new ComputationalPhysics();
    const result = cp.apply(makeState({ ...ZERO_STATE }));
    for (const val of Object.values(result.data)) {
      expect(val).toBeGreaterThanOrEqual(0);
      expect(val).toBeLessThanOrEqual(1);
    }
  });

  it("apply() with max state returns valid output", () => {
    const cp = new ComputationalPhysics();
    const result = cp.apply(makeState({ ...MAX_STATE }));
    for (const val of Object.values(result.data)) {
      expect(val).toBeGreaterThanOrEqual(0);
      expect(val).toBeLessThanOrEqual(1);
    }
  });

  it("listModels() returns 13 models", () => {
    const cp = new ComputationalPhysics();
    expect(cp.listModels()).toHaveLength(13);
  });

  it("hasModel() returns true for known models", () => {
    const cp = new ComputationalPhysics();
    expect(cp.hasModel("agency")).toBe(true);
    expect(cp.hasModel("trust")).toBe(true);
    expect(cp.hasModel("dream-momentum")).toBe(true);
  });

  it("hasModel() returns false for unknown model", () => {
    const cp = new ComputationalPhysics();
    expect(cp.hasModel("nonexistent" as ModelName)).toBe(false);
  });

  it("getModelCount() returns 13", () => {
    const cp = new ComputationalPhysics();
    expect(cp.getModelCount()).toBe(13);
  });

  it("computeModel() returns a result for each model", () => {
    const cp = new ComputationalPhysics();
    for (const name of cp.listModels()) {
      const result = cp.computeModel(name, DEFAULT_STATE);
      expect(result.value).toBeGreaterThanOrEqual(0);
      expect(result.value).toBeLessThanOrEqual(1);
      expect(result.confidence).toBeGreaterThan(0);
    }
  });

  it("computeAll() returns results for all 13 models", () => {
    const cp = new ComputationalPhysics();
    const results = cp.computeAll(DEFAULT_STATE);
    expect(Object.keys(results)).toHaveLength(13);
  });
});

// ─── Individual Models ──────────────────────────────────

describe("agency model", () => {
  it("increases with attention and trust", () => {
    const low = computeModel("agency", { ...DEFAULT_STATE, attention: 0.2, trust: 0.2 });
    const high = computeModel("agency", { ...DEFAULT_STATE, attention: 0.9, trust: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("agency", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });

  it("has positive confidence", () => {
    const result = computeModel("agency", DEFAULT_STATE);
    expect(result.confidence).toBeGreaterThan(0);
  });
});

describe("burden model", () => {
  it("increases with entropy", () => {
    const low = computeModel("burden", { ...DEFAULT_STATE, entropy: 0.1 });
    const high = computeModel("burden", { ...DEFAULT_STATE, entropy: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("decreases with recovery", () => {
    const low = computeModel("burden", { ...DEFAULT_STATE, recovery: 0.2 });
    const high = computeModel("burden", { ...DEFAULT_STATE, recovery: 0.9 });
    expect(low.value).toBeGreaterThan(high.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("burden", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("attention model", () => {
  it("recharges over time", () => {
    const low = computeModel("attention", { ...DEFAULT_STATE, attention: 0.3, burden: 0.5 });
    const high = computeModel("attention", { ...DEFAULT_STATE, attention: 0.8, burden: 0.2 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("attention", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("momentum model", () => {
  it("increases with agency", () => {
    const low = computeModel("momentum", { ...DEFAULT_STATE, agency: 0.1 });
    const high = computeModel("momentum", { ...DEFAULT_STATE, agency: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("momentum", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("resistance model", () => {
  it("increases with identity stability", () => {
    const low = computeModel("resistance", { ...DEFAULT_STATE, identityStability: 0.2 });
    const high = computeModel("resistance", { ...DEFAULT_STATE, identityStability: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("resistance", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("recovery model", () => {
  it("increases with lower burden", () => {
    const low = computeModel("recovery", { ...DEFAULT_STATE, burden: 0.8 });
    const high = computeModel("recovery", { ...DEFAULT_STATE, burden: 0.1 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("recovery", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("trust model", () => {
  it("increases with consistency and evidence", () => {
    const low = computeModel("trust", { ...DEFAULT_STATE, identityStability: 0.2, reflectionStrength: 0.1 });
    const high = computeModel("trust", { ...DEFAULT_STATE, identityStability: 0.9, reflectionStrength: 0.8 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("trust", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("opportunity model", () => {
  it("increases with agency and learning", () => {
    const low = computeModel("opportunity", { ...DEFAULT_STATE, agency: 0.1, learning: 0.1 });
    const high = computeModel("opportunity", { ...DEFAULT_STATE, agency: 0.9, learning: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("opportunity", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("learning model", () => {
  it("increases with attention", () => {
    const low = computeModel("learning", { ...DEFAULT_STATE, attention: 0.1 });
    const high = computeModel("learning", { ...DEFAULT_STATE, attention: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("has diminishing returns at high learning", () => {
    const low = computeModel("learning", { ...DEFAULT_STATE, learning: 0.2, attention: 0.8 });
    const high = computeModel("learning", { ...DEFAULT_STATE, learning: 0.8, attention: 0.8 });
    const delta = high.value - low.value;
    expect(delta).toBeLessThan(0.6);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("learning", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("entropy model", () => {
  it("increases without recovery", () => {
    const low = computeModel("entropy", { ...DEFAULT_STATE, entropy: 0.1, recovery: 0.9 });
    const high = computeModel("entropy", { ...DEFAULT_STATE, entropy: 0.1, recovery: 0.1 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("entropy", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("identity-stability model", () => {
  it("increases with consistency", () => {
    const low = computeModel("identity-stability", { ...DEFAULT_STATE, identityStability: 0.2, entropy: 0.8 });
    const high = computeModel("identity-stability", { ...DEFAULT_STATE, identityStability: 0.8, entropy: 0.1 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("identity-stability", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("reflection-strength model", () => {
  it("increases with attention and learning", () => {
    const low = computeModel("reflection-strength", { ...DEFAULT_STATE, attention: 0.1, learning: 0.1 });
    const high = computeModel("reflection-strength", { ...DEFAULT_STATE, attention: 0.9, learning: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("reflection-strength", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

describe("dream-momentum model", () => {
  it("increases with agency and reflection", () => {
    const low = computeModel("dream-momentum", { ...DEFAULT_STATE, agency: 0.1, reflectionStrength: 0.1 });
    const high = computeModel("dream-momentum", { ...DEFAULT_STATE, agency: 0.9, reflectionStrength: 0.9 });
    expect(high.value).toBeGreaterThan(low.value);
  });

  it("is bounded [0,1]", () => {
    const result = computeModel("dream-momentum", MAX_STATE);
    expect(result.value).toBeGreaterThanOrEqual(0);
    expect(result.value).toBeLessThanOrEqual(1);
  });
});

// ─── Edge Cases ─────────────────────────────────────────

describe("edge cases", () => {
  it("zero state produces valid results for all models", () => {
    const results = computeAllSafe(ZERO_STATE);
    expect(results.ok).toBe(true);
    if (results.ok) {
      for (const r of Object.values(results.results)) {
        expect(r.value).toBeGreaterThanOrEqual(0);
        expect(r.value).toBeLessThanOrEqual(1);
      }
    }
  });

  it("max state produces valid results for all models", () => {
    const results = computeAllSafe(MAX_STATE);
    expect(results.ok).toBe(true);
    if (results.ok) {
      for (const r of Object.values(results.results)) {
        expect(r.value).toBeGreaterThanOrEqual(0);
        expect(r.value).toBeLessThanOrEqual(1);
      }
    }
  });

  it("NaN values are rejected", () => {
    const result = computeModelSafe("agency", { ...DEFAULT_STATE, attention: NaN });
    expect(result.ok).toBe(false);
  });

  it("out-of-range values are rejected", () => {
    const result = computeModelSafe("agency", { ...DEFAULT_STATE, attention: 1.5 });
    expect(result.ok).toBe(false);
  });

  it("unknown model name is rejected", () => {
    const result = computeModelSafe("nonexistent" as ModelName, DEFAULT_STATE);
    expect(result.ok).toBe(false);
  });
});

// ─── Validation ─────────────────────────────────────────

describe("validateState", () => {
  it("valid state passes", () => {
    expect(validateState(DEFAULT_STATE).valid).toBe(true);
  });

  it("NaN fails", () => {
    expect(validateState({ ...DEFAULT_STATE, agency: NaN }).valid).toBe(false);
  });

  it("negative fails", () => {
    expect(validateState({ ...DEFAULT_STATE, agency: -0.1 }).valid).toBe(false);
  });

  it("over 1 fails", () => {
    expect(validateState({ ...DEFAULT_STATE, agency: 1.1 }).valid).toBe(false);
  });
});

// ─── Registry ───────────────────────────────────────────

describe("registry", () => {
  it("has all 13 models", () => {
    expect(listModels()).toHaveLength(13);
  });

  it("hasModel works for all", () => {
    for (const name of listModels()) {
      expect(hasModel(name)).toBe(true);
    }
  });
});

// ─── Performance ────────────────────────────────────────

describe("benchmark", () => {
  it("benchmarkModel returns valid result", () => {
    const result = benchmarkModel("agency", 1000);
    if ("error" in result) throw new Error(result.error);
    expect(result.iterations).toBe(1000);
    expect(result.avgMs).toBeGreaterThanOrEqual(0);
    expect(result.p99Ms).toBeGreaterThanOrEqual(result.avgMs);
  });

  it("all models complete benchmark in <100ms avg", () => {
    const results = benchmarkAll(1000);
    for (const [name, r] of Object.entries(results)) {
      if ("error" in r) throw new Error(`${name}: ${r.error}`);
      expect(r.avgMs).toBeLessThan(100);
    }
  });
});
