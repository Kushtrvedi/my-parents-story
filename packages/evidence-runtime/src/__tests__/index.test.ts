import { describe, it, expect, beforeEach } from "vitest";
import {
  EvidenceRuntime,
  hashPayload,
  hashBundle,
  signPayload,
  verifySignature,
  type EvidenceBundle,
  type ScientificMetadata,
  type ExperimentMetadata,
  type CertificationMetadata,
} from "../index";

// ─── Hashing ────────────────────────────────────────────

describe("hashPayload", () => {
  it("returns a 64-char hex string", () => {
    const hash = hashPayload({ a: 1 });
    expect(hash).toMatch(/^[a-f0-9]{64}$/);
  });

  it("is deterministic", () => {
    const h1 = hashPayload({ x: 1, y: 2 });
    const h2 = hashPayload({ x: 1, y: 2 });
    expect(h1).toBe(h2);
  });

  it("different inputs produce different hashes", () => {
    const h1 = hashPayload({ a: 1 });
    const h2 = hashPayload({ a: 2 });
    expect(h1).not.toBe(h2);
  });

  it("order-independent for objects", () => {
    const h1 = hashPayload({ a: 1, b: 2 });
    const h2 = hashPayload({ b: 2, a: 1 });
    expect(h1).toBe(h2);
  });
});

describe("hashBundle", () => {
  it("produces a consistent hash", () => {
    const bundle = makeBundle();
    const { hash: _, ...rest } = bundle;
    const h1 = hashBundle(rest);
    const h2 = hashBundle(rest);
    expect(h1).toBe(h2);
  });
});

// ─── Signatures ─────────────────────────────────────────

describe("signPayload", () => {
  it("returns a 64-char hex string", () => {
    const sig = signPayload("test-data");
    expect(sig).toMatch(/^[a-f0-9]{64}$/);
  });

  it("is deterministic", () => {
    const s1 = signPayload("hello");
    const s2 = signPayload("hello");
    expect(s1).toBe(s2);
  });

  it("different data produces different signatures", () => {
    const s1 = signPayload("a");
    const s2 = signPayload("b");
    expect(s1).not.toBe(s2);
  });
});

describe("verifySignature", () => {
  it("returns true for valid signature", () => {
    const data = "some-data";
    const sig = signPayload(data);
    expect(verifySignature(data, sig)).toBe(true);
  });

  it("returns false for invalid signature", () => {
    expect(verifySignature("data", "bad-sig")).toBe(false);
  });

  it("returns false for wrong data", () => {
    const sig = signPayload("correct");
    expect(verifySignature("wrong", sig)).toBe(false);
  });
});

// ─── Helpers ────────────────────────────────────────────

function makeBundle(overrides: Partial<EvidenceBundle> = {}): EvidenceBundle {
  const timestamp = new Date("2026-01-01T00:00:00Z");
  return {
    id: "test-bundle",
    bundleId: "test-bundle",
    createdAt: timestamp,
    updatedAt: timestamp,
    timestamp,
    source: "test",
    action: "test-action",
    rationale: "test rationale",
    input: { a: 1 },
    output: { b: 2 },
    confidence: 0.9,
    category: "state-transition",
    constitutionalArticles: [],
    architecturalLaws: [],
    trustScore: 0.8,
    hash: "",
    previousHash: "0".repeat(64),
    chainDepth: 0,
    signature: "",
    metadata: {},
    ...overrides,
  };
}

// ─── EvidenceRuntime ────────────────────────────────────

