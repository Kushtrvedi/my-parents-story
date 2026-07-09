import express from "express";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import rateLimit from "express-rate-limit";
import { WebSocketServer, WebSocket } from "ws";
import { createServer } from "http";
import { randomUUID } from "crypto";
import { getState, mutate, subscribe, health, getMetrics, hydrateFromDisk } from "@reyou/runtime-api";
import type { HumanStateVector } from "@reyou/human-runtime";
import { computePresence, extractSignals, type PresenceState } from "@reyou/presence-engine";
import { computeFounderMode, extractFounderModeContext, type FounderMode, type TransitionTrigger } from "@reyou/founder-mode";
import { EvidenceRuntime } from "@reyou/evidence-runtime";
import { calculateBurdenFromState, recordBurdenTrend } from "@reyou/burden-engine";
import { ProductIntelligence } from "@reyou/product-intelligence";
import { ExperienceRuntime } from "@reyou/experience-runtime";

// ─── Initialize Runtime ───────────────────────────────────

await hydrateFromDisk();

// ─── Observability ────────────────────────────────────────

const serverStartTime = Date.now();
let requestCount = 0;
let errorCount = 0;
let wsClientCount = 0;

interface RequestMetrics {
  id: string;
  method: string;
  path: string;
  status: number;
  duration: number;
  timestamp: number;
}

const recentRequests: RequestMetrics[] = [];
const MAX_RECENT_REQUESTS = 100;

// ─── Evidence Runtime ────────────────────────────────────

const evidenceRuntime = new EvidenceRuntime();

// ─── Product Intelligence ────────────────────────────────

const experienceRuntime = new ExperienceRuntime();
const productIntelligence = new ProductIntelligence(experienceRuntime);
productIntelligence.setStateAccessor(getState);

// ─── State Selectors ──────────────────────────────────────

function selectDreams(state: HumanStateVector) {
  return Object.values((state.data as any).dreams ?? {});
}

function selectEmotions(state: HumanStateVector) {
  return Object.values((state.data as any).emotion?.observations ?? {});
}

function selectBehaviors(state: HumanStateVector) {
  const b = (state.data as any).behavior ?? {};
  return { events: Object.values(b.events ?? {}), attention: Object.values(b.attention ?? {}) };
}

function selectOpportunities(state: HumanStateVector) {
  return Object.values((state.data as any).opportunity?.opportunities ?? {});
}

function selectExecution(state: HumanStateVector) {
  const e = (state.data as any).execution ?? {};
  return {
    projects: Object.values(e.projects ?? {}),
    tasks: Object.values(e.tasks ?? {}),
    active: e.execution ?? {},
  };
}

function selectIdentity(state: HumanStateVector) {
  const id = (state.data as any).identity ?? {};
  return { traits: id.traits ?? {}, beliefs: id.beliefs ?? {}, version: id.version ?? 0 };
}

function selectLearning(state: HumanStateVector) {
  return Object.values((state.data as any).learning?.skills ?? {});
}

function selectKnowledge(state: HumanStateVector) {
  const k = (state.data as any).knowledge ?? {};
  return { nodes: Object.values(k.nodes ?? {}), edges: k.edges ?? {} };
}

function selectReflection(state: HumanStateVector) {
  return { insights: (state.data as any).reflection?.insights ?? [] };
}

function selectConversations(state: HumanStateVector) {
  return Object.values((state.data as any).conversation?.sessions ?? {});
}

// ─── Express App ──────────────────────────────────────────

const app = express();

// Trust proxy (Railway, Vercel, etc.)
app.set("trust proxy", 1);

// Security
app.use(helmet() as any);

// Compression
app.use(compression());

