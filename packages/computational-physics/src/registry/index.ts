import type { ModelInput, ModelResult, ModelFn } from "../models/types";

export type ModelName =
  | "agency"
  | "burden"
  | "attention"
  | "momentum"
  | "resistance"
  | "recovery"
  | "trust"
  | "opportunity"
  | "learning"
  | "entropy"
  | "identity-stability"
  | "reflection-strength"
  | "dream-momentum";

export interface ModelEntry {
  name: ModelName;
  fn: ModelFn;
}

const registry = new Map<ModelName, ModelEntry>();

export function registerModel(name: ModelName, fn: ModelFn): void {
  registry.set(name, { name, fn });
}

export function getModel(name: ModelName): ModelEntry | undefined {
  return registry.get(name);
}

export function computeModel(name: ModelName, input: ModelInput): ModelResult {
  const entry = registry.get(name);
  if (!entry) throw new Error(`Model not registered: ${name}`);
  return entry.fn(input);
}

export function listModels(): ModelName[] {
  return Array.from(registry.keys());
}

export function hasModel(name: ModelName): boolean {
  return registry.has(name);
}

export function computeAll(input: ModelInput): Record<ModelName, ModelResult> {
  const results = {} as Record<ModelName, ModelResult>;
  for (const [name, entry] of registry) {
    results[name] = entry.fn(input);
  }
  return results;
}

export function getModelCount(): number {
  return registry.size;
}

export function clearRegistry(): void {
  registry.clear();
}

export type { ModelInput, ModelResult, ModelFn };
