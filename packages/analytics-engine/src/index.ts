import type { HumanStateVector } from "@reyou/human-runtime";
import type { EvidenceBundle } from "@reyou/evidence-runtime";
import { readFileSync, writeFileSync, mkdirSync, existsSync, appendFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

// ─── Types: Program G — Founder Analytics ────────────────

export interface FounderAnalytics {
  date: string;
  resumeLatencyMs: number | null;
  contextRecoveryTimeMs: number | null;
  recoveredTasks: number;
  forgottenTasks: number;
  burdenTrend: { direction: "improving" | "worsening" | "stable"; scores: number[] };
  presenceTimeline: { timestamp: number; state: string }[];
  recoveryEvents: { timestamp: number; duration: number; cause: string }[];
  deepWorkDurationMs: number;
  interruptions: number;
  contextSwitches: number;
  recommendationAcceptance: number;
  recommendationRejection: number;
  reflectionFrequency: number;
  captureFrequency: number;
  totalPresenceChanges: number;
  totalModeChanges: number;
  tasksCompleted: number;
  tasksCreated: number;
}

// ─── Types: Program J — Founder Timeline ─────────────────

export type TimelineEventType = "resume" | "deep_work" | "meeting" | "capture" | "recovery" | "reflection" | "shutdown";

export interface TimelineEvent {
  timestamp: number;
  type: TimelineEventType;
  evidenceBundleId: string;
  duration: number | null;
  context: string;
}

// ─── Types: Program H — Continuity Accuracy ──────────────

export interface ContinuityAccuracy {
  total: number;
  correct: number;
  partiallyCorrect: number;
  incorrect: number;
  missedContext: number;
  falseRecommendation: number;
  accuracyPercent: number;
  confidenceCalibration: number;
  evidenceCoveragePercent: number;
}

// ─── Types: Program I — Burden Calibration ────────────────

export interface CalibrationPoint {
  timestamp: number;
  predictedBurden: number;
  predictedRecovery: number;
  observedBurden: number | null;
  observedRecovery: number | null;
}

export interface BurdenCalibration {
  totalRecords: number;
  meanAbsoluteError: number | null;
  directionalAccuracy: number | null;
  records: CalibrationPoint[];
}

// ─── Types: Program K — Self Validation ─────────────────

export interface ExperimentRecord {
  id: string;
  recommendation: string;
  reason: string;
  evidence: string[];
  context: Record<string, unknown>;
  createdAt: number;
  userAction: string | null;
  userActionResult: string | null;
  evaluatedAt: number | null;
  classification: "helpful" | "ignored" | "wrong" | "unable_to_evaluate" | null;
}

// ─── Types: Program L — Scientific Dataset ───────────────

export interface DatasetEntry {
  timestamp: number;
  presence: string;
  founderMode: string;
  burden: number | null;
  recommendation: string | null;
  outcome: string | null;
  recovery: number | null;
  reflectionCount: number;
  evidenceIds: string[];
}

export interface DailyDataset {
  date: string;
  entries: DatasetEntry[];
  summary: Record<string, unknown>;
}

// ─── Types: Program M — Daily Summary ───────────────────

export interface FounderDailySummary {
  date: string;
  burden: number | null;
  recoveredContext: boolean;
  recoveredWork: number;
  interruptedWork: number;
  focusQuality: number;
  continuityAccuracy: number | null;
  recoveryTrend: string;
  reflectionStreak: number;
  deepWorkMinutes: number;
  interruptions: number;
  tasksCompleted: number;
  tasksCreated: number;
}

// ─── Storage ─────────────────────────────────────────────

const REYOU_DIR = process.env.REYOU_DATA_DIR || join(homedir(), ".reyou");
const ANALYTICS_DIR = join(REYOU_DIR, "analytics");

function ensureDir(): void {
  if (!existsSync(ANALYTICS_DIR)) {
    mkdirSync(ANALYTICS_DIR, { recursive: true });
  }
}

function analyticsPath(name: string): string {
  return join(ANALYTICS_DIR, name);
}

/** Append a JSON line to a file */
export function appendLine(file: string, data: unknown): void {
  ensureDir();
  appendFileSync(analyticsPath(file), JSON.stringify(data) + "\n", "utf-8");
}

/** Read all JSON lines from a file */
export function readLines(file: string): string[] {
  const path = analyticsPath(file);
  if (!existsSync(path)) return [];
  const content = readFileSync(path, "utf-8").trim();
  if (!content) return [];
  return content.split("\n").filter(Boolean);
}

/** Read all records from a line-delimited JSON file */
export function readRecords<T>(file: string): T[] {
  return readLines(file).map((line) => JSON.parse(line) as T);
}

/** Overwrite file with newline-delimited JSON */
export function writeRecords<T>(file: string, records: T[]): void {
  ensureDir();
  const lines = records.map((r) => JSON.stringify(r)).join("\n");
  writeFileSync(analyticsPath(file), lines + (lines ? "\n" : ""), "utf-8");
}

// ─── Program G: Founder Analytics ────────────────────────

export function computeFounderAnalytics(
  state: HumanStateVector,
  evidence: EvidenceBundle[],
  date?: string,
): FounderAnalytics {
  const today = date ?? new Date().toISOString().split("T")[0]!;
  const todayStart = new Date(today + "T00:00:00.000Z").getTime();
  const todayEnd = todayStart + 86400000;

  const todayEvidence = evidence.filter(
    (e) => e.timestamp.getTime() >= todayStart && e.timestamp.getTime() < todayEnd,
  );

  const sorted = [...todayEvidence].sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

  const presenceEvents = sorted.filter((e) => e.source === "presence-engine");
  const modeEvents = sorted.filter((e) => e.source === "founder-mode");
  const captureEvents = sorted.filter(
    (e) => e.action === "DreamCaptured" || e.action === "TaskCreated",
  );

  // Resume Latency: first "returning" to first "working"
  let resumeLatencyMs: number | null = null;
  const returningEvents = presenceEvents.filter((e) => (e.output as any)?.state === "returning");
  if (returningEvents.length > 0) {
    const firstReturn = returningEvents[0]!;
    const firstWork = presenceEvents.find(
      (e) => (e.output as any)?.state === "working" && e.timestamp > firstReturn.timestamp,
    );
    if (firstWork) {
      resumeLatencyMs = firstWork.timestamp.getTime() - firstReturn.timestamp.getTime();
    } else {
      resumeLatencyMs = todayEnd - firstReturn.timestamp.getTime();
    }
  }

  // Context Recovery: first "returning" to first task activity
  let contextRecoveryTimeMs: number | null = null;
  const taskEvents = sorted.filter((e) => e.source === "execution");
  if (returningEvents.length > 0) {
    const firstReturn = returningEvents[0]!;
    const firstTaskEvent = taskEvents.find((e) => e.timestamp > firstReturn.timestamp);
    if (firstTaskEvent) {
      contextRecoveryTimeMs = firstTaskEvent.timestamp.getTime() - firstReturn.timestamp.getTime();
    }
  }

  // Recovered tasks: tasks active after returning
  const recoveredTasks = taskEvents.filter((e) => {
    const result = (e as any).result;
    return result === "active" || result === "success";
  }).length;

  // Forgotten tasks: tasks pending at end of day
  const data = state.data as any;
  const allTasks = Object.values(data.execution?.tasks ?? {}) as any[];
  const forgottenTasks = allTasks.filter((t: any) => t.status === "pending").length;

  // Burden trend
  const burdenEvents = sorted.filter((e) => e.action === "BurdenRecorded");
  const burdenScores = burdenEvents.map((e) => (e.output as any)?.burdenScore as number).filter(Boolean);
  let burdenDirection: "improving" | "worsening" | "stable" = "stable";
  if (burdenScores.length >= 2) {
    const first = burdenScores[0]!;
    const last = burdenScores[burdenScores.length - 1]!;
    if (last < first - 5) burdenDirection = "improving";
    else if (last > first + 5) burdenDirection = "worsening";
  }

  // Presence timeline
  const presenceTimeline = presenceEvents.map((e) => ({
    timestamp: e.timestamp.getTime(),
    state: ((e.output as any)?.state as string) ?? "unknown",
  }));

  // Recovery events
  const recoveryEvents = presenceEvents
    .filter((e) => (e.output as any)?.state === "recovery")
    .map((e) => ({
      timestamp: e.timestamp.getTime(),
      duration: e.duration ?? 0,
      cause: e.rationale,
    }));

  // Deep work duration: sum of consecutive "working" durations
  const deepWorkDurationMs = presenceEvents
    .filter((e) => (e.output as any)?.state === "working")
    .reduce((sum, e) => sum + (e.duration ?? 0), 0);

  // Interruptions: from working to idle/meeting/offline
  const interruptions = presenceEvents.filter((e) => {
    const from = (e.input as any)?.previousState;
    const to = (e.output as any)?.state;
    return from === "working" && ["idle", "meeting", "offline", "recovery"].includes(to);
  }).length;

  // Context switches: mode changes
  const contextSwitches = modeEvents.length;

  // Recommendation acceptance/rejection
  const recEvents = sorted.filter((e) => e.action === "RecommendationMade");
  const acceptedRecs = recEvents.filter((e) => (e.result ?? "pending") === "success").length;
  const rejectedRecs = recEvents.filter((e) => (e.result ?? "pending") === "failure").length;

  // Reflection frequency
  const reflectionEvents = modeEvents.filter((e) => (e.output as any)?.mode === "reflection");
  const reflectionFreq = reflectionEvents.length;

  // Capture frequency
  const captureFreq = captureEvents.length;

  // Tasks completed vs created
  const tasksCompleted = taskEvents.filter((e) => (e.output as any)?.status === "completed").length;
  const tasksCreated = allTasks.filter((t: any) => {
    if (!t.createdAt) return false;
    return new Date(t.createdAt).getTime() >= todayStart && new Date(t.createdAt).getTime() < todayEnd;
  }).length;

  return {
    date: today,
    resumeLatencyMs,
    contextRecoveryTimeMs,
    recoveredTasks,
    forgottenTasks,
    burdenTrend: { direction: burdenDirection, scores: burdenScores.length > 0 ? burdenScores : [] },
    presenceTimeline,
    recoveryEvents,
    deepWorkDurationMs,
    interruptions,
    contextSwitches,
    recommendationAcceptance: acceptedRecs,
    recommendationRejection: rejectedRecs,
    reflectionFrequency: reflectionFreq,
    captureFrequency: captureFreq,
    totalPresenceChanges: presenceEvents.length,
    totalModeChanges: modeEvents.length,
    tasksCompleted,
    tasksCreated,
  };
}

// ─── Program J: Founder Timeline ────────────────────────

export function buildTimeline(
  evidence: EvidenceBundle[],
): TimelineEvent[] {
  const sorted = [...evidence].sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

  const events: TimelineEvent[] = [];

  const typeMap: Record<string, TimelineEventType> = {
    resume: "resume",
    working: "deep_work",
    meeting: "meeting",
    capture: "capture",
    recovery: "recovery",
    reflection: "reflection",
    shutdown: "shutdown",
  };

  for (const e of sorted) {
    if (e.source === "founder-mode") {
      const mode = (e.output as any)?.mode as string;
      const mapped = typeMap[mode];
      if (mapped) {
        events.push({
          timestamp: e.timestamp.getTime(),
          type: mapped,
          evidenceBundleId: e.bundleId,
          duration: e.duration ?? null,
          context: e.rationale,
        });
      }
    } else if (e.action === "TaskCompleted") {
      events.push({
        timestamp: e.timestamp.getTime(),
        type: "capture",
        evidenceBundleId: e.bundleId,
        duration: e.duration ?? null,
        context: `Task completed: ${(e.input as any)?.title ?? "unknown"}`,
      });
    } else if (e.action === "DreamCaptured") {
      events.push({
        timestamp: e.timestamp.getTime(),
        type: "capture",
        evidenceBundleId: e.bundleId,
        duration: null,
        context: `Dream captured: ${(e.input as any)?.content ?? "unknown"}`,
      });
    }
  }

  return events;
}

// ─── Program H: Continuity Accuracy ──────────────────────

export function computeContinuityAccuracy(
  evidence: EvidenceBundle[],
): ContinuityAccuracy {
  const recEvents = evidence.filter((e) => e.action === "RecommendationMade");
  const followUpEvents = evidence.filter(
    (e) => e.action === "RecommendationOutcome",
  );

  const total = recEvents.length;
  let correct = 0;
  let partiallyCorrect = 0;
  let incorrect = 0;
  let missedContext = 0;
  let falseRecommendation = 0;

  for (const rec of recEvents) {
    const recommendation = ((rec.input as any)?.recommendation ?? "") as string;
    const hasContext = ((rec.input as any)?.hasContext ?? false) as boolean;

    // Find follow-up outcomes for this recommendation
    const outcome = followUpEvents.find(
      (f) =>
        f.timestamp > rec.timestamp &&
        f.timestamp.getTime() - rec.timestamp.getTime() < 3600000 && // within 1 hour
        ((f.input as any)?.recommendationId === rec.bundleId ||
          (f.input as any)?.recommendation === recommendation),
    );

    if (outcome) {
      const rating = (outcome.output as any)?.rating as string;
      if (rating === "correct") correct++;
      else if (rating === "partial") partiallyCorrect++;
      else if (rating === "incorrect") incorrect++;
      else if (rating === "false") falseRecommendation++;
    } else if (!hasContext) {
      missedContext++;
    }
  }

  // Evidence coverage: recommendations that had evidence backing
  const withCoverage = recEvents.filter(
    (e) => {
      const evidenceArr = (e.input as any)?.evidence as unknown[];
      return Array.isArray(evidenceArr) && evidenceArr.length > 0;
    },
  ).length;

  const evidenceCoveragePercent = total > 0 ? Math.round((withCoverage / total) * 100) : 100;

  // Confidence calibration: average confidence of correct recommendations
  const correctRecs = recEvents.filter((e) => {
    const outcome = followUpEvents.find(
      (f) =>
        f.timestamp > e.timestamp &&
        f.timestamp.getTime() - e.timestamp.getTime() < 3600000 &&
        ((f.input as any)?.recommendationId === e.bundleId),
    );
    return outcome && (outcome.output as any)?.rating === "correct";
  });

  const avgConfidence =
    correctRecs.length > 0
      ? correctRecs.reduce((s, r) => s + r.confidence, 0) / correctRecs.length
      : 0;

  const accuracyPercent = total > 0 ? Math.round(((correct + partiallyCorrect) / total) * 100) : 100;

  return {
    total,
    correct,
    partiallyCorrect,
    incorrect,
    missedContext,
    falseRecommendation,
    accuracyPercent,
    confidenceCalibration: Math.round(avgConfidence * 100) / 100,
    evidenceCoveragePercent,
  };
}

// ─── Program I: Burden Calibration ───────────────────────

const CALIBRATION_FILE = "burden-calibration.jsonl";

export function recordBurdenObservation(point: {
  timestamp: number;
  predictedBurden: number;
  predictedRecovery: number;
  observedBurden?: number;
  observedRecovery?: number;
}): void {
  appendLine(CALIBRATION_FILE, {
    timestamp: point.timestamp,
    predictedBurden: point.predictedBurden,
    predictedRecovery: point.predictedRecovery,
    observedBurden: point.observedBurden ?? null,
    observedRecovery: point.observedRecovery ?? null,
  });
}

export function updateBurdenObservation(
  timestamp: number,
  observed: { observedBurden: number; observedRecovery: number },
): void {
  const records = readRecords<CalibrationPoint>(CALIBRATION_FILE);
  const idx = records.findIndex((r) => r.timestamp === timestamp);
  if (idx >= 0) {
    records[idx]!.observedBurden = observed.observedBurden;
    records[idx]!.observedRecovery = observed.observedRecovery;
    writeRecords(CALIBRATION_FILE, records);
  }
}

export function computeBurdenCalibration(): BurdenCalibration {
  const records = readRecords<CalibrationPoint>(CALIBRATION_FILE);

  const withObservation = records.filter(
    (r) => r.observedBurden !== null && r.observedRecovery !== null,
  );

  let meanAbsoluteError: number | null = null;
  let directionalAccuracy: number | null = null;

  if (withObservation.length > 0) {
    const errors = withObservation.map((r) => Math.abs(r.predictedBurden - r.observedBurden!));
    meanAbsoluteError = Math.round((errors.reduce((a, b) => a + b, 0) / errors.length) * 100) / 100;

    // Directional: did burden direction prediction match?
    const directionMatches = withObservation.filter((r) => {
      const predictedDirection = r.predictedBurden > 50 ? "high" : "low";
      const observedDirection = r.observedBurden! > 50 ? "high" : "low";
      return predictedDirection === observedDirection;
    }).length;
    directionalAccuracy = Math.round((directionMatches / withObservation.length) * 100) / 100;
  }

  return {
    totalRecords: records.length,
    meanAbsoluteError,
    directionalAccuracy,
    records: records.slice(-50),
  };
}

// ─── Program K: Self Validation — Experiments ────────────

const EXPERIMENTS_FILE = "experiments.jsonl";

export function recordExperiment(experiment: {
  recommendation: string;
  reason: string;
  evidence: string[];
  context: Record<string, unknown>;
}): void {
  appendLine(EXPERIMENTS_FILE, {
    id: `exp-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    ...experiment,
    createdAt: Date.now(),
    userAction: null,
    userActionResult: null,
    evaluatedAt: null,
    classification: null,
  });
}

export function recordExperimentOutcome(
  id: string,
  outcome: {
    userAction: string;
    userActionResult: string;
    classification: "helpful" | "ignored" | "wrong" | "unable_to_evaluate";
  },
): void {
  const records = readRecords<ExperimentRecord>(EXPERIMENTS_FILE);
  const idx = records.findIndex((r) => r.id === id);
  if (idx >= 0) {
    records[idx]!.userAction = outcome.userAction;
    records[idx]!.userActionResult = outcome.userActionResult;
    records[idx]!.classification = outcome.classification;
    records[idx]!.evaluatedAt = Date.now();
    writeRecords(EXPERIMENTS_FILE, records);
  }
}

export function getExperiments(): ExperimentRecord[] {
  return readRecords<ExperimentRecord>(EXPERIMENTS_FILE);
}

export function classifyExperiments(): Record<string, number> {
  const records = getExperiments();
  const classified = records.filter((r) => r.classification !== null);
  const result: Record<string, number> = {
    helpful: 0,
    ignored: 0,
    wrong: 0,
    unable_to_evaluate: 0,
    total: classified.length,
  };

  for (const r of classified) {
    const key = r.classification!;
    if (result[key] !== undefined) result[key]++;
  }

  return result;
}

// ─── Program L: Scientific Dataset ───────────────────────

const DATASET_FILE_PREFIX = "dataset-";

export function generateDailyDataset(
  date: string,
  analytics: FounderAnalytics,
  timeline: TimelineEvent[],
  accuracy: ContinuityAccuracy,
  calibration: BurdenCalibration,
  state: HumanStateVector,
): DailyDataset {
  const data = state.data as any;
  const entries: DatasetEntry[] = timeline.map((t) => ({
    timestamp: t.timestamp,
    presence: analytics.presenceTimeline.find((p) => p.timestamp <= t.timestamp)?.state ?? "unknown",
    founderMode: t.type,
    burden: null,
    recommendation: null,
    outcome: null,
    recovery: null,
    reflectionCount: 0,
    evidenceIds: [t.evidenceBundleId],
  }));

  const summary: Record<string, unknown> = {
    date,
    totalEvents: timeline.length,
    resumeLatencyMs: analytics.resumeLatencyMs,
    contextRecoveryTimeMs: analytics.contextRecoveryTimeMs,
    deepWorkMinutes: Math.round(analytics.deepWorkDurationMs / 60000),
    interruptions: analytics.interruptions,
    tasksCompleted: analytics.tasksCompleted,
    tasksCreated: analytics.tasksCreated,
    continuityAccuracy: accuracy.accuracyPercent,
    burdenCalibrationMAE: calibration.meanAbsoluteError,
    experiments: classifyExperiments(),
    burdenTrend: analytics.burdenTrend.direction,
    reflectionFrequency: analytics.reflectionFrequency,
    captureFrequency: analytics.captureFrequency,
    totalDreams: Object.keys(data.dreams ?? {}).length,
    totalTasks: Object.keys(data.execution?.tasks ?? {}).length,
    totalProjects: Object.keys(data.execution?.projects ?? {}).length,
  };

  return { date, entries, summary };
}

export function saveDailyDataset(dataset: DailyDataset): void {
  const file = `${DATASET_FILE_PREFIX}${dataset.date}.json`;
  const path = analyticsPath(file);
  if (existsSync(path)) {
    const existing = JSON.parse(readFileSync(path, "utf-8")) as DailyDataset;
    existing.entries.push(...dataset.entries);
    existing.summary = dataset.summary;
    writeFileSync(path, JSON.stringify(existing, null, 2), "utf-8");
  } else {
    ensureDir();
    writeFileSync(path, JSON.stringify(dataset, null, 2), "utf-8");
  }
}

export function getDailyDataset(date: string): DailyDataset | null {
  const file = `${DATASET_FILE_PREFIX}${date}.json`;
  const path = analyticsPath(file);
  if (!existsSync(path)) return null;
  return JSON.parse(readFileSync(path, "utf-8")) as DailyDataset;
}

export function listDatasets(): string[] {
  if (!existsSync(ANALYTICS_DIR)) return [];
  return readdirSync(ANALYTICS_DIR)
    .filter((f: string) => f.startsWith(DATASET_FILE_PREFIX) && f.endsWith(".json"))
    .map((f: string) => f.replace(DATASET_FILE_PREFIX, "").replace(".json", ""))
    .sort();
}

// ─── Program M: Daily Summary Builder ────────────────────

export function buildDailySummary(
  analytics: FounderAnalytics,
  accuracy: ContinuityAccuracy,
): FounderDailySummary {
  const burden = analytics.burdenTrend.scores.length > 0
    ? analytics.burdenTrend.scores[analytics.burdenTrend.scores.length - 1]!
    : null;

  let recoveryTrend = "stable";
  if (analytics.recoveryEvents.length > 0) {
    const avgDuration =
      analytics.recoveryEvents.reduce((s, r) => s + r.duration, 0) / analytics.recoveryEvents.length;
    if (avgDuration < 300000) recoveryTrend = "fast"; // < 5 min
    else if (avgDuration > 1800000) recoveryTrend = "slow"; // > 30 min
  }

  return {
    date: analytics.date,
    burden,
    recoveredContext: analytics.contextRecoveryTimeMs !== null,
    recoveredWork: analytics.recoveredTasks,
    interruptedWork: analytics.interruptions,
    focusQuality: analytics.deepWorkDurationMs > 3600000 ? 1 : // > 1hr
      analytics.deepWorkDurationMs > 1800000 ? 2 : // > 30min
        analytics.deepWorkDurationMs > 600000 ? 3 : 4, // > 10min / poor
    continuityAccuracy: accuracy.accuracyPercent,
    recoveryTrend,
    reflectionStreak: analytics.reflectionFrequency,
    deepWorkMinutes: Math.round(analytics.deepWorkDurationMs / 60000),
    interruptions: analytics.interruptions,
    tasksCompleted: analytics.tasksCompleted,
    tasksCreated: analytics.tasksCreated,
  };
}

// ─── Program N: Dogfood Mode ─────────────────────────────

export function buildDogfoodCycle(
  state: HumanStateVector,
  evidence: EvidenceBundle[],
): {
  startDay: { mode: string; timestamp: number };
  resumeContext: { whatWasIDoing: string; tasks: number };
  recommendations: { count: number; list: string[] };
  endDay: { analytics: FounderAnalytics; summary: FounderDailySummary };
} {
  const analytics = computeFounderAnalytics(state, evidence);
  const accuracy = computeContinuityAccuracy(evidence);
  const summary = buildDailySummary(analytics, accuracy);

  const data = state.data as any;
  const allTasks = Object.values(data.execution?.tasks ?? {}) as any[];
  const activeTasks = allTasks.filter((t: any) => t.status === "in_progress");
  const pendingTasks = allTasks.filter((t: any) => t.status === "pending");

  const whatWasIDoing =
    activeTasks.length > 0
      ? `Working on "${activeTasks[0]!.title}"`
      : pendingTasks.length > 0
        ? `${pendingTasks.length} pending tasks`
        : "No active work";

  const recommendations: string[] = [];
  if (analytics.burdenTrend.scores.length > 0) {
    const latestBurden = analytics.burdenTrend.scores[analytics.burdenTrend.scores.length - 1]!;
    if (latestBurden > 70) recommendations.push("Take a recovery break — burden is high");
    else if (activeTasks.length > 0) recommendations.push(`Continue: "${activeTasks[0]!.title}"`);
    else if (pendingTasks.length > 0) recommendations.push(`Start: "${pendingTasks[0]!.title}"`);
  }

  return {
    startDay: { mode: "morning", timestamp: Date.now() },
    resumeContext: { whatWasIDoing, tasks: activeTasks.length + pendingTasks.length },
    recommendations: { count: recommendations.length, list: recommendations },
    endDay: { analytics, summary },
  };
}