describe("EvidenceRuntime record", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("creates a bundle with hash", () => {
    const bundle = er.record({
      source: "test",
      action: "demo",
      rationale: "unit test",
      input: { a: 1 },
      output: { b: 2 },
      confidence: 1,
    });
    expect(bundle.hash).toMatch(/^[a-f0-9]{64}$/);
    expect(bundle.bundleId).toContain("test-");
  });

  it("creates a bundle with signature", () => {
    const bundle = er.record({
      source: "test",
      action: "demo",
      rationale: "test",
      input: {},
      output: {},
      confidence: 1,
    });
    expect(bundle.signature).toMatch(/^[a-f0-9]{64}$/);
  });

  it("sets previousHash to genesis hash initially", () => {
    const bundle = er.record({
      source: "test",
      action: "demo",
      rationale: "test",
      input: {},
      output: {},
      confidence: 1,
    });
    expect(bundle.previousHash).toBe("0".repeat(64));
  });

  it("chains previousHash correctly", () => {
    const b1 = er.record({ source: "a", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    const b2 = er.record({ source: "b", action: "y", rationale: "", input: {}, output: {}, confidence: 1 });
    expect(b2.previousHash).toBe(b1.hash);
  });

  it("increments chainDepth", () => {
    const b1 = er.record({ source: "a", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    const b2 = er.record({ source: "b", action: "y", rationale: "", input: {}, output: {}, confidence: 1 });
    expect(b1.chainDepth).toBe(0);
    expect(b2.chainDepth).toBe(1);
  });

  it("sets default category to custom", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    expect(bundle.category).toBe("custom");
  });

  it("accepts category", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
      category: "prediction",
    });
    expect(bundle.category).toBe("prediction");
  });

  it("accepts scientific metadata", () => {
    const sci: ScientificMetadata = { modelId: "m1", confidence: 0.95 };
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
      scientific: sci,
    });
    expect(bundle.scientific?.modelId).toBe("m1");
  });

  it("accepts experiment metadata", () => {
    const exp: ExperimentMetadata = { experimentId: "e1", hypothesis: "h1" };
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
      experiment: exp,
    });
    expect(bundle.experiment?.experimentId).toBe("e1");
  });

  it("accepts certification metadata", () => {
    const cert: CertificationMetadata = { certificationId: "c1", level: "gold" };
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
      certification: cert,
    });
    expect(bundle.certification?.level).toBe("gold");
  });

  it("accepts custom metadata", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
      metadata: { custom: "value" },
    });
    expect(bundle.metadata.custom).toBe("value");
  });
});

describe("EvidenceRuntime retrieve", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("retrieves a stored bundle", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    const retrieved = er.retrieve(bundle.bundleId);
    expect(retrieved?.hash).toBe(bundle.hash);
  });

  it("returns undefined for unknown ID", () => {
    expect(er.retrieve("nonexistent")).toBeUndefined();
  });
});

describe("EvidenceRuntime queries", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
    er.record({ source: "engine", action: "a", rationale: "", input: {}, output: {}, confidence: 1, category: "state-transition" });
    er.record({ source: "engine", action: "b", rationale: "", input: {}, output: {}, confidence: 1, category: "prediction" });
    er.record({ source: "ui", action: "c", rationale: "", input: {}, output: {}, confidence: 1, category: "decision" });
  });

  it("getAll returns all bundles", () => {
    expect(er.getAll()).toHaveLength(3);
  });

  it("getBySource filters correctly", () => {
    expect(er.getBySource("engine")).toHaveLength(2);
    expect(er.getBySource("ui")).toHaveLength(1);
    expect(er.getBySource("unknown")).toHaveLength(0);
  });

  it("getByCategory filters correctly", () => {
    expect(er.getByCategory("state-transition")).toHaveLength(1);
    expect(er.getByCategory("prediction")).toHaveLength(1);
    expect(er.getByCategory("decision")).toHaveLength(1);
  });

  it("getCount returns count", () => {
    expect(er.getCount()).toBe(3);
  });
});

describe("EvidenceRuntime verify", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("verifyBundle returns valid for intact bundle", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    const result = er.verifyBundle(bundle);
    expect(result.valid).toBe(true);
  });

  it("verifyBundle detects tampered hash", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    const tampered = { ...bundle, hash: "tampered" };
    const result = er.verifyBundle(tampered);
    expect(result.valid).toBe(false);
    expect(result.reason).toContain("Hash mismatch");
  });

  it("verifyBundle detects tampered signature", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    const tampered = { ...bundle, signature: "tampered" };
    const result = er.verifyBundle(tampered);
    expect(result.valid).toBe(false);
    expect(result.reason).toContain("Signature");
  });
});

