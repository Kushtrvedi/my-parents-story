import type { HumanStateVector } from "@reyou/human-runtime";

// ─── Presence States ─────────────────────────────────────

export type PresenceState =
  | "working"      // Active engagement with tasks/projects
  | "idle"         // No recent activity, but session alive
  | "meeting"      // Calendar indicates meeting
  | "recovery"     // Post-meeting, pre-next-task transition
  | "reflection"   // End-of-day or post-completion review
  | "offline"      // No session / WebSocket disconnected
  | "returning";   // Reconnecting after absence

// ─── Detection Signals ───────────────────────────────────

export interface PresenceSignals {
  /** Time since last state mutation (ms) */
  timeSinceLastMutation: number;
  /** Time since last WebSocket activity (ms) */
  timeSinceLastActivity: number;
  /** Number of active (in-progress) tasks */
  activeTasks: number;
  /** Number of pending tasks */
  pendingTasks: number;
  /** Number of completed tasks today */
  completedTasksToday: number;
  /** Recent emotion observations (last 5) */
  recentEmotions: string[];
  /** Current hour (0-23) in local time */
  currentHour: number;
  /** Whether a meeting is detected */
  meetingDetected: boolean;
  /** WebSocket client count */
  wsClientCount: number;
}

// ─── Transition Rules ────────────────────────────────────

export interface TransitionRule {
  from: PresenceState;
  to: PresenceState;
  /** Returns true if transition should fire */
  guard: (signals: PresenceSignals, currentState: PresenceState) => boolean;
  /** Human-readable reason for the transition */
  reason: (signals: PresenceSignals) => string;
}

// ─── Evidence ────────────────────────────────────────────

export interface PresenceEvidence {
  timestamp: number;
  previousState: PresenceState;
  newState: PresenceState;
  reason: string;
  signals: PresenceSignals;
  confidence: number;
}

// ─── Detection Logic ─────────────────────────────────────

/** Thresholds derived from observable behavior, not arbitrary constants */
const THRESHOLDS = {
  /** Under 5 minutes = working (task activity assumed) */
  WORKING_MAX_IDLE_MS: 5 * 60 * 1000,
  /** 5-30 minutes = idle */
  IDLE_MIN_MS: 5 * 60 * 1000,
  IDLE_MAX_MS: 30 * 60 * 1000,
  /** Over 30 minutes = offline */
  OFFLINE_MIN_MS: 30 * 60 * 1000,
  /** Recovery window after meeting ends */
  RECOVERY_WINDOW_MS: 10 * 60 * 1000,
  /** Reflection: end of day (after 18:00) or post-completion */
  REFLECTION_HOUR_START: 18,
  /** Morning: before 09:00 */
  MORNING_HOUR_END: 9,
  /** Meeting detected = recent emotion contains meeting-related signals */
  MEETING_SIGNALS: ["meeting", "call", "discussion", "standup", "sync", "review"],
} as const;

/**
 * Detect presence state from observable Runtime signals.
 * Pure function — same inputs always produce same output.
 */
export function detectPresence(signals: PresenceSignals): PresenceState {
  const {
    timeSinceLastMutation,
    timeSinceLastActivity,
    activeTasks,
    pendingTasks,
    completedTasksToday,
    recentEmotions,
    currentHour,
    meetingDetected,
    wsClientCount,
  } = signals;

  // Offline: no WebSocket connection
  if (wsClientCount === 0) return "offline";

  // Meeting detected from signals
  if (meetingDetected) return "meeting";

  // Check for meeting-related emotions in recent observations
  const hasMeetingEmotion = recentEmotions.some(e =>
    THRESHOLDS.MEETING_SIGNALS.some(s => e.toLowerCase().includes(s))
  );
  if (hasMeetingEmotion) return "meeting";

  // Returning: just reconnected after long absence
  if (timeSinceLastActivity > THRESHOLDS.OFFLINE_MIN_MS && wsClientCount > 0) {
    return "returning";
  }

  // Reflection: end of day with completed work
  if (currentHour >= THRESHOLDS.REFLECTION_HOUR_START && completedTasksToday > 0) {
    return "reflection";
  }

  // Working: active tasks and recent mutation
  if (activeTasks > 0 && timeSinceLastMutation < THRESHOLDS.WORKING_MAX_IDLE_MS) {
    return "working";
  }

  // Working: pending tasks and very recent mutation
  if (pendingTasks > 0 && timeSinceLastMutation < THRESHOLDS.WORKING_MAX_IDLE_MS) {
    return "working";
  }

  // Idle: some activity but not enough for working
  if (timeSinceLastMutation < THRESHOLDS.IDLE_MAX_MS) {
    return "idle";
  }

  // Recovery: was in meeting, now transitioned out
  if (timeSinceLastMutation < THRESHOLDS.RECOVERY_WINDOW_MS && completedTasksToday === 0) {
    return "recovery";
  }

  // Default: idle
  return "idle";
}

