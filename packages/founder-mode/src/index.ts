import type { HumanStateVector } from "@reyou/human-runtime";
import type { PresenceState } from "@reyou/presence-engine";

// ─── Founder Mode States ─────────────────────────────────

export type FounderMode =
  | "morning"      // Start of day, loading context
  | "resume"       // Returning after absence, loading context
  | "work"         // Active task engagement
  | "meeting"      // Calendar indicates meeting
  | "capture"      // Quick capture of thought/task
  | "recovery"     // Post-meeting, pre-next-task transition
  | "reflection"   // End-of-day review
  | "shutdown";    // End of day, persisting state

// ─── Transition Triggers ─────────────────────────────────

export type TransitionTrigger =
  | "session_start"     // App opened / WebSocket connected
  | "presence_change"   // Presence engine detected state change
  | "task_started"      // Founder started a task
  | "task_completed"    // Founder completed a task
  | "capture_created"   // Founder captured a thought
  | "meeting_started"   // Meeting detected
  | "meeting_ended"     // Meeting ended
  | "end_of_day"        // Time-based: after 18:00
  | "session_end"       // App closed / WebSocket disconnected
  | "manual";           // Explicit founder action

// ─── Transition Rules ────────────────────────────────────

export interface ModeTransition {
  from: FounderMode;
  to: FounderMode;
  trigger: TransitionTrigger;
  guard: (context: TransitionContext) => boolean;
  action?: (context: TransitionContext) => TransitionAction;
}

export interface TransitionContext {
  currentMode: FounderMode;
  trigger: TransitionTrigger;
  presence: PresenceState;
  currentHour: number;
  activeTasks: number;
  pendingTasks: number;
  completedTasksToday: number;
  timeSinceLastMutation: number;
  timeInCurrentMode: number;
}

export interface TransitionAction {
  type: string;
  payload: Record<string, unknown>;
  evidence: string;
}

// ─── Evidence ────────────────────────────────────────────

export interface FounderModeEvidence {
  timestamp: number;
  previousMode: FounderMode;
  newMode: FounderMode;
  trigger: TransitionTrigger;
  action?: TransitionAction;
  duration: number;
  reason: string;
}

// ─── Day Metrics ─────────────────────────────────────────

export interface DayMetrics {
  date: string;
  modes: Record<FounderMode, number>; // Time spent in each mode (ms)
  transitions: FounderModeEvidence[];
  tasksStarted: number;
  tasksCompleted: number;
  capturesCreated: number;
  meetingsAttended: number;
  reflectionTime: number;
  workTime: number;
  recoveryTime: number;
}

// ─── Transition Graph ────────────────────────────────────

const TRANSITIONS: ModeTransition[] = [
  // Session start -> morning or resume
  {
    from: "shutdown",
    to: "morning",
    trigger: "session_start",
    guard: (ctx) => ctx.currentHour < 12 && ctx.completedTasksToday === 0,
    action: () => ({
      type: "load_context",
      payload: {},
      evidence: "Loading morning context",
    }),
  },
  {
    from: "shutdown",
    to: "resume",
    trigger: "session_start",
    guard: (ctx) => ctx.completedTasksToday > 0 || ctx.timeSinceLastMutation < 86400000,
    action: () => ({
      type: "load_context",
      payload: {},
      evidence: "Resuming from previous session",
    }),
  },

  // Morning -> work (first task started)
  {
    from: "morning",
    to: "work",
    trigger: "task_started",
    guard: () => true,
    action: () => ({
      type: "start_work",
      payload: {},
      evidence: "First task started",
    }),
  },

  // Resume -> work (task resumed)
  {
    from: "resume",
    to: "work",
    trigger: "task_started",
    guard: () => true,
    action: () => ({
      type: "resume_work",
      payload: {},
      evidence: "Task resumed",
    }),
  },

  // Work -> meeting (meeting detected)
  {
    from: "work",
    to: "meeting",
    trigger: "meeting_started",
    guard: () => true,
    action: () => ({
      type: "enter_meeting",
      payload: {},
      evidence: "Meeting started",
    }),
  },

  // Meeting -> recovery (meeting ended)
  {
    from: "meeting",
    to: "recovery",
    trigger: "meeting_ended",
    guard: () => true,
    action: () => ({
      type: "exit_meeting",
      payload: {},
      evidence: "Meeting ended, entering recovery",
    }),
  },

  // Recovery -> work (task resumed after meeting)
  {
    from: "recovery",
    to: "work",
    trigger: "task_started",
    guard: () => true,
    action: () => ({
      type: "resume_after_meeting",
      payload: {},
      evidence: "Resuming work after meeting",
    }),
  },

  // Work -> capture (quick capture)
  {
    from: "work",
    to: "capture",
    trigger: "capture_created",
    guard: () => true,
    action: () => ({
      type: "quick_capture",
      payload: {},
      evidence: "Thought captured",
    }),
  },

  // Capture -> work (back to work)
  {
    from: "capture",
    to: "work",
    trigger: "task_started",
    guard: () => true,
    action: () => ({
      type: "return_from_capture",
      payload: {},
      evidence: "Returning to work after capture",
    }),
  },

  // Work -> reflection (end of day)
  {
    from: "work",
    to: "reflection",
    trigger: "end_of_day",
    guard: (ctx) => ctx.currentHour >= 18 && ctx.completedTasksToday > 0,
    action: () => ({
      type: "start_reflection",
      payload: {},
      evidence: "End of day, starting reflection",
    }),
  },

  // Reflection -> shutdown
  {
    from: "reflection",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },

  // Any -> shutdown (session end)
  {
    from: "morning",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },
  {
    from: "resume",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },
  {
    from: "work",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },
  {
    from: "capture",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },
  {
    from: "meeting",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },
  {
    from: "recovery",
    to: "shutdown",
    trigger: "session_end",
    guard: () => true,
    action: () => ({
      type: "shutdown",
      payload: {},
      evidence: "Session ending",
    }),
  },

  // Any -> meeting (meeting detected from any state)
  {
    from: "morning",
    to: "meeting",
    trigger: "meeting_started",
    guard: () => true,
    action: () => ({
      type: "enter_meeting",
      payload: {},
      evidence: "Meeting started during morning",
    }),
  },
  {
    from: "resume",
    to: "meeting",
    trigger: "meeting_started",
    guard: () => true,
    action: () => ({
      type: "enter_meeting",
      payload: {},
      evidence: "Meeting started during resume",
    }),
  },
  {
    from: "capture",
    to: "meeting",
    trigger: "meeting_started",
    guard: () => true,
    action: () => ({
      type: "enter_meeting",
      payload: {},
      evidence: "Meeting started during capture",
    }),
  },
  {
    from: "recovery",
    to: "meeting",
    trigger: "meeting_started",
    guard: () => true,
    action: () => ({
      type: "enter_meeting",
      payload: {},
      evidence: "Meeting started during recovery",
    }),
  },
];

