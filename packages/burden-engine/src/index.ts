import type { HumanStateVector } from "@reyou/human-runtime";

// ─── Types ───────────────────────────────────────────────

export interface BurdenInput {
  /** Open tasks requiring attention */
  openTasks: number;
  /** Blocked tasks unable to proceed */
  blockedTasks: number;
  /** Tasks in progress */
  activeTasks: number;
  /** Tasks completed today */
  completedTasks: number;
  /** Active dreams/aspirations */
  activeDreams: number;
  /** Active projects */
  activeProjects: number;
  /** Negative emotion observations (stressed, overwhelmed, etc.) */
  negativeEmotions: number;
  /** Total emotion observations */
  totalEmotions: number;
  /** Hours since last activity */
  hoursSinceActive: number;
}

export interface BurdenResult {
  /** Burden score 0-100 */
  burdenScore: number;
  /** Recovery score 0-100 */
  recoveryScore: number;
  /** Attention cost (sum of weighted inputs) */
  attentionCost: number;
  /** Trend: low, moderate, high */
  trend: "low" | "moderate" | "high";
  /** Confidence in the calculation */
  confidence: number;
  /** Human-readable explanation */
  explanation: string[];
  /** Primary cause of burden */
  primaryCause: string;
  /** Suggested recovery action */
  suggestedRecovery: string;
  /** Raw inputs for transparency */
  inputs: BurdenInput;
}

export interface BurdenSnapshot {
  timestamp: number;
  burdenScore: number;
  recoveryScore: number;
  trend: "low" | "moderate" | "high";
}

export interface BurdenTrend {
  /** Current burden score */
  current: number;
  /** Previous burden score (from last calculation) */
  previous: number | null;
  /** Change from previous */
  change: number;
  /** Direction: improving, worsening, stable */
  direction: "improving" | "worsening" | "stable";
  /** History of burden scores (last 24 entries) */
  history: BurdenSnapshot[];
}

// ─── Deterministic Weights ───────────────────────────────

/** Weights derived from observable cognitive load patterns */
const WEIGHTS = {
  /** Each active task costs 25 attention units */
  ACTIVE_TASK: 25,
  /** Each pending task costs 10 attention units */
  PENDING_TASK: 10,
  /** Each blocked task costs 15 attention units */
  BLOCKED_TASK: 15,
  /** Each negative emotion costs 20 attention units */
  NEGATIVE_EMOTION: 20,
  /** Each open loop (dream, project) costs 5 attention units, capped at 50 */
  OPEN_LOOP: 5,
  MAX_OPEN_LOOP_COST: 50,
} as const;

// ─── Calculation ─────────────────────────────────────────

/**
 * Calculate burden from observable inputs.
 * Pure function — same inputs always produce same output.
 */
export function calculateBurden(input: BurdenInput): BurdenResult {
  // Calculate attention cost
  let attentionCost = 0;
  attentionCost += input.activeTasks * WEIGHTS.ACTIVE_TASK;
  attentionCost += input.openTasks * WEIGHTS.PENDING_TASK;
  attentionCost += input.blockedTasks * WEIGHTS.BLOCKED_TASK;
  attentionCost += input.negativeEmotions * WEIGHTS.NEGATIVE_EMOTION;

  const openLoops = input.activeDreams + input.activeProjects;
  attentionCost += Math.min(openLoops * WEIGHTS.OPEN_LOOP, WEIGHTS.MAX_OPEN_LOOP_COST);

  // Calculate burden score (capped at 100)
  const burdenScore = Math.max(0, Math.min(100, attentionCost));

  // Calculate recovery score
  let recoveryScore = 100;
  recoveryScore -= Math.min(attentionCost, 80);
  if (input.hoursSinceActive > 8) recoveryScore += 10;
  if (input.negativeEmotions === 0 && input.completedTasks > 0) recoveryScore += 10;
  recoveryScore = Math.max(0, Math.min(100, recoveryScore));

  // Determine trend
  const trend = burdenScore < 30 ? "low" : burdenScore < 60 ? "moderate" : "high";

  // Calculate confidence
  const confidence = Math.min(1, 0.5 + (input.totalEmotions * 0.05) + ((input.activeTasks + input.openTasks) * 0.03));

  // Generate explanation
  const explanation = generateExplanation(input);

  // Determine primary cause
  const primaryCause = determinePrimaryCause(input);

  // Suggest recovery
  const suggestedRecovery = suggestRecovery(input, burdenScore);

  return {
    burdenScore,
    recoveryScore,
    attentionCost,
    trend,
    confidence,
    explanation,
    primaryCause,
    suggestedRecovery,
    inputs: input,
  };
}

/**
 * Calculate burden from Runtime state.
 * Extracts signals and computes burden.
 */
