import type { ModelInput, ModelResult, BenchmarkResult, ValidationResult } from "./models/types.js";
import { clamp, mean, percentile } from "./models/utils.js";
import {
  registerModel,
  computeModel,
  computeAll,
  listModels,
  hasModel,
  getModelCount,
  clearRegistry,
  type ModelName,
} from "./registry/index.js";
import * as agency from "./models/agency.js";
import * as burden from "./models/burden.js";
import * as attention from "./models/attention.js";
import * as momentum from "./models/momentum.js";
import * as resistance from "./models/resistance.js";
import * as recovery from "./models/recovery.js";
import * as trust from "./models/trust.js";
import * as opportunity from "./models/opportunity.js";
import * as learning from "./models/learning.js";
import * as entropy from "./models/entropy.js";
import * as identityStability from "./models/identity-stability.js";
import * as reflectionStrength from "./models/reflection-strength.js";
import * as dreamMomentum from "./models/dream-momentum.js";

const MODEL_MODULES: Record<ModelName, { calculate: (input: ModelInput) => ModelResult }> = {
  agency,
  burden,
  attention,
  momentum,
  resistance,
  recovery,
  trust,
  opportunity,
  learning,
  entropy,
  "identity-stability": identityStability,
  "reflection-strength": reflectionStrength,
  "dream-momentum": dreamMomentum,
};

function registerAll(): void {
  for (const [name, mod] of Object.entries(MODEL_MODULES)) {
    registerModel(name as ModelName, mod.calculate);
  }
}

registerAll();

// ─── State Constants ────────────────────────────────────

export const ZERO_STATE: ModelInput = {
  agency: 0, burden: 0, attention: 0, momentum: 0,
  resistance: 0, recovery: 0, trust: 0, opportunity: 0,
  learning: 0, entropy: 0, identityStability: 0, reflectionStrength: 0, dreamMomentum: 0,
};

export const MAX_STATE: ModelInput = {
  agency: 1, burden: 1, attention: 1, momentum: 1,
  resistance: 1, recovery: 1, trust: 1, opportunity: 1,
  learning: 1, entropy: 1, identityStability: 1, reflectionStrength: 1, dreamMomentum: 1,
};

export const DEFAULT_STATE: ModelInput = {
  agency: 0.5, burden: 0.3, attention: 0.7, momentum: 0.4,
  resistance: 0.2, recovery: 0.6, trust: 0.5, opportunity: 0.3,
  learning: 0.4, entropy: 0.1, identityStability: 0.7, reflectionStrength: 0.3, dreamMomentum: 0.4,
};

// ─── Validation ─────────────────────────────────────────

export function validateState(input: ModelInput): ValidationResult {
  const errors: string[] = [];
  for (const [key, val] of Object.entries(input)) {
    if (typeof val !== "number" || isNaN(val)) {
      errors.push(`${key} must be a number`);
    } else if (val < 0 || val > 1) {
      errors.push(`${key} must be between 0 and 1, got ${val}`);
    }
  }
  return { valid: errors.length === 0, errors };
}

// ─── Safe Compute ───────────────────────────────────────

export function computeModelSafe(
  name: ModelName, input: ModelInput,
): { ok: true; result: ModelResult } | { ok: false; error: string } {
  if (!hasModel(name)) return { ok: false, error: `Unknown model: ${name}` };
  const validation = validateState(input);
  if (!validation.valid) return { ok: false, error: validation.errors.join("; ") };
  return { ok: true, result: computeModel(name, input) };
}

export function computeAllSafe(
  input: ModelInput,
): { ok: true; results: Record<ModelName, ModelResult> } | { ok: false; error: string } {
  const validation = validateState(input);
  if (!validation.valid) return { ok: false, error: validation.errors.join("; ") };
  return { ok: true, results: computeAll(input) };
}

// ─── Benchmark ──────────────────────────────────────────