// ─── Engine ──────────────────────────────────────────────

export interface FounderModeResult {
  mode: FounderMode;
  previousMode: FounderMode | null;
  changed: boolean;
  action?: TransitionAction;
  evidence?: FounderModeEvidence;
  dayMetrics: DayMetrics;
}

/**
 * Compute founder mode from context.
 * Returns the new mode and whether it changed.
 */
export function computeFounderMode(
  context: TransitionContext,
  currentMode: FounderMode = "shutdown",
  dayMetrics?: DayMetrics
): FounderModeResult {
  const now = Date.now();
  const today = new Date().toISOString().split("T")[0]!;

  const metrics: DayMetrics = dayMetrics ?? {
    date: today,
    modes: {
      morning: 0, resume: 0, work: 0, meeting: 0,
      capture: 0, recovery: 0, reflection: 0, shutdown: 0,
    },
    transitions: [],
    tasksStarted: 0,
    tasksCompleted: 0,
    capturesCreated: 0,
    meetingsAttended: 0,
    reflectionTime: 0,
    workTime: 0,
    recoveryTime: 0,
  };

  // Try transition rules
  for (const transition of TRANSITIONS) {
    if (transition.from === currentMode && transition.trigger === context.trigger) {
      if (transition.guard(context)) {
        const newMode = transition.to;
        const action = transition.action?.(context);

        // Update time in previous mode
        metrics.modes[currentMode] += context.timeInCurrentMode;

        // Update mode-specific counters
        if (newMode === "meeting") metrics.meetingsAttended++;
        if (newMode === "work") metrics.workTime += context.timeInCurrentMode;
        if (newMode === "recovery") metrics.recoveryTime += context.timeInCurrentMode;
        if (newMode === "reflection") metrics.reflectionTime += context.timeInCurrentMode;
        if (context.trigger === "task_started") metrics.tasksStarted++;
        if (context.trigger === "task_completed") metrics.tasksCompleted++;
        if (context.trigger === "capture_created") metrics.capturesCreated++;

        const evidence: FounderModeEvidence = {
          timestamp: now,
          previousMode: currentMode,
          newMode,
          trigger: context.trigger,
          action,
          duration: context.timeInCurrentMode,
          reason: action?.evidence ?? `Transitioned from ${currentMode} to ${newMode}`,
        };

        metrics.transitions.push(evidence);

        return {
          mode: newMode,
          previousMode: currentMode,
          changed: true,
          action,
          evidence,
          dayMetrics: metrics,
        };
      }
    }
  }

  // No transition matched — stay in current mode
  metrics.modes[currentMode] += context.timeInCurrentMode;

  return {
    mode: currentMode,
    previousMode: currentMode,
    changed: false,
    dayMetrics: metrics,
  };
}

/**
 * Extract founder mode context from Runtime state.
 */
export function extractFounderModeContext(
  state: HumanStateVector,
  trigger: TransitionTrigger,
  presence: PresenceState,
  timeInCurrentMode: number
): TransitionContext {
  const data = state.data as any;
  const now = Date.now();

  const tasks = Object.values(data.execution?.tasks ?? {}) as any[];
  const activeTasks = tasks.filter(t => t.status === "in_progress").length;
  const pendingTasks = tasks.filter(t => t.status === "pending").length;

  const today = new Date().toISOString().split("T")[0];
  const completedTasksToday = tasks.filter(
    t => t.status === "completed" && t.completedAt?.startsWith(today)
  ).length;

  return {
    currentMode: (data.founderMode?.mode ?? "shutdown") as FounderMode,
    trigger,
    presence,
    currentHour: new Date().getHours(),
    activeTasks,
    pendingTasks,
    completedTasksToday,
    timeSinceLastMutation: now - state.timestamp,
    timeInCurrentMode,
  };
}
