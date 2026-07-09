import type { HumanStateVector } from "@reyou/human-runtime";
import { ComputationalPhysics } from "@reyou/computational-physics";

// ─── Types ──────────────────────────────────────────────

export interface PredictionResult {
  state: HumanStateVector;
  confidence: number;
  risk: number;
}

export interface TrajectoryResult {
  steps: PredictionResult[];
  drift: number;
}

export interface CounterfactualResult {
  actual: HumanStateVector;
  hypothetical: HumanStateVector;
  divergence: number;
}

export interface DesiredFutureResult {
  target: HumanStateVector;
  feasibility: number;
  stepsNeeded: number;
  criticalFactors: string[];
}

export type RiskLevel = "low" | "medium" | "high" | "critical";

export interface RiskAssessment {
  level: RiskLevel;
  score: number;
  factors: string[];
}

export interface OpportunityForecast {
  potential: number;
  factors: string[];
  timeline: number;
}

export interface DriftForecast {
  direction: number;
  magnitude: number;
  factors: string[];
}

export interface RecoveryForecast {
  recoveryRate: number;
  timeToRecover: number;
  factors: string[];
}

// ─── Physics ────────────────────────────────────────────

const physics = new ComputationalPhysics();

// ─── Helpers ────────────────────────────────────────────

function extractNumber(data: Record<string, unknown>, key: string, fallback = 0): number {
  const val = data[key];
  return typeof val === "number" ? val : fallback;
}

function confidenceFromRisk(risk: number): number {
  return Math.max(0, Math.min(1, 1 - risk));
}

function stateDivergence(a: HumanStateVector, b: HumanStateVector): number {
  const keys = ["agency", "burden", "attention", "momentum", "trust", "recovery", "entropy"];
  let sum = 0;
  for (const key of keys) {
    const diff = extractNumber(a.data, key) - extractNumber(b.data, key);
    sum += diff * diff;
  }
  return Math.sqrt(sum / keys.length);
}

function riskLevel(score: number): RiskLevel {
  if (score < 0.25) return "low";
  if (score < 0.5) return "medium";
  if (score < 0.75) return "high";
  return "critical";
}

// ─── Core Functions ─────────────────────────────────────

/** Forecast N steps into the future by iteratively applying physics. */
export function forecast(state: HumanStateVector, steps: number): ForecastResult {
  const states: HumanStateVector[] = [];
  let current = { ...state, data: { ...state.data } };
  for (let i = 0; i < steps; i++) {
    current = physics.apply(current);
    current = { ...current, version: current.version + 1, timestamp: Date.now() + (i + 1) * 1000 };
    states.push({ ...current, data: { ...current.data } });
  }
  return { horizon: steps, states };
}

/** Simulate multiple possible futures with different noise profiles. */
export function simulate(
  state: HumanStateVector,
  steps: number,
  scenarios: number = 3,
): TrajectoryResult[] {
  const trajectories: TrajectoryResult[] = [];
  for (let s = 0; s < scenarios; s++) {
    const steps_result: PredictionResult[] = [];
    let current = { ...state, data: { ...state.data } };
    for (let i = 0; i < steps; i++) {
      current = physics.apply(current);
      // Apply scenario-specific perturbation to create different trajectories
      const perturbation = (s - (scenarios - 1) / 2) * 0.02;
      const perturbedData = { ...current.data };
      for (const key of ["agency", "trust", "learning", "momentum"]) {
        if (typeof perturbedData[key] === "number") {
          perturbedData[key] = Math.max(0, Math.min(1, (perturbedData[key] as number) + perturbation));
        }
      }
      current = { ...current, data: perturbedData, version: current.version + 1 };
      const noise = Math.abs(perturbation) + extractNumber(current.data, "burden") * 0.3;
      steps_result.push({
        state: { ...current, data: { ...current.data } },
        confidence: confidenceFromRisk(noise),
        risk: noise,
      });
    }
    const lastStep = steps_result[steps_result.length - 1];
    const drift = lastStep ? stateDivergence(state, lastStep.state) : 0;
    trajectories.push({ steps: steps_result, drift });
  }
  return trajectories;
}