describe("EvidenceRuntime chain", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("verifyChain returns valid for empty chain", () => {
    const result = er.verifyChain();
    expect(result.valid).toBe(true);
    expect(result.totalBundles).toBe(0);
  });

  it("verifyChain returns valid for intact chain", () => {
    er.record({ source: "a", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    er.record({ source: "b", action: "y", rationale: "", input: {}, output: {}, confidence: 1 });
    er.record({ source: "c", action: "z", rationale: "", input: {}, output: {}, confidence: 1 });
    const result = er.verifyChain();
    expect(result.valid).toBe(true);
    expect(result.totalBundles).toBe(3);
    expect(result.brokenLinks).toBe(0);
  });

  it("getChainDepth returns depth", () => {
    er.record({ source: "a", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    er.record({ source: "b", action: "y", rationale: "", input: {}, output: {}, confidence: 1 });
    expect(er.getChainDepth()).toBe(2);
  });

  it("getLastHash returns last bundle hash", () => {
    const b = er.record({ source: "a", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    expect(er.getLastHash()).toBe(b.hash);
  });
});

describe("EvidenceRuntime replay", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("replay returns match for intact bundle", () => {
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: {},
      output: {},
      confidence: 1,
    });
    const result = er.replay(bundle.bundleId);
    expect(result).toBeDefined();
    expect(result!.match).toBe(true);
    expect(result!.originalHash).toBe(result!.replayHash);
  });

  it("replay returns undefined for unknown ID", () => {
    expect(er.replay("nonexistent")).toBeUndefined();
  });
});

describe("EvidenceRuntime audit trail", () => {
  let er: EvidenceRuntime;

  beforeEach(() => {
    er = new EvidenceRuntime();
  });

  it("records audit entries for record", () => {
    er.record({ source: "test", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    const trail = er.getAuditTrail();
    expect(trail.length).toBeGreaterThanOrEqual(1);
    expect(trail[0]!.action).toBe("record");
  });

  it("records audit entries for retrieve", () => {
    const b = er.record({ source: "test", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    er.retrieve(b.bundleId);
    const trail = er.getAuditTrail();
    expect(trail.some((e) => e.action === "retrieve")).toBe(true);
  });

  it("records audit entries for replay", () => {
    const b = er.record({ source: "test", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    er.replay(b.bundleId);
    const trail = er.getAuditTrail();
    expect(trail.some((e) => e.action === "replay")).toBe(true);
  });

  it("audit trail is a copy", () => {
    const trail = er.getAuditTrail();
    trail.pop();
    expect(er.getAuditTrail()).toHaveLength(0);
  });
});

describe("EvidenceRuntime clear", () => {
  it("clear resets all state", () => {
    const er = new EvidenceRuntime();
    er.record({ source: "test", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    er.clear();
    expect(er.getCount()).toBe(0);
    expect(er.getChainDepth()).toBe(0);
    expect(er.getLastHash()).toBe("0".repeat(64));
  });
});

// ─── Edge Cases ─────────────────────────────────────────

describe("edge cases", () => {
  it("100 bundles chain correctly", () => {
    const er = new EvidenceRuntime();
    for (let i = 0; i < 100; i++) {
      er.record({ source: `s${i}`, action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    }
    expect(er.getCount()).toBe(100);
    const chain = er.verifyChain();
    expect(chain.valid).toBe(true);
    expect(chain.totalBundles).toBe(100);
  });

  it("bundle with empty input/output", () => {
    const er = new EvidenceRuntime();
    const bundle = er.record({ source: "test", action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    expect(bundle.hash).toMatch(/^[a-f0-9]{64}$/);
  });

  it("bundle with complex nested input", () => {
    const er = new EvidenceRuntime();
    const bundle = er.record({
      source: "test",
      action: "x",
      rationale: "",
      input: { nested: { deep: [1, 2, 3] } },
      output: { result: true },
      confidence: 0.99,
    });
    expect(bundle.hash).toMatch(/^[a-f0-9]{64}$/);
  });
});

// ─── Performance ────────────────────────────────────────

describe("performance", () => {
  it("1000 record operations complete in <500ms", () => {
    const er = new EvidenceRuntime();
    const start = performance.now();
    for (let i = 0; i < 1000; i++) {
      er.record({ source: `s${i}`, action: "x", rationale: "", input: { i }, output: {}, confidence: 1 });
    }
    expect(performance.now() - start).toBeLessThan(500);
  });

  it("chain verification of 100 bundles completes in <100ms", () => {
    const er = new EvidenceRuntime();
    for (let i = 0; i < 100; i++) {
      er.record({ source: `s${i}`, action: "x", rationale: "", input: {}, output: {}, confidence: 1 });
    }
    const start = performance.now();
    er.verifyChain();
    expect(performance.now() - start).toBeLessThan(100);
  });
});
