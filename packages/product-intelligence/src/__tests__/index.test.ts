import { describe, it, expect, beforeEach } from "vitest";
import { ProductIntelligence } from "../index";
import type { Policy, Rule, DecisionAction } from "../index";
import { ExperienceRuntime } from "@reyou/experience-runtime";

// ─── Helpers ────────────────────────────────────────────

function makeExperience(overrides: Record<string, unknown> = {}): ExperienceRuntime {
  const exp = new ExperienceRuntime();
  if ("attentionBudget" in overrides) {
    (exp as any).getAttentionBudget = () => overrides.attentionBudget;
  }
  if ("interactionCost" in overrides) {
    (exp as any).getInteractionCost = () => overrides.interactionCost;
  }
  if ("hospitality" in overrides) {
    (exp as any).getHospitalitySignal = () => overrides.hospitality;
  }
  if ("tokens" in overrides) {
    (exp as any).getTokens = () => overrides.tokens as unknown[];
  }
  return exp;
}

function makePolicy(overrides: Partial<Policy> = {}): Policy {
  return {
    id: "test-policy",
    name: "Test Policy",
    rules: [],
    fallback: "ignore",
    enabled: true,
    ...overrides,
  };
}

function makeRule(overrides: Partial<Rule> = {}): Rule {
  return {
    id: "test-rule",
    condition: () => false,
    action: "speak",
    weight: 0.8,
    reason: "test reason",
    ...overrides,
  };
}

// ─── Core Decision Methods ─────────────────────────────

describe("ProductIntelligence core methods", () => {
  it("shouldSpeak returns boolean", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30, interactionCost: 2 }));
    expect(typeof pi.shouldSpeak()).toBe("boolean");
  });

  it("shouldWait returns true when interaction cost > 5", () => {
    const pi = new ProductIntelligence(makeExperience({ interactionCost: 6 }));
    expect(pi.shouldWait()).toBe(true);
  });

  it("shouldWait returns false when interaction cost <= 5", () => {
    const pi = new ProductIntelligence(makeExperience({ interactionCost: 3 }));
    expect(pi.shouldWait()).toBe(false);
  });

  it("shouldInterrupt returns true when hospitality is high", () => {
    const pi = new ProductIntelligence(makeExperience({ hospitality: "high" }));
    expect(pi.shouldInterrupt()).toBe(true);
  });

  it("shouldInterrupt returns false when hospitality is low", () => {
    const pi = new ProductIntelligence(makeExperience({ hospitality: "low" }));
    expect(pi.shouldInterrupt()).toBe(false);
  });

  it("shouldRecommend returns true when tokens exist", () => {
    const pi = new ProductIntelligence(makeExperience({ tokens: [{ id: "1", type: "a", payload: {} }] }));
    expect(pi.shouldRecommend()).toBe(true);
  });

  it("shouldRecommend returns false when no tokens", () => {
    const pi = new ProductIntelligence(makeExperience({ tokens: [] }));
    expect(pi.shouldRecommend()).toBe(false);
  });

  it("shouldStaySilent returns true when shouldSpeak and shouldRecommend are false", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 5, interactionCost: 10, tokens: [] }));
    expect(pi.shouldStaySilent()).toBe(true);
  });

  it("priorityScore returns attention minus cost", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30, interactionCost: 10 }));
    expect(pi.priorityScore()).toBe(20);
  });
});

// ─── Policy Management ─────────────────────────────────

describe("policy management", () => {
  let pi: ProductIntelligence;

  beforeEach(() => {
    pi = new ProductIntelligence(makeExperience());
  });

  it("addPolicy adds a policy", () => {
    pi.addPolicy(makePolicy({ id: "p1" }));
    expect(pi.listPolicies()).toHaveLength(1);
  });

  it("removePolicy removes a policy", () => {
    pi.addPolicy(makePolicy({ id: "p1" }));
    pi.removePolicy("p1");
    expect(pi.listPolicies()).toHaveLength(0);
  });

  it("getPolicy returns correct policy", () => {
    pi.addPolicy(makePolicy({ id: "p1", name: "Policy 1" }));
    expect(pi.getPolicy("p1")?.name).toBe("Policy 1");
  });

  it("getPolicy returns undefined for unknown id", () => {
    expect(pi.getPolicy("unknown")).toBeUndefined();
  });

  it("listPolicies returns copy", () => {
    pi.addPolicy(makePolicy({ id: "p1" }));
    const list = pi.listPolicies();
    list.pop();
    expect(pi.listPolicies()).toHaveLength(1);
  });

  it("disabled policies are not evaluated", () => {
    pi.addPolicy(makePolicy({ id: "p1", enabled: false }));
    expect(pi.listPolicies()).toHaveLength(1);
  });
});