/** Project towards a desired target state, returning feasibility. */
export function project(
  state: HumanStateVector,
  target: Record<string, number>,
): DesiredFutureResult {
  const targetState: HumanStateVector = {
    version: state.version + 1,
    timestamp: Date.now(),
    data: { ...state.data, ...target },
  };
  const current = extractNumber(state.data, "agency") + extractNumber(state.data, "trust") + extractNumber(state.data, "learning");
  const targetValues = Object.values(target);
  const needed = targetValues.length > 0
    ? targetValues.reduce((sum, v) => sum + v, 0) / targetValues.length
    : 0;
  const feasibility = needed > 0 ? Math.min(1, current / needed) : 1;
  const criticalFactors: string[] = [];
  for (const [key, val] of Object.entries(target)) {
    const currentVal = extractNumber(state.data, key);
    if (val > currentVal * 1.5) criticalFactors.push(key);
  }
  const stepsNeeded = Math.ceil(1 / Math.max(0.01, feasibility));
  return { target: targetState, feasibility, stepsNeeded, criticalFactors };
}

/** Compare two states and return divergence. */
export function compare(a: HumanStateVector, b: HumanStateVector): number {
  return stateDivergence(a, b);
}

/** Assess risk based on current state metrics. */
export function estimateRisk(state: HumanStateVector): RiskAssessment {
  const burden = extractNumber(state.data, "burden");
  const entropy = extractNumber(state.data, "entropy");
  const recovery = extractNumber(state.data, "recovery");
  const attention = extractNumber(state.data, "attention");
  const score = Math.min(1, burden * 0.4 + entropy * 0.3 + (1 - recovery) * 0.2 + (1 - attention) * 0.1);
  const factors: string[] = [];
  if (burden > 0.7) factors.push("high-burden");
  if (entropy > 0.6) factors.push("high-entropy");
  if (recovery < 0.3) factors.push("low-recovery");
  if (attention < 0.3) factors.push("low-attention");
  return { level: riskLevel(score), score, factors };
}

/** Forecast opportunity potential. */
export function estimateOpportunity(state: HumanStateVector): OpportunityForecast {
  const agency = extractNumber(state.data, "agency");
  const learning = extractNumber(state.data, "learning");
  const trust = extractNumber(state.data, "trust");
  const potential = Math.min(1, agency * 0.4 + learning * 0.3 + trust * 0.3);
  const factors: string[] = [];
  if (agency > 0.7) factors.push("high-agency");
  if (learning > 0.6) factors.push("high-learning");
  if (trust > 0.6) factors.push("high-trust");
  const timeline = Math.ceil(10 * (1 - potential));
  return { potential, factors, timeline };
}

/** Forecast drift direction and magnitude. */
export function estimateDrift(state: HumanStateVector): DriftForecast {
  const agency = extractNumber(state.data, "agency");
  const momentum = extractNumber(state.data, "momentum");
  const resistance = extractNumber(state.data, "resistance");
  const direction = agency - resistance;
  const magnitude = Math.abs(direction) + momentum * 0.3;
  const factors: string[] = [];
  if (direction > 0.3) factors.push("forward-drift");
  if (direction < -0.3) factors.push("backward-drift");
  if (magnitude > 0.7) factors.push("high-momentum");
  return { direction, magnitude, factors };
}

/** Forecast recovery trajectory. */
export function estimateRecovery(state: HumanStateVector): RecoveryForecast {
  const recovery = extractNumber(state.data, "recovery");
  const burden = extractNumber(state.data, "burden");
  const entropy = extractNumber(state.data, "entropy");
  const recoveryRate = Math.min(1, recovery * 0.5 + (1 - burden) * 0.3 + (1 - entropy) * 0.2);
  const deficit = 1 - recovery;
  const timeToRecover = Math.ceil(deficit / Math.max(0.01, recoveryRate) * 10);
  const factors: string[] = [];
  if (burden > 0.7) factors.push("high-burden-delay");
  if (entropy > 0.6) factors.push("entropy-delay");
  if (recovery > 0.8) factors.push("near-full-recovery");
  return { recoveryRate, timeToRecover, factors };
}

// ─── Counterfactual ─────────────────────────────────────

export function counterfactual(
  state: HumanStateVector,
  mutate: (s: HumanStateVector) => HumanStateVector,
): CounterfactualResult {
  const actualResult = forecast(state, 1);
  const actual = actualResult.states[0]!;
  const hypothetical = mutate({ ...state, data: { ...state.data } });
  const divergence = stateDivergence(actual, hypothetical);
  return { actual, hypothetical, divergence };
}

// ─── Re-exports ─────────────────────────────────────────

export interface ForecastResult {
  horizon: number;
  states: HumanStateVector[];
}