// CORS
app.use(cors({
  origin: [
    "https://reyou-os-dashboard.vercel.app",
    "http://localhost:5173",
    "http://localhost:3000",
  ],
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization", "X-Request-ID"],
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later" },
});
app.use("/api", limiter);

// Body parsing
app.use(express.json({ limit: "1mb" }));

// Request ID + timing middleware
app.use((req, res, next) => {
  const requestId = req.headers["x-request-id"] as string || randomUUID();
  const start = Date.now();
  requestCount++;

  res.setHeader("X-Request-ID", requestId);
  res.setHeader("X-Powered-By", "RE-YOU OS");

  const originalEnd = res.end;
  res.end = function (this: any, ...args: any[]) {
    const duration = Date.now() - start;
    const metrics: RequestMetrics = {
      id: requestId,
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration,
      timestamp: Date.now(),
    };

    recentRequests.unshift(metrics);
    if (recentRequests.length > MAX_RECENT_REQUESTS) {
      recentRequests.pop();
    }

    if (res.statusCode >= 400) {
      errorCount++;
    }

    res.setHeader("X-Response-Time", `${duration}ms`);
    return originalEnd.apply(res, args as any);
  } as any;

  next();
});

// ─── Root ────────────────────────────────────────────────

app.get("/", (_req, res) => {
  res.json({
    name: "RE-YOU OS Runtime Gateway",
    version: "0.1.0",
    dashboard: "https://reyou-os-dashboard.vercel.app",
    docs: "/api/docs",
    openapi: "/api/openapi.json",
    api: {
      health: "/api/health",
      state: "/api/state",
      dreams: "/api/dreams",
      emotions: "/api/emotions",
      behaviors: "/api/behaviors",
      opportunities: "/api/opportunities",
      execution: "/api/execution",
      identity: "/api/identity",
      learning: "/api/learning",
      knowledge: "/api/knowledge",
      reflection: "/api/reflection",
      conversations: "/api/conversations",
      continuity: "/api/continuity",
      burden: "/api/burden",
      decisions: "/api/decisions",
      evidence: "/api/evidence",
      metrics: "/api/metrics",
      websocket: "/ws",
    },
  });
});

// ─── Health ───────────────────────────────────────────────

app.get("/api/health", (_req, res) => {
  const h = health();
  const m = getMetrics();
  const mem = process.memoryUsage();
  res.json({
    ...h,
    metrics: m,
    observability: {
      uptime: Math.floor((Date.now() - serverStartTime) / 1000),
      requests: requestCount,
      errors: errorCount,
      websocketClients: wsClientCount,
      memory: {
        rss: Math.round(mem.rss / 1024 / 1024),
        heapUsed: Math.round(mem.heapUsed / 1024 / 1024),
        heapTotal: Math.round(mem.heapTotal / 1024 / 1024),
      },
      recentRequests: recentRequests.slice(0, 10),
    },
  });
});

// ─── Full State ───────────────────────────────────────────

app.get("/api/state", (_req, res) => {
  res.json(getState());
});

// ─── Dreams ───────────────────────────────────────────────

app.get("/api/dreams", (_req, res) => {
  res.json(selectDreams(getState()));
});

// ─── Emotions ─────────────────────────────────────────────

app.get("/api/emotions", (_req, res) => {
  res.json(selectEmotions(getState()));
});

// ─── Behaviors ────────────────────────────────────────────

app.get("/api/behaviors", (_req, res) => {
  res.json(selectBehaviors(getState()));
});

// ─── Opportunities ────────────────────────────────────────

app.get("/api/opportunities", (_req, res) => {
  res.json(selectOpportunities(getState()));
});

// ─── Execution ────────────────────────────────────────────

app.get("/api/execution", (_req, res) => {
  res.json(selectExecution(getState()));
});

// ─── Identity ─────────────────────────────────────────────

app.get("/api/identity", (_req, res) => {
  res.json(selectIdentity(getState()));
});

// ─── Learning ─────────────────────────────────────────────

app.get("/api/learning", (_req, res) => {
  res.json(selectLearning(getState()));
});

// ─── Knowledge ────────────────────────────────────────────

app.get("/api/knowledge", (_req, res) => {
  res.json(selectKnowledge(getState()));
});

// ─── Reflection ───────────────────────────────────────────

app.get("/api/reflection", (_req, res) => {
  res.json(selectReflection(getState()));
});

// ─── Conversations ────────────────────────────────────────

app.get("/api/conversations", (_req, res) => {
  res.json(selectConversations(getState()));
});

// ─── Presence Engine ────────────────────────────────────

let lastPresenceState: PresenceState = "offline";
let lastPresenceTimestamp = Date.now();
let lastFounderMode: FounderMode = "shutdown";
let lastFounderModeTimestamp = Date.now();
let founderModeDayMetrics: ReturnType<typeof computeFounderMode>["dayMetrics"] | undefined;

app.get("/api/presence", (_req, res) => {
  const state = getState();
  const signals = extractSignals(state, wsClientCount, lastPresenceTimestamp);
  const result = computePresence(signals, lastPresenceState);

  if (result.changed) {
    lastPresenceState = result.state;
    lastPresenceTimestamp = Date.now();
    // Persist presence to runtime state
    mutate((s) => ({
      ...s,
      data: {
        ...s.data,
        presence: {
          state: result.state,
          previousState: result.previousState,
          changedAt: Date.now(),
          evidence: result.evidence,
        },
      },
    }));
    // Record evidence
    evidenceRuntime.record({
      source: "presence-engine",
      action: "PresenceChanged",
      rationale: result.evidence?.reason ?? `Presence changed to ${result.state}`,
      input: { previousState: result.previousState, signals },
      output: { state: result.state },
      confidence: result.evidence?.confidence ?? 0.5,
      category: "observation",
      duration: Date.now() - lastPresenceTimestamp,
      result: "success",
    });
  }

  res.json({
    state: result.state,
    previousState: result.previousState,
    changed: result.changed,
    evidence: result.evidence,
    signals: {
      timeSinceLastMutation: signals.timeSinceLastMutation,
      activeTasks: signals.activeTasks,
      pendingTasks: signals.pendingTasks,
      completedTasksToday: signals.completedTasksToday,
      currentHour: signals.currentHour,
      meetingDetected: signals.meetingDetected,
    },
  });
});

// ─── Founder Mode ────────────────────────────────────────

app.get("/api/founder-mode", (_req, res) => {
  const state = getState();
  const presence = lastPresenceState;
  const timeInCurrentMode = Date.now() - lastFounderModeTimestamp;

  // Map presence changes to founder mode triggers
  let trigger: TransitionTrigger = "presence_change";
  const prevPresence: PresenceState = lastPresenceState;
  if (presence === "meeting") {
    trigger = "meeting_started";
  } else if (prevPresence === "meeting") {
    trigger = "meeting_ended";
  } else if (presence === "returning") {
    trigger = "session_start";
  } else if (presence === "working") {
    trigger = "task_started";
  }

  const context = extractFounderModeContext(state, trigger, presence, timeInCurrentMode);
  const result = computeFounderMode(context, lastFounderMode, founderModeDayMetrics);

  if (result.changed) {
    lastFounderMode = result.mode;
    lastFounderModeTimestamp = Date.now();
    founderModeDayMetrics = result.dayMetrics;

    // Persist founder mode to runtime state
    mutate((s) => ({
      ...s,
      data: {
        ...s.data,
        founderMode: {
          mode: result.mode,
          previousMode: result.previousMode,
          changedAt: Date.now(),
          action: result.action,
          evidence: result.evidence,
          dayMetrics: result.dayMetrics,
        },
      },
    }));
    // Record evidence
    evidenceRuntime.record({
      source: "founder-mode",
      action: "ModeChanged",
      rationale: result.evidence?.reason ?? `Mode changed to ${result.mode}`,
      input: { previousMode: result.previousMode, trigger, presence },
      output: { mode: result.mode, action: result.action },
      confidence: 0.8,
      category: "state-transition",
      duration: timeInCurrentMode,
      result: "success",
    });
  }

  res.json({
    mode: result.mode,
    previousMode: result.previousMode,
    changed: result.changed,
    action: result.action,
    evidence: result.evidence,
    dayMetrics: result.dayMetrics,
  });
});

// ─── Continuity (Founder Wedge) ──────────────────────────

app.get("/api/continuity", (_req, res) => {
  const state = getState();
  const data = state.data as any;

  // Get presence and founder mode state
  const presenceState = data.presence?.state ?? "offline";
  const founderMode = data.founderMode?.mode ?? "shutdown";

  const activeDreams = Object.values(data.dreams ?? {}).filter((d: any) => d.activated);
  const recentEmotions = Object.values(data.emotion?.observations ?? {}).slice(0, 3);
  const activeTasks = Object.values(data.execution?.tasks ?? {}).filter((t: any) => t.status === "in_progress");
  const completedTasks = Object.values(data.execution?.tasks ?? {}).filter((t: any) => t.status === "completed");
  const pendingTasks = Object.values(data.execution?.tasks ?? {}).filter((t: any) => t.status === "pending");
  const projects = Object.values(data.execution?.projects ?? {});
  const skills = Object.values(data.learning?.skills ?? {});
  const opportunities = Object.values(data.opportunity?.opportunities ?? {}).slice(0, 3);

  const lastVersion = state.version;
  const lastTimestamp = state.timestamp;
  const timeSinceLastActive = Date.now() - lastTimestamp;

  // Generate greeting based on presence and time
  let greeting = "";
  if (presenceState === "returning") {
    greeting = "Welcome back. Everything is where you left it.";
  } else if (timeSinceLastActive < 3600000) {
    greeting = "Welcome back. Everything is where you left it.";
  } else if (timeSinceLastActive < 86400000) {
    greeting = "Welcome back. Your state has been preserved.";
  } else {
    greeting = "Welcome back. Nothing has been lost.";
  }

  // Generate narrative: what was I doing?
  let whatWasIDoing = "";
  if (activeTasks.length > 0) {
    const task = activeTasks[0] as any;
    whatWasIDoing = `You were working on "${task.title}"`;
    if (task.description) whatWasIDoing += ` — ${task.description}`;
    whatWasIDoing += ".";
  } else if (pendingTasks.length > 0) {
    whatWasIDoing = `You had ${pendingTasks.length} unfinished task${pendingTasks.length > 1 ? "s" : ""}: "${(pendingTasks[0] as any).title}"`;
    if (pendingTasks.length > 1) whatWasIDoing += ` and ${pendingTasks.length - 1} more`;
    whatWasIDoing += ".";
  } else if (activeDreams.length > 0) {
    whatWasIDoing = `Your aspiration was: "${(activeDreams[0] as any).content}".`;
  } else if (projects.length > 0) {
    whatWasIDoing = `Active project: "${(projects[0] as any).name}".`;
  } else if (completedTasks.length > 0) {
    whatWasIDoing = `You completed ${completedTasks.length} task${completedTasks.length > 1 ? "s" : ""} today.`;
  } else {
    whatWasIDoing = "No active commitments.";
  }

  // Generate context
  let context = "";
  if (activeTasks.length > 0) {
    context = `You were working on ${(activeTasks[0] as any).title}.`;
  } else if (pendingTasks.length > 0) {
    context = `You have ${pendingTasks.length} unfinished task${pendingTasks.length > 1 ? "s" : ""}.`;
  } else if (activeDreams.length > 0) {
    context = `Your aspiration: ${(activeDreams[0] as any).content}.`;
  } else if (projects.length > 0) {
    context = `Active project: ${(projects[0] as any).name}.`;
  } else {
    context = "No active commitments.";
  }

  // Generate recommendation with evidence
  let recommendation = "";
  let recommendationEvidence: string[] = [];
  if (presenceState === "returning" && activeTasks.length > 0) {
    recommendation = `Resume "${(activeTasks[0] as any).title}" — it's in progress.`;
    recommendationEvidence = [`Active task found`, `Task started at ${(activeTasks[0] as any).createdAt}`];
  } else if (activeTasks.length > 0) {
    recommendation = "Continue with your active commitment.";
    recommendationEvidence = [`Active task: ${(activeTasks[0] as any).title}`];
  } else if (pendingTasks.length > 0) {
    recommendation = `Start working on "${(pendingTasks[0] as any).title}".`;
    recommendationEvidence = [`${pendingTasks.length} pending tasks`, `Latest: ${(pendingTasks[0] as any).title}`];
  } else if (opportunities.length > 0) {
    recommendation = "Consider the next opportunity.";
    recommendationEvidence = [`${opportunities.length} opportunities available`];
  } else if (activeDreams.length > 0) {
    recommendation = "Review your aspirations.";
    recommendationEvidence = [`Active aspiration: ${(activeDreams[0] as any).content}`];
  } else {
    recommendation = "Nothing requires your attention.";
    recommendationEvidence = ["No tasks, no dreams, no opportunities"];
  }

  // Gather evidence
  const evidence = [];
  if (activeTasks.length > 0) evidence.push(`Active task: ${(activeTasks[0] as any).title}`);
  if (pendingTasks.length > 0) evidence.push(`${pendingTasks.length} pending tasks`);
  if (completedTasks.length > 0) evidence.push(`${completedTasks.length} tasks completed`);
  if (recentEmotions.length > 0) evidence.push(`Last emotion: ${(recentEmotions[0] as any).observation}`);
  if (timeSinceLastActive < 3600000) evidence.push(`Last active ${Math.round(timeSinceLastActive / 60000)} minutes ago`);
  else if (timeSinceLastActive < 86400000) evidence.push(`Last active ${Math.round(timeSinceLastActive / 3600000)} hours ago`);
  evidence.push(`Presence: ${presenceState}`);
  evidence.push(`Founder mode: ${founderMode}`);

  res.json({
    greeting,
    whatWasIDoing,
    context,
    recommendation,
    recommendationEvidence,
    evidence,
    presence: presenceState,
    founderMode,
    activeDreams: activeDreams.length,
    activeTasks: activeTasks.length,
    pendingTasks: pendingTasks.length,
    completedTasks: completedTasks.length,
    totalProjects: projects.length,
    skillsTracked: skills.length,
    recentObservations: recentEmotions.map((e: any) => e.observation),
    version: lastVersion,
    lastActive: new Date(lastTimestamp).toISOString(),
  });
});

// ─── Metrics ──────────────────────────────────────────────

app.get("/api/metrics", (_req, res) => {
  const state = getState();
  const data = state.data as any;

  const metrics = {
    ...getMetrics(),
    stateVersion: state.version,
    stateTimestamp: new Date(state.timestamp).toISOString(),
    uptimeMs: Date.now() - state.timestamp,
    dreams: Object.keys(data.dreams ?? {}).length,
    emotions: Object.keys(data.emotion?.observations ?? {}).length,
    tasks: Object.keys(data.execution?.tasks ?? {}).length,
    projects: Object.keys(data.execution?.projects ?? {}).length,
    skills: Object.keys(data.learning?.skills ?? {}).length,
    opportunities: Object.keys(data.opportunity?.opportunities ?? {}).length,
    knowledgeNodes: Object.keys(data.knowledge?.nodes ?? {}).length,
    identityTraits: Object.keys(data.identity?.traits ?? {}).length,
  };

  res.json(metrics);
});

// ─── Cognitive Burden ───────────────────────────────────

app.get("/api/burden", (_req, res) => {
  const state = getState();
  const result = calculateBurdenFromState(state);
  const trend = recordBurdenTrend(result);

  res.json({
    ...result,
    trend,
  });
});

// ─── Product Intelligence ────────────────────────────────

app.get("/api/decisions", (_req, res) => {
  const decision = productIntelligence.decide();

  res.json({
    decisions: [{
      decision: decision.action,
      confidence: decision.confidence,
      evidence: decision.evidence,
      reason: decision.reason,
      attentionCost: decision.attentionCost,
      benefit: decision.benefit,
      risk: decision.risk,
    }],
  });
});

// ─── Evidence Trail ──────────────────────────────────────

app.get("/api/evidence", (_req, res) => {
  const state = getState();
  const data = state.data as any;
  const now = Date.now();

  const evidence = [];

  const tasks = Object.values(data.execution?.tasks ?? {});
  for (const task of tasks as any[]) {
    if (task.status === "completed" && task.completedAt) {
      evidence.push({
        action: "TaskCompleted",
        timestamp: task.completedAt,
        source: "execution",
        input: { taskId: task.id, title: task.title },
        output: { status: "completed" },
        confidence: 1.0,
        duration: task.actualDuration ?? null,
        result: "success",
      });
    }
    if (task.status === "in_progress") {
      evidence.push({
        action: "TaskInProgress",
        timestamp: task.updatedAt,
        source: "execution",
        input: { taskId: task.id, title: task.title },
        output: { status: "in_progress" },
        confidence: 1.0,
        duration: null,
        result: "active",
      });
    }
  }

  const emotions = Object.values(data.emotion?.observations ?? []);
  for (const obs of emotions as any[]) {
    evidence.push({
      action: "EmotionObserved",
      timestamp: obs.timestamp,
      source: "emotion",
      input: { observation: obs.observation, confidence: obs.confidence },
      output: { recorded: true },
      confidence: obs.confidence,
      duration: null,
      result: "recorded",
    });
  }

  const dreams = Object.values(data.dreams ?? {});
  for (const dream of dreams as any[]) {
    evidence.push({
      action: "DreamCaptured",
      timestamp: dream.capturedAt,
      source: "dream",
      input: { content: dream.content },
      output: { momentum: dream.momentum, activated: dream.activated },
      confidence: 1.0,
      duration: null,
      result: dream.activated ? "activated" : "dormant",
    });
  }

  // Add evidence from the evidence runtime
  const runtimeEvidence = evidenceRuntime.getAll();
  for (const bundle of runtimeEvidence) {
    evidence.push({
      action: bundle.action,
      timestamp: bundle.timestamp.getTime(),
      source: bundle.source,
      input: bundle.input,
      output: bundle.output,
      confidence: bundle.confidence,
      duration: bundle.duration ?? null,
      result: bundle.result ?? "success",
    });
  }

  evidence.sort((a, b) => b.timestamp - a.timestamp);

  res.json({
    evidence: evidence.slice(0, 50),
    totalEvents: evidence.length,
    chainIntegrity: evidenceRuntime.verifyChain(),
    timespan: evidence.length > 0
      ? { from: new Date(evidence[evidence.length - 1].timestamp).toISOString(), to: new Date(evidence[0].timestamp).toISOString() }
      : null,
  });
});

// ─── OpenAPI Specification ────────────────────────────────

const openApiSpec = {
  openapi: "3.0.3",
  info: {
    title: "RE-YOU OS Runtime API",
    version: "0.1.0",
    description: "Runtime Gateway for RE-YOU OS — cognitive burden engine, product intelligence, and evidence trail.",
  },
  servers: [{ url: "/", description: "Current server" }],
  paths: {
    "/api/health": { get: { summary: "Health check with observability", tags: ["System"], responses: { "200": { description: "Healthy" } } } },
    "/api/state": { get: { summary: "Full runtime state", tags: ["Runtime"], responses: { "200": { description: "State vector" } } } },
    "/api/dreams": { get: { summary: "List dreams/aspirations", tags: ["Runtime"], responses: { "200": { description: "Dream array" } } } },
    "/api/emotions": { get: { summary: "List emotion observations", tags: ["Runtime"], responses: { "200": { description: "Emotion array" } } } },
    "/api/behaviors": { get: { summary: "Behavior events and attention", tags: ["Runtime"], responses: { "200": { description: "Behavior data" } } } },
    "/api/opportunities": { get: { summary: "Opportunities", tags: ["Runtime"], responses: { "200": { description: "Opportunity array" } } } },
    "/api/execution": { get: { summary: "Projects, tasks, and active execution", tags: ["Runtime"], responses: { "200": { description: "Execution state" } } } },
    "/api/identity": { get: { summary: "Identity traits and beliefs", tags: ["Runtime"], responses: { "200": { description: "Identity" } } } },
    "/api/learning": { get: { summary: "Skills and learning", tags: ["Runtime"], responses: { "200": { description: "Skill array" } } } },
    "/api/knowledge": { get: { summary: "Knowledge graph", tags: ["Runtime"], responses: { "200": { description: "Knowledge nodes" } } } },
    "/api/reflection": { get: { summary: "Reflection insights", tags: ["Runtime"], responses: { "200": { description: "Insights" } } } },
    "/api/conversations": { get: { summary: "Conversation sessions", tags: ["Runtime"], responses: { "200": { description: "Session array" } } } },
    "/api/continuity": { get: { summary: "Continuity context for returning founder", tags: ["Intelligence"], responses: { "200": { description: "Continuity data" } } } },
    "/api/presence": { get: { summary: "Founder presence state detection", tags: ["Intelligence"], responses: { "200": { description: "Presence state" } } } },
    "/api/founder-mode": { get: { summary: "Founder mode state machine", tags: ["Intelligence"], responses: { "200": { description: "Founder mode state" } } } },
    "/api/burden": { get: { summary: "Cognitive burden score and recovery", tags: ["Intelligence"], responses: { "200": { description: "Burden metrics" } } } },
    "/api/decisions": { get: { summary: "Product intelligence recommendations", tags: ["Intelligence"], responses: { "200": { description: "Decision array" } } } },
    "/api/evidence": { get: { summary: "Evidence trail of all actions", tags: ["Intelligence"], responses: { "200": { description: "Evidence array" } } } },
    "/api/metrics": { get: { summary: "Runtime metrics summary", tags: ["System"], responses: { "200": { description: "Metrics" } } } },
  },
  components: {
    schemas: {
      Burden: { type: "object", properties: { burdenScore: { type: "number" }, recoveryScore: { type: "number" }, trend: { type: "string", enum: ["low", "moderate", "high"] } } },
      Decision: { type: "object", properties: { decision: { type: "string" }, confidence: { type: "number" }, reason: { type: "string" } } },
      Evidence: { type: "object", properties: { action: { type: "string" }, timestamp: { type: "number" }, source: { type: "string" } } },
    },
  },
};

app.get("/api/openapi.json", (_req, res) => {
  res.json(openApiSpec);
});

app.get("/api/docs", (_req, res) => {
  res.send(`<!DOCTYPE html>
<html><head><title>RE-YOU OS API Docs</title>
<script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
<link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head><body>
<div id="swagger"></div>
<script>SwaggerUIBundle({ url: "/api/openapi.json", dom_id: "#swagger" })</script>
</body></html>`);
});

// ─── HTTP Server + WebSocket ──────────────────────────────

const server = createServer(app);
const wss = new WebSocketServer({ server, path: "/ws" });

function broadcastState() {
  const state = getState();
  const payload = JSON.stringify({ type: "state:update", version: state.version, timestamp: state.timestamp });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(payload);
    }
  });
}

subscribe("HumanStateMutation", () => {
  broadcastState();
});

wss.on("connection", (ws) => {
  wsClientCount++;
  const state = getState();
  ws.send(JSON.stringify({ type: "state:initial", version: state.version, timestamp: state.timestamp }));
  ws.on("close", () => { wsClientCount--; });
});

// ─── Start ────────────────────────────────────────────────

const PORT = process.env.PORT ?? 3001;

server.listen(PORT, () => {
  const runtimeLoaded = getState().version > 0;
  console.log(`  RE-YOU OS Runtime Gateway v0.1.0`);
  console.log(`  http://localhost:${PORT}`);
  console.log(`  ws://localhost:${PORT}/ws`);
  console.log(`  docs: http://localhost:${PORT}/api/docs`);
  console.log(`  health: http://localhost:${PORT}/api/health`);
  console.log(`  runtime: ${runtimeLoaded ? "loaded" : "empty"}`);
  console.log(`  security: helmet + cors + rate-limit + compression`);
  console.log(`  observability: request-id + timing + memory`);
});