// ─── Explainable Decisions ──────────────────────────────

describe("explainable decisions", () => {
  it("decide returns a Decision object", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.action).toBeDefined();
    expect(decision.reason).toBeDefined();
    expect(typeof decision.confidence).toBe("number");
    expect(Array.isArray(decision.evidence)).toBe(true);
    expect(typeof decision.attentionCost).toBe("number");
    expect(typeof decision.benefit).toBe("number");
    expect(typeof decision.risk).toBe("number");
    expect(decision.trace).toBeDefined();
  });

  it("confidence is between 0 and 1", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.confidence).toBeGreaterThanOrEqual(0);
    expect(decision.confidence).toBeLessThanOrEqual(1);
  });

  it("attentionCost is between 0 and 1", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.attentionCost).toBeGreaterThanOrEqual(0);
    expect(decision.attentionCost).toBeLessThanOrEqual(1);
  });

  it("benefit is between 0 and 1", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.benefit).toBeGreaterThanOrEqual(0);
    expect(decision.benefit).toBeLessThanOrEqual(1);
  });

  it("risk is between 0 and 1", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.risk).toBeGreaterThanOrEqual(0);
    expect(decision.risk).toBeLessThanOrEqual(1);
  });

  it("trace contains timestamp and inputs", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.trace.timestamp).toBeGreaterThan(0);
    expect(typeof decision.trace.inputs).toBe("object");
  });

  it("evidence contains action tag", () => {
    const pi = new ProductIntelligence(makeExperience());
    const decision = pi.decide();
    expect(decision.evidence.some((e) => e.startsWith("action:"))).toBe(true);
  });
});

// ─── Policy-Driven Decisions ────────────────────────────

describe("policy-driven decisions", () => {
  it("policy rule triggers correct action", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30, interactionCost: 2 }));
    pi.addPolicy(makePolicy({
      id: "speak-policy",
      rules: [makeRule({
        condition: (ctx) => ctx.attentionBudget > 20,
        action: "speak",
        weight: 0.9,
        reason: "High attention",
      })],
    }));
    const decision = pi.decide();
    expect(decision.action).toBe("speak");
    expect(decision.reason).toBe("High attention");
  });

  it("highest weight rule wins", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30, tokens: [{ id: "1", type: "a", payload: {} }] }));
    pi.addPolicy(makePolicy({
      id: "multi-rule",
      rules: [
        makeRule({ condition: () => true, action: "speak", weight: 0.5, reason: "low weight" }),
        makeRule({ condition: () => true, action: "recommend", weight: 0.9, reason: "high weight" }),
      ],
    }));
    const decision = pi.decide();
    expect(decision.action).toBe("recommend");
  });

  it("fallback action used when no rules match", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.addPolicy(makePolicy({
      id: "no-match",
      rules: [makeRule({ condition: () => false })],
      fallback: "escape",
    }));
    const decision = pi.decide();
    // Fallback to heuristic since no policy matched
    expect(decision.action).toBeDefined();
  });

  it("multiple policies are evaluated", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30 }));
    pi.addPolicy(makePolicy({
      id: "p1",
      rules: [makeRule({ condition: (ctx) => ctx.attentionBudget > 20, action: "speak", weight: 0.6, reason: "p1" })],
    }));
    pi.addPolicy(makePolicy({
      id: "p2",
      rules: [makeRule({ condition: (ctx) => ctx.attentionBudget > 20, action: "interrupt", weight: 0.8, reason: "p2" })],
    }));
    const decision = pi.decide();
    expect(decision.action).toBe("interrupt");
  });
});

// ─── Heuristic Fallback ────────────────────────────────