export function benchmarkModel(
  name: ModelName, iterations = 10000,
): BenchmarkResult | { error: string } {
  if (!hasModel(name)) return { error: `Unknown model: ${name}` };
  const times: number[] = [];
  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    computeModel(name, DEFAULT_STATE);
    times.push(performance.now() - start);
  }
  times.sort((a, b) => a - b);
  return {
    iterations,
    avgMs: mean(times),
    minMs: times[0]!,
    maxMs: times[times.length - 1]!,
    p99Ms: percentile(times, 99),
  };
}

export function benchmarkAll(
  iterations = 10000,
): Record<ModelName, BenchmarkResult | { error: string }> {
  const results: Record<string, BenchmarkResult | { error: string }> = {};
  for (const name of listModels()) {
    results[name] = benchmarkModel(name, iterations);
  }
  return results as Record<ModelName, BenchmarkResult | { error: string }>;
}

// ─── ComputationalPhysics Class ─────────────────────────
// state-transition-engine uses `new ComputationalPhysics()` and `.apply(state)`.

function toModelInput(state: Record<string, unknown>): ModelInput {
  return {
    agency: typeof state.agency === "number" ? state.agency : 0,
    burden: typeof state.burden === "number" ? state.burden : 0,
    attention: typeof state.attention === "number" ? state.attention : 0,
    momentum: typeof state.momentum === "number" ? state.momentum : 0,
    resistance: typeof state.resistance === "number" ? state.resistance : 0,
    recovery: typeof state.recovery === "number" ? state.recovery : 0,
    trust: typeof state.trust === "number" ? state.trust : 0,
    opportunity: typeof state.opportunity === "number" ? state.opportunity : 0,
    learning: typeof state.learning === "number" ? state.learning : 0,
    entropy: typeof state.entropy === "number" ? state.entropy : 0,
    identityStability: typeof state.identityStability === "number" ? state.identityStability : 0,
    reflectionStrength: typeof state.reflectionStrength === "number" ? state.reflectionStrength : 0,
    dreamMomentum: typeof state.dreamMomentum === "number" ? state.dreamMomentum : 0,
  };
}

export interface HumanStateVector {
  version: number;
  timestamp: number;
  data: Record<string, unknown>;
}

export class ComputationalPhysics {
  /** Run all models on the given state and return a new state with computed fields. */
  apply(state: HumanStateVector): HumanStateVector {
    const input = toModelInput(state.data ?? {});
    const results = computeAll(input);
    return {
      ...state,
      data: {
        ...state.data,
        agency: clamp(results.agency.value),
        burden: clamp(results.burden.value),
        attention: clamp(results.attention.value),
        momentum: clamp(results.momentum.value),
        resistance: clamp(results.resistance.value),
        recovery: clamp(results.recovery.value),
        trust: clamp(results.trust.value),
        opportunity: clamp(results.opportunity.value),
        learning: clamp(results.learning.value),
        entropy: clamp(results.entropy.value),
        identityStability: clamp(results["identity-stability"].value),
        reflectionStrength: clamp(results["reflection-strength"].value),
        dreamMomentum: clamp(results["dream-momentum"].value),
      },
    };
  }

  computeModel(name: ModelName, input: ModelInput): ModelResult {
    return computeModel(name, input);
  }

  computeAll(input: ModelInput): Record<ModelName, ModelResult> {
    return computeAll(input);
  }

  listModels(): ModelName[] {
    return listModels();
  }

  hasModel(name: ModelName): boolean {
    return hasModel(name);
  }

  getModelCount(): number {
    return getModelCount();
  }
}

// ─── Re-exports ─────────────────────────────────────────

export {
  computeModel,
  computeAll,
  listModels,
  hasModel,
  getModelCount,
  clearRegistry,
  type ModelName,
  type ModelInput,
  type ModelResult,
  type BenchmarkResult,
  type ValidationResult,
};
