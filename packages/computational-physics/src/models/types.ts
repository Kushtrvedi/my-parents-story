export interface ModelInput {
  agency: number;
  burden: number;
  attention: number;
  momentum: number;
  resistance: number;
  recovery: number;
  trust: number;
  opportunity: number;
  learning: number;
  entropy: number;
  identityStability: number;
  reflectionStrength: number;
  dreamMomentum: number;
}

export interface ModelResult {
  value: number;
  confidence: number;
  metadata?: Record<string, unknown>;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

export interface BenchmarkResult {
  iterations: number;
  avgMs: number;
  minMs: number;
  maxMs: number;
  p99Ms: number;
}

export type ModelFn = (input: ModelInput) => ModelResult;