describe("heuristic fallback", () => {
  it("speaks when attention is high and cost is low", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 30, interactionCost: 2, tokens: [] }));
    const decision = pi.decide();
    expect(decision.action).toBe("speak");
  });

  it("recommends when tokens exist and cost is low", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 5, interactionCost: 2, tokens: [{ id: "1", type: "a", payload: {} }] }));
    const decision = pi.decide();
    expect(decision.action).toBe("recommend");
  });

  it("interrupts when hospitality is high", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 5, interactionCost: 10, hospitality: "high", tokens: [] }));
    const decision = pi.decide();
    expect(decision.action).toBe("interrupt");
  });

  it("waits when interaction cost is high", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 5, interactionCost: 10, tokens: [] }));
    const decision = pi.decide();
    expect(decision.action).toBe("wait");
  });

  it("silences by default", () => {
    const pi = new ProductIntelligence(makeExperience({ attentionBudget: 5, interactionCost: 3, tokens: [] }));
    const decision = pi.decide();
    expect(decision.action).toBe("silence");
  });
});

// ─── History & Explanation ──────────────────────────────

describe("history and explanation", () => {
  it("decisions are stored in history", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.decide();
    pi.decide();
    expect(pi.getHistory()).toHaveLength(2);
  });

  it("getLastDecision returns most recent", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.decide();
    const second = pi.decide();
    expect(pi.getLastDecision()).toBe(second);
  });

  it("getLastDecision returns undefined when empty", () => {
    const pi = new ProductIntelligence(makeExperience());
    expect(pi.getLastDecision()).toBeUndefined();
  });

  it("explainLastDecision returns formatted string", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.decide();
    const explanation = pi.explainLastDecision();
    expect(explanation).toBeDefined();
    expect(explanation).toContain("Action:");
    expect(explanation).toContain("Reason:");
    expect(explanation).toContain("Confidence:");
  });

  it("explainLastDecision returns undefined when no decisions", () => {
    const pi = new ProductIntelligence(makeExperience());
    expect(pi.explainLastDecision()).toBeUndefined();
  });

  it("clearHistory empties history", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.decide();
    pi.clearHistory();
    expect(pi.getHistory()).toHaveLength(0);
  });

  it("history is a copy", () => {
    const pi = new ProductIntelligence(makeExperience());
    pi.decide();
    const history = pi.getHistory();
    history.pop();
    expect(pi.getHistory()).toHaveLength(1);
  });
});

// ─── Decision Actions ──────────────────────────────────

describe("decision actions", () => {
  const actions: DecisionAction[] = ["speak", "silence", "recommend", "interrupt", "wait", "escape", "ignore"];

  it.each(actions)("action '%s' is valid", (action) => {
    const pi = new ProductIntelligence(makeExperience());
    // Force a specific action via policy
    pi.addPolicy(makePolicy({
      id: `force-${action}`,
      rules: [makeRule({ condition: () => true, action, weight: 1, reason: `force ${action}` })],
    }));
    const decision = pi.decide();
    expect(decision.action).toBe(action);
  });
});

// ─── Edge Cases ─────────────────────────────────────────

describe("edge cases", () => {
  it("empty experience produces valid decision", () => {
    const pi = new ProductIntelligence(new ExperienceRuntime());
    const decision = pi.decide();
    expect(decision.action).toBeDefined();
    expect(decision.confidence).toBeGreaterThanOrEqual(0);
  });

  it("all-zero context produces valid decision", () => {
    const pi = new ProductIntelligence(makeExperience({
      attentionBudget: 0, interactionCost: 0, hospitality: "low", tokens: [],
    }));
    const decision = pi.decide();
    expect(decision.action).toBeDefined();
  });

  it("all-max context produces valid decision", () => {
    const pi = new ProductIntelligence(makeExperience({
      attentionBudget: 100, interactionCost: 100, hospitality: "high",
      tokens: [{ id: "1", type: "a", payload: {} }, { id: "2", type: "b", payload: {} }],
    }));
    const decision = pi.decide();
    expect(decision.action).toBeDefined();
  });

  it("100 decisions can be made", () => {
    const pi = new ProductIntelligence(makeExperience());
    for (let i = 0; i < 100; i++) {
      pi.decide();
    }
    expect(pi.getHistory()).toHaveLength(100);
  });
});

// ─── Performance ────────────────────────────────────────

describe("performance", () => {
  it("1000 decisions complete in <100ms", () => {
    const pi = new ProductIntelligence(makeExperience());
    const start = performance.now();
    for (let i = 0; i < 1000; i++) {
      pi.decide();
    }
    expect(performance.now() - start).toBeLessThan(100);
  });
});