// ─── Transition Graph ────────────────────────────────────

const TRANSITION_RULES: TransitionRule[] = [
  // Any state -> returning (after long absence)
  {
    from: "offline",
    to: "returning",
    guard: (s) => s.wsClientCount > 0 && s.timeSinceLastActivity > THRESHOLDS.OFFLINE_MIN_MS,
    reason: (s) => `Reconnected after ${Math.round(s.timeSinceLastActivity / 60000)} minutes`,
  },
  // Returning -> working (has active tasks)
  {
    from: "returning",
    to: "working",
    guard: (s) => s.activeTasks > 0,
    reason: () => "Active tasks found, resuming work",
  },
  // Returning -> idle (no active tasks)
  {
    from: "returning",
    to: "idle",
    guard: (s) => s.activeTasks === 0 && s.pendingTasks > 0,
    reason: () => "No active tasks, but pending work exists",
  },
  // Working -> meeting
  {
    from: "working",
    to: "meeting",
    guard: (s) => s.meetingDetected,
    reason: () => "Meeting detected",
  },
  // Working -> idle (no recent mutation)
  {
    from: "working",
    to: "idle",
    guard: (s) => s.timeSinceLastMutation > THRESHOLDS.WORKING_MAX_IDLE_MS,
    reason: (s) => `No activity for ${Math.round(s.timeSinceLastMutation / 60000)} minutes`,
  },
  // Working -> reflection (end of day with completions)
  {
    from: "working",
    to: "reflection",
    guard: (s) => s.currentHour >= THRESHOLDS.REFLECTION_HOUR_START && s.completedTasksToday > 0,
    reason: () => "End of day with completed work",
  },
  // Meeting -> recovery (meeting ended)
  {
    from: "meeting",
    to: "recovery",
    guard: (s) => !s.meetingDetected && s.timeSinceLastMutation < THRESHOLDS.RECOVERY_WINDOW_MS,
    reason: () => "Meeting ended, entering recovery",
  },
  // Recovery -> working (resumed tasks)
  {
    from: "recovery",
    to: "working",
    guard: (s) => s.activeTasks > 0 && s.timeSinceLastMutation < THRESHOLDS.WORKING_MAX_IDLE_MS,
    reason: () => "Resumed active tasks after recovery",
  },
  // Recovery -> idle
  {
    from: "recovery",
    to: "idle",
    guard: (s) => s.timeSinceLastMutation > THRESHOLDS.RECOVERY_WINDOW_MS,
    reason: () => "Recovery window elapsed",
  },
  // Reflection -> idle
  {
    from: "reflection",
    to: "idle",
    guard: (s) => s.currentHour < THRESHOLDS.REFLECTION_HOUR_START || s.completedTasksToday === 0,
    reason: () => "Reflection complete",
  },
  // Idle -> working (new activity)
  {
    from: "idle",
    to: "working",
    guard: (s) => s.activeTasks > 0 && s.timeSinceLastMutation < THRESHOLDS.WORKING_MAX_IDLE_MS,
    reason: () => "New task activity detected",
  },
  // Idle -> meeting
  {
    from: "idle",
    to: "meeting",
    guard: (s) => s.meetingDetected,
    reason: () => "Meeting detected",
  },
  // Idle -> reflection (end of day)
  {
    from: "idle",
    to: "reflection",
    guard: (s) => s.currentHour >= THRESHOLDS.REFLECTION_HOUR_START && s.completedTasksToday > 0,
    reason: () => "End of day reflection",
  },
  // Any -> offline (no WebSocket)
  {
    from: "working",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
  {
    from: "idle",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
  {
    from: "meeting",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
  {
    from: "recovery",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
  {
    from: "reflection",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
  {
    from: "returning",
    to: "offline",
    guard: (s) => s.wsClientCount === 0,
    reason: () => "WebSocket disconnected",
  },
];

// ─── Engine ──────────────────────────────────────────────

export interface PresenceResult {
  state: PresenceState;
  previousState: PresenceState | null;
  changed: boolean;
  evidence: PresenceEvidence | null;
  transitions: PresenceState[];
}

/**
 * Compute presence state from signals and current state.
 * Returns the new state and whether it changed.
 */
export function computePresence(
  signals: PresenceSignals,
  currentState: PresenceState = "offline"
): PresenceResult {
  // Try transition rules first (ordered by specificity)
  for (const rule of TRANSITION_RULES) {
    if (rule.from === currentState && rule.guard(signals, currentState)) {
      const newState = rule.to;
      const evidence: PresenceEvidence = {
        timestamp: Date.now(),
        previousState: currentState,
        newState,
        reason: rule.reason(signals),
        signals,
        confidence: computeConfidence(signals, newState),
      };
      return {
        state: newState,
        previousState: currentState,
        changed: newState !== currentState,
        evidence,
        transitions: getTransitionPath(currentState, newState),
      };
    }
  }

  // No transition matched — use direct detection
  const detected = detectPresence(signals);
  const changed = detected !== currentState;
  const evidence: PresenceEvidence | null = changed ? {
    timestamp: Date.now(),
    previousState: currentState,
    newState: detected,
    reason: `Direct detection: ${detected}`,
    signals,
    confidence: computeConfidence(signals, detected),
  } : null;

  return {
    state: detected,
    previousState: currentState,
    changed,
    evidence,
    transitions: changed ? [currentState, detected] : [currentState],
  };
}

// ─── Helpers ─────────────────────────────────────────────

function computeConfidence(signals: PresenceSignals, state: PresenceState): number {
  let confidence = 0.5; // Base confidence

  // More signals = higher confidence
  if (signals.activeTasks > 0) confidence += 0.1;
  if (signals.pendingTasks > 0) confidence += 0.05;
  if (signals.completedTasksToday > 0) confidence += 0.05;
  if (signals.recentEmotions.length > 0) confidence += 0.05;
  if (signals.meetingDetected) confidence += 0.15;

  // Time-based confidence
  if (state === "working" && signals.timeSinceLastMutation < 60000) confidence += 0.1;
  if (state === "offline" && signals.wsClientCount === 0) confidence += 0.2;

  return Math.min(1, confidence);
}

function getTransitionPath(from: PresenceState, to: PresenceState): PresenceState[] {
  // Direct transition — no intermediate states needed
  return [from, to];
}

/**
 * Extract presence signals from Runtime state.
 * Pure function — reads from state vector only.
 */
export function extractSignals(
  state: HumanStateVector,
  wsClientCount: number,
  lastActivityTimestamp?: number
): PresenceSignals {
  const data = state.data as any;
  const now = Date.now();

  const tasks = Object.values(data.execution?.tasks ?? {}) as any[];
  const activeTasks = tasks.filter(t => t.status === "in_progress").length;
  const pendingTasks = tasks.filter(t => t.status === "pending").length;

  const today = new Date().toISOString().split("T")[0];
  const completedTasksToday = tasks.filter(
    t => t.status === "completed" && t.completedAt?.startsWith(today)
  ).length;

  const emotions = Object.values(data.emotion?.observations ?? {}) as any[];
  const recentEmotions = emotions.slice(-5).map(e => e.observation ?? "");

  const currentHour = new Date().getHours();

  // Check for meeting signals in recent emotions
  const meetingSignals = ["meeting", "call", "discussion", "standup", "sync", "review"];
  const meetingDetected = recentEmotions.some(e =>
    meetingSignals.some(s => e.toLowerCase().includes(s))
  );

  return {
    timeSinceLastMutation: now - state.timestamp,
    timeSinceLastActivity: now - (lastActivityTimestamp ?? state.timestamp),
    activeTasks,
    pendingTasks,
    completedTasksToday,
    recentEmotions,
    currentHour,
    meetingDetected,
    wsClientCount,
  };
}