export function calculateBurdenFromState(state: HumanStateVector): BurdenResult {
  const data = state.data as any;

  const tasks = Object.values(data.execution?.tasks ?? {}) as any[];
  const activeTasks = tasks.filter(t => t.status === "in_progress").length;
  const openTasks = tasks.filter(t => t.status === "pending").length;
  const blockedTasks = tasks.filter(t => t.status === "blocked").length;

  const today = new Date().toISOString().split("T")[0]!;
  const completedTasks = tasks.filter(
    t => t.status === "completed" && t.completedAt?.startsWith(today)
  ).length;

  const emotions = Object.values(data.emotion?.observations ?? {}) as any[];
  const recentEmotions = emotions.slice(-5);
  const negativeEmotions = recentEmotions.filter(e =>
    e.confidence > 0.6 && ["stressed", "overwhelmed", "anxious", "tired", "frustrated"].includes(e.observation)
  ).length;

  const dreams = Object.values(data.dreams ?? {}) as any[];
  const activeDreams = dreams.filter(d => d.activated).length;

  const projects = Object.values(data.execution?.projects ?? {}) as any[];
  const activeProjects = projects.filter(p => p.status === "active").length;

  const timeSinceLastActive = Date.now() - state.timestamp;
  const hoursSinceActive = timeSinceLastActive / 3600000;

  return calculateBurden({
    openTasks,
    blockedTasks,
    activeTasks,
    completedTasks,
    activeDreams,
    activeProjects,
    negativeEmotions,
    totalEmotions: emotions.length,
    hoursSinceActive,
  });
}

// ─── Trend Tracking ──────────────────────────────────────

const MAX_HISTORY = 24;
const history: BurdenSnapshot[] = [];

/**
 * Record a burden snapshot and return the trend.
 */
export function recordBurdenTrend(result: BurdenResult): BurdenTrend {
  const snapshot: BurdenSnapshot = {
    timestamp: Date.now(),
    burdenScore: result.burdenScore,
    recoveryScore: result.recoveryScore,
    trend: result.trend,
  };

  const previous = history.length > 0 ? history[history.length - 1]! : null;
  history.push(snapshot);

  // Trim history
  if (history.length > MAX_HISTORY) {
    history.shift();
  }

  const change = previous ? result.burdenScore - previous.burdenScore : 0;
  const direction = change < -5 ? "improving" : change > 5 ? "worsening" : "stable";

  return {
    current: result.burdenScore,
    previous: previous?.burdenScore ?? null,
    change,
    direction,
    history: [...history],
  };
}

/**
 * Get current burden trend without recording.
 */
export function getBurdenTrend(): BurdenTrend {
  const previous = history.length > 0 ? history[history.length - 1]! : null;
  const current = previous?.burdenScore ?? 0;
  const change = 0;

  return {
    current,
    previous: null,
    change,
    direction: "stable",
    history: [...history],
  };
}

// ─── Helpers ─────────────────────────────────────────────

function generateExplanation(input: BurdenInput): string[] {
  const explanation: string[] = [];

  if (input.activeTasks > 0) explanation.push(`${input.activeTasks} task${input.activeTasks > 1 ? "s" : ""} in progress`);
  if (input.openTasks > 0) explanation.push(`${input.openTasks} task${input.openTasks > 1 ? "s" : ""} awaiting attention`);
  if (input.blockedTasks > 0) explanation.push(`${input.blockedTasks} task${input.blockedTasks > 1 ? "s" : ""} blocked`);
  if (input.negativeEmotions > 0) explanation.push(`${input.negativeEmotions} negative observation${input.negativeEmotions > 1 ? "s" : ""}`);

  const openLoops = input.activeDreams + input.activeProjects;
  if (openLoops > 3) explanation.push(`${openLoops} open loops`);

  if (input.completedTasks > 0) explanation.push(`${input.completedTasks} task${input.completedTasks > 1 ? "s" : ""} addressed today`);

  return explanation;
}

function determinePrimaryCause(input: BurdenInput): string {
  const costs = [
    { cause: "active tasks", cost: input.activeTasks * WEIGHTS.ACTIVE_TASK },
    { cause: "pending tasks", cost: input.openTasks * WEIGHTS.PENDING_TASK },
    { cause: "blocked tasks", cost: input.blockedTasks * WEIGHTS.BLOCKED_TASK },
    { cause: "negative emotions", cost: input.negativeEmotions * WEIGHTS.NEGATIVE_EMOTION },
    { cause: "open loops", cost: Math.min((input.activeDreams + input.activeProjects) * WEIGHTS.OPEN_LOOP, WEIGHTS.MAX_OPEN_LOOP_COST) },
  ];

  costs.sort((a, b) => b.cost - a.cost);
  const top = costs[0];
  return top && top.cost > 0 ? top.cause : "none";
}

function suggestRecovery(input: BurdenInput, burdenScore: number): string {
  if (burdenScore < 30) return "Continue working — burden is low";
  if (input.blockedTasks > 0) return "Unblock tasks to reduce cognitive load";
  if (input.negativeEmotions > 2) return "Take a break — multiple negative observations";
  if (input.activeTasks > 3) return "Focus on one task at a time";
  if (input.openTasks > 5) return "Prioritize and defer low-value tasks";
  if (input.hoursSinceActive > 4) return "Consider a recovery period";
  return "Continue with current focus";
}
