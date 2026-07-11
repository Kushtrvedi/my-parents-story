import express from "express";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import rateLimit from "express-rate-limit";
import { WebSocketServer, WebSocket } from "ws";
import { createServer } from "http";
import { randomUUID, timingSafeEqual } from "crypto";
import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, copyFileSync, rmSync, statSync, appendFileSync } from "fs";
import { join } from "path";
import { homedir, hostname as osHostname } from "os";
import { getState, mutate, subscribe, health, getMetrics, hydrateFromDisk } from "@reyou/runtime-api";
import type { HumanStateVector } from "@reyou/human-runtime";
import { computePresence, extractSignals, type PresenceState } from "@reyou/presence-engine";
import { computeFounderMode, extractFounderModeContext, type FounderMode, type TransitionTrigger } from "@reyou/founder-mode";
import { EvidenceRuntime } from "@reyou/evidence-runtime";
import { calculateBurdenFromState, recordBurdenTrend } from "@reyou/burden-engine";
import { ProductIntelligence } from "@reyou/product-intelligence";
import { ExperienceRuntime } from "@reyou/experience-runtime";
import {
  computeFounderAnalytics,
  buildTimeline,
  computeContinuityAccuracy,
  computeBurdenCalibration,
  recordBurdenObservation,
  recordExperiment,
  recordExperimentOutcome,
  getExperiments,
  generateDailyDataset,
  saveDailyDataset,
  getDailyDataset,
  listDatasets,
  buildDailySummary,
  buildDogfoodCycle,
} from "@reyou/analytics-engine";

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

// ─── Operational Metrics ────────────────────────────────

interface OpSnapshot {
  timestamp: number;
  latencyP50: number;
  latencyP95: number;
  latencyP99: number;
  errorRate: number;
  rssMb: number;
  heapUsedMb: number;
  heapTotalMb: number;
  wsClients: number;
  runtimeVersion: number;
  requestCount: number;
}

const opMetrics: { snapshots: OpSnapshot[]; perPath: Record<string, number[]> } = {
  snapshots: [],
  perPath: {},
};

const OP_SNAPSHOT_INTERVAL = 60_000;
const MAX_OP_SNAPSHOTS = 1440;

function takeOpSnapshot(): void {
  const mem = process.memoryUsage();
  const latencies = Object.values(opMetrics.perPath).flat();
  const sorted = [...latencies].sort((a, b) => a - b);
  const p50 = sorted.length > 0 ? sorted[Math.floor(sorted.length * 0.5)]! : 0;
  const p95 = sorted.length > 0 ? sorted[Math.floor(sorted.length * 0.95)]! : 0;
  const p99 = sorted.length > 0 ? sorted[Math.floor(sorted.length * 0.99)]! : 0;
  const totalRequests = Object.values(opMetrics.perPath).reduce((s, v) => s + v.length, 0);
  const totalErrors = errorCount;

  opMetrics.snapshots.push({
    timestamp: Date.now(),
    latencyP50: p50,
    latencyP95: p95,
    latencyP99: p99,
    errorRate: totalRequests > 0 ? totalErrors / totalRequests : 0,
    rssMb: Math.round(mem.rss / 1024 / 1024 * 10) / 10,
    heapUsedMb: Math.round(mem.heapUsed / 1024 / 1024 * 10) / 10,
    heapTotalMb: Math.round(mem.heapTotal / 1024 / 1024 * 10) / 10,
    wsClients: wsClientCount,
    runtimeVersion: getState().version,
    requestCount: totalRequests,
  });

  if (opMetrics.snapshots.length > MAX_OP_SNAPSHOTS) {
    opMetrics.snapshots.shift();
  }
}

setInterval(takeOpSnapshot, OP_SNAPSHOT_INTERVAL);

// ─── Evidence Runtime ────────────────────────────────────

const evidenceRuntime = new EvidenceRuntime();

// ─── Product Intelligence ────────────────────────────────

const experienceRuntime = new ExperienceRuntime();
const productIntelligence = new ProductIntelligence(experienceRuntime);
productIntelligence.setStateAccessor(getState);

// ─── Startup Verification ───────────────────────────────

const REYOU_DIR = process.env.REYOU_DATA_DIR || join(homedir(), ".reyou");
const APP_VERSION = process.env.REYOU_VERSION || "0.1.0";
const SERVER_ID = `reyou-${osHostname()}-${Date.now().toString(36)}`;

function verifyEnvironment(): string[] {
  const warnings: string[] = [];
  if (!process.env.REYOU_DATA_DIR) warnings.push("REYOU_DATA_DIR not set, using default");
  if (!existsSync(REYOU_DIR)) warnings.push("Data directory does not exist yet");
  if (!process.env.EVIDENCE_SIGNING_KEY) warnings.push("EVIDENCE_SIGNING_KEY not set, using default dev key");
  return warnings;
}

function verifyStateIntegrity(): string[] {
  const warnings: string[] = [];
  const state = getState();
  if (state.version === 0) warnings.push("Runtime state is empty");
  if (state.data && typeof state.data !== "object") warnings.push("Runtime state data is malformed");
  return warnings;
}

function verifyEvidenceChain(): { valid: boolean; bundles: number; error?: string } {
  try {
    const result = evidenceRuntime.verifyChain();
    return { valid: result.valid, bundles: result.totalBundles, error: result.valid ? undefined : "Chain integrity check failed" };
  } catch (e) {
    return { valid: false, bundles: 0, error: String(e) };
  }
}

const envWarnings = verifyEnvironment();
const integrityWarnings = verifyStateIntegrity();
const allWarnings = [...envWarnings, ...integrityWarnings];

let lastRestartCheck = Date.now();
let serverRestartCount = 0;
try {
  const restartFile = join(REYOU_DIR, ".restart_count");
  if (existsSync(restartFile)) {
    serverRestartCount = parseInt(readFileSync(restartFile, "utf-8").trim(), 10) || 0;
  }
  serverRestartCount++;
  writeFileSync(restartFile, String(serverRestartCount), "utf-8");
} catch { /* persist restart count silently */ }

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
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'none'"],
      scriptSrc: ["'self'", "https://unpkg.com"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://unpkg.com"],
      imgSrc: ["'self'"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      baseUri: ["'none'"],
      formAction: ["'none'"],
    },
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  referrerPolicy: { policy: "no-referrer" },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: true,
  crossOriginResourcePolicy: { policy: "same-origin" },
  noSniff: true,
  xssFilter: true,
} as any) as any);

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

// ─── Rate Limiting (Category-Based) ──────────────────────

const RATE_WINDOW = 60 * 1000;

function makeRateLimiter(windowMs: number, max: number, label: string) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => req.ip ?? req.socket.remoteAddress ?? "unknown",
    message: { error: "Too many requests", retryAfter: Math.ceil(windowMs / 1000), category: label },
  });
}

// Public: health, status, version, docs — generous limits
const publicLimiter = makeRateLimiter(RATE_WINDOW, 200, "public");

// API queries: analytics, evidence, metrics, continuity, burden, decisions
const queryLimiter = makeRateLimiter(RATE_WINDOW, 100, "query");

// Runtime mutations: presence, founder-mode — protect state integrity
const mutationLimiter = makeRateLimiter(RATE_WINDOW, 30, "mutation");

// Operations: backup, audit — administrative endpoints
const opsLimiter = makeRateLimiter(RATE_WINDOW, 10, "operations");

// Analytics writes: dataset/generate, experiments — infrequent
const analyticsWriteLimiter = makeRateLimiter(RATE_WINDOW, 20, "analytics-write");

// Apply category-specific rate limits to route groups
app.use("/api/health", publicLimiter);
app.use("/api/status", publicLimiter);
app.use("/api/version", publicLimiter);
app.use("/api/docs", publicLimiter);
app.use("/api/openapi.json", publicLimiter);
app.use("/api/presence", mutationLimiter);
app.use("/api/founder-mode", mutationLimiter);
app.use("/api/continuity", queryLimiter);
app.use("/api/burden", queryLimiter);
app.use("/api/decisions", queryLimiter);
app.use("/api/evidence", queryLimiter);
app.use("/api/analytics", queryLimiter);
app.use("/api/analytics/dataset/generate", analyticsWriteLimiter);
app.use("/api/analytics/experiments", analyticsWriteLimiter);
app.use("/api/dogfood", analyticsWriteLimiter);
app.use("/api/ops", opsLimiter);
app.use("/api/metrics", queryLimiter);

// Body parsing
app.use(express.json({ limit: "1mb" }));

// ─── Input Validation Middleware ─────────────────────────

function validateContentType(req: express.Request, res: express.Response, next: express.NextFunction): void {
  if (req.method === "POST" || req.method === "PUT" || req.method === "PATCH") {
    const ct = req.headers["content-type"];
    if (!ct || !ct.includes("application/json")) {
      res.status(415).json({ error: "Content-Type must be application/json" });
      return;
    }
  }
  next();
}

function validateJsonBody(req: express.Request, res: express.Response, next: express.NextFunction): void {
  if (req.method === "POST" || req.method === "PUT" || req.method === "PATCH") {
    if (req.body && typeof req.body === "object") {
      const keys = Object.keys(req.body);
      if (keys.length > 50) {
        res.status(400).json({ error: "Request body too large" });
        return;
      }
      // Reject prototype pollution attempts
      for (const key of keys) {
        if (key === "__proto__" || key === "constructor" || key === "prototype") {
          res.status(400).json({ error: "Invalid field name" });
          return;
        }
      }
    }
  }
  next();
}

function validateNoPathTraversal(req: express.Request, res: express.Response, next: express.NextFunction): void {
  const path = req.originalUrl;
  if (path.includes("..") || path.includes("%2e%2e") || path.includes("%2E%2E")) {
    res.status(400).json({ error: "Invalid path" });
    return;
  }
  next();
}

function validateMethod(req: express.Request, res: express.Response, next: express.NextFunction): void {
  const allowed = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"];
  if (!allowed.includes(req.method)) {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }
  next();
}

app.use(validateMethod);
app.use(validateNoPathTraversal);
app.use(validateContentType);
app.use(validateJsonBody);

// Request ID + timing middleware
app.use((req, res, next) => {
  const requestId = req.headers["x-request-id"] as string || randomUUID();
  const start = Date.now();
  requestCount++;

  res.setHeader("X-Request-ID", requestId);
  res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

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

    if (!opMetrics.perPath[req.path]) {
      opMetrics.perPath[req.path] = [];
    }
    opMetrics.perPath[req.path]!.push(duration);

    if (res.statusCode >= 400) {
      errorCount++;
    }

    res.setHeader("X-Response-Time", `${duration}ms`);
    return originalEnd.apply(res, args as any);
  } as any;

  next();
});

// ─── Error Handling ─────────────────────────────────────

function safeHandler(fn: (req: express.Request, res: express.Response) => void | Promise<void>) {
  return async (req: express.Request, res: express.Response) => {
    try {
      await fn(req, res);
    } catch (err) {
      const errId = randomUUID();
      console.error(`[${errId}] ${req.method} ${req.path}:`, err);
      if (!res.headersSent) {
        res.status(500).json({ error: "Internal server error", id: errId });
      }
    }
  };
}

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
      analytics: "/api/analytics",
      timeline: "/api/analytics/timeline",
      "continuity-accuracy": "/api/analytics/continuity-accuracy",
      "burden-calibration": "/api/analytics/burden-calibration",
      dataset: "/api/analytics/dataset/:date",
      datasets: "/api/analytics/datasets",
      summary: "/api/analytics/summary",
      experiments: "/api/analytics/experiments",
      dogfood: "/api/dogfood/run",
      report: "/api/dogfood/report",
      status: "/api/status",
      version: "/api/version",
      runtime: "/api/runtime",
      metrics: "/api/metrics",
      backup: "/api/ops/backup",
      backups: "/api/ops/backups",
      ops: "/api/ops/dashboard/operational",
      errors: "/api/ops/dashboard/errors",
      performance: "/api/ops/dashboard/performance",
      audit: "/api/ops/audit",
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

app.get("/api/presence", safeHandler(async (_req, res) => {
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
}));

// ─── Founder Mode ────────────────────────────────────────

app.get("/api/founder-mode", safeHandler(async (_req, res) => {
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
}));

// ─── Continuity (Founder Wedge) ──────────────────────────

app.get("/api/continuity", safeHandler(async (_req, res) => {
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

  // Record recommendation as evidence for continuity accuracy scoring
  if (recommendation && recommendation !== "Nothing requires your attention.") {
    evidenceRuntime.record({
      source: "continuity",
      action: "RecommendationMade",
      rationale: `Recommendation: ${recommendation}`,
      input: { recommendation, evidence: recommendationEvidence, hasContext: context !== "No active commitments." },
      output: { recommendation, whatWasIDoing, context },
      confidence: recommendationEvidence.length > 1 ? 0.7 : 0.4,
      category: "decision",
    });
  }

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
}));

// ─── Metrics (Operational Only) ──────────────────────────

app.get("/api/metrics", (_req, res) => {
  const mem = process.memoryUsage();
  const last = opMetrics.snapshots[opMetrics.snapshots.length - 1];
  const state = getState();
  const runMetrics = getMetrics();

  res.json({
    version: 1,
    uptime: Math.floor((Date.now() - serverStartTime) / 1000),
    requests: { total: requestCount, errors: errorCount },
    latency: last ? { p50: last.latencyP50, p95: last.latencyP95, p99: last.latencyP99 } : null,
    memory: {
      rssMb: Math.round(mem.rss / 1024 / 1024 * 10) / 10,
      heapUsedMb: Math.round(mem.heapUsed / 1024 / 1024 * 10) / 10,
      heapTotalMb: Math.round(mem.heapTotal / 1024 / 1024 * 10) / 10,
    },
    websocket: { clients: wsClientCount },
    runtime: { version: state.version, mutations: runMetrics.mutationCount, uptimeMs: Date.now() - state.timestamp },
    monitoring: { snapshots: opMetrics.snapshots.length, historyMinutes: Math.floor(opMetrics.snapshots.length / 60) },
  });
});

// ─── Cognitive Burden ───────────────────────────────────

app.get("/api/burden", safeHandler(async (_req, res) => {
  const state = getState();
  const result = calculateBurdenFromState(state);
  const trend = recordBurdenTrend(result);

  // Record burden prediction for calibration tracking
  recordBurdenObservation({
    timestamp: Date.now(),
    predictedBurden: result.burdenScore,
    predictedRecovery: result.recoveryScore,
  });

  // Record evidence
  evidenceRuntime.record({
    source: "burden-engine",
    action: "BurdenRecorded",
    rationale: `Burden score: ${result.burdenScore}, recovery: ${result.recoveryScore}`,
    input: { signalCount: result.explanation.length },
    output: { burdenScore: result.burdenScore, recoveryScore: result.recoveryScore, trend },
    confidence: result.confidence,
    category: "observation",
  });

  res.json({
    ...result,
    trend,
  });
}));

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

app.get("/api/evidence", safeHandler(async (_req, res) => {
  const state = getState();
  const data = state.data as any;

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
}));

// ─── Program G: Founder Analytics ────────────────────────

app.get("/api/analytics", (_req, res) => {
  const state = getState();
  const evidence = evidenceRuntime.getAll();
  const analytics = computeFounderAnalytics(state, evidence);
  res.json(analytics);
});

// ─── Program J: Founder Timeline ─────────────────────────

app.get("/api/analytics/timeline", (_req, res) => {
  const evidence = evidenceRuntime.getAll();
  const timeline = buildTimeline(evidence);
  res.json({ timeline, total: timeline.length });
});

// ─── Program H: Continuity Accuracy ──────────────────────

app.get("/api/analytics/continuity-accuracy", (_req, res) => {
  const evidence = evidenceRuntime.getAll();
  const accuracy = computeContinuityAccuracy(evidence);
  res.json(accuracy);
});

// ─── Program I: Burden Calibration ───────────────────────

app.get("/api/analytics/burden-calibration", (_req, res) => {
  const calibration = computeBurdenCalibration();
  res.json(calibration);
});

// ─── Program L: Scientific Dataset ───────────────────────

app.get("/api/analytics/dataset/:date", (req, res) => {
  const dataset = getDailyDataset(req.params.date!);
  if (!dataset) return res.status(404).json({ error: "Dataset not found for date" });
  res.json(dataset);
});

app.get("/api/analytics/datasets", (_req, res) => {
  const dates = listDatasets();
  res.json({ datasets: dates });
});

app.post("/api/analytics/dataset/generate", (_req, res) => {
  const state = getState();
  const evidence = evidenceRuntime.getAll();
  const date = new Date().toISOString().split("T")[0]!;
  const analytics = computeFounderAnalytics(state, evidence, date);
  const timeline = buildTimeline(evidence);
  const accuracy = computeContinuityAccuracy(evidence);
  const calibration = computeBurdenCalibration();
  const dataset = generateDailyDataset(date, analytics, timeline, accuracy, calibration, state);
  saveDailyDataset(dataset);
  res.json({ dataset, saved: true });
});

// ─── Program M: Daily Summary ───────────────────────────

app.get("/api/analytics/summary", (_req, res) => {
  const state = getState();
  const evidence = evidenceRuntime.getAll();
  const analytics = computeFounderAnalytics(state, evidence);
  const accuracy = computeContinuityAccuracy(evidence);
  const summary = buildDailySummary(analytics, accuracy);
  res.json(summary);
});

// ─── Program K: Self Validation (Experiments) ────────────

app.get("/api/analytics/experiments", (_req, res) => {
  const experiments = getExperiments();
  const classification = experiments.reduce(
    (acc: Record<string, number>, e: { classification?: string | null }) => {
      if (e.classification) acc[e.classification] = (acc[e.classification] ?? 0) + 1;
      return acc;
    },
    {} as Record<string, number>,
  );
  res.json({ experiments, total: experiments.length, classification });
});

app.post("/api/analytics/experiments", (req, res) => {
  const { recommendation, reason, evidence } = req.body;
  if (!recommendation || !reason) {
    return res.status(400).json({ error: "recommendation and reason are required" });
  }
  recordExperiment({
    recommendation,
    reason,
    evidence: evidence ?? [],
    context: { stateVersion: getState().version },
  });
  res.status(201).json({ recorded: true });
});

app.post("/api/analytics/experiments/:id/outcome", (req, res) => {
  const { userAction, userActionResult, classification } = req.body;
  if (!classification || !userAction) {
    return res.status(400).json({ error: "classification and userAction are required" });
  }
  recordExperimentOutcome(req.params.id!, {
    userAction,
    userActionResult: userActionResult ?? "",
    classification,
  });
  res.json({ recorded: true });
});

// ─── Program N: Dogfood Mode ────────────────────────────

app.post("/api/dogfood/run", (_req, res) => {
  const state = getState();
  const evidence = evidenceRuntime.getAll();
  const cycle = buildDogfoodCycle(state, evidence);

  // Save the daily dataset
  const analytics = cycle.endDay.analytics;
  const timeline = buildTimeline(evidence);
  const accuracy = computeContinuityAccuracy(evidence);
  const calibration = computeBurdenCalibration();
  const dataset = generateDailyDataset(analytics.date, analytics, timeline, accuracy, calibration, state);
  saveDailyDataset(dataset);

  res.json(cycle);
});

app.get("/api/dogfood/report", (_req, res) => {
  const state = getState();
  const evidence = evidenceRuntime.getAll();
  const analytics = computeFounderAnalytics(state, evidence);
  const accuracy = computeContinuityAccuracy(evidence);
  const summary = buildDailySummary(analytics, accuracy);
  const calibration = computeBurdenCalibration();
  const experiments = getExperiments();

  const classified = experiments.filter((e: { classification?: string | null }) => e.classification !== null);
  const helpful = classified.filter((e: { classification?: string | null }) => e.classification === "helpful").length;
  const ignored = classified.filter((e: { classification?: string | null }) => e.classification === "ignored").length;
  const wrong = classified.filter((e: { classification?: string | null }) => e.classification === "wrong").length;

  res.json({
    date: analytics.date,
    summary,
    analytics,
    accuracy,
    calibration,
    experiments: {
      total: experiments.length,
      classified: classified.length,
      helpful,
      ignored,
      wrong,
    },
  });
});

// ─── Alpha Operations: Workstream 2 — Status/Version/Runtime ──

app.get("/api/status", (_req, res) => {
  const lastSnapshot = opMetrics.snapshots[opMetrics.snapshots.length - 1];
  res.json({
    status: "operational",
    serverId: SERVER_ID,
    uptime: Math.floor((Date.now() - serverStartTime) / 1000),
    version: APP_VERSION,
    requests: { total: requestCount, errors: errorCount },
    latency: lastSnapshot ? { p50: lastSnapshot.latencyP50, p95: lastSnapshot.latencyP95, p99: lastSnapshot.latencyP99 } : null,
    websocket: { clients: wsClientCount },
    warnings: allWarnings,
    restartCount: serverRestartCount,
  });
});

app.get("/api/version", (_req, res) => {
  res.json({
    app: "RE-YOU OS Runtime Gateway",
    version: APP_VERSION,
    build: process.env.REYOU_BUILD || "dev",
    commit: process.env.REYOU_COMMIT || "unknown",
    node: process.version,
    platform: process.platform,
    arch: process.arch,
    serverId: SERVER_ID,
  });
});

app.get("/api/runtime", (_req, res) => {
  const state = getState();
  const runMetrics = getMetrics();
  const evidenceChain = verifyEvidenceChain();
  const diskFree = (() => { try { const s = statSync(REYOU_DIR); return s.size; } catch { return -1; } })();
  res.json({
    runtime: { version: state.version, timestamp: state.timestamp, uptimeMs: Date.now() - state.timestamp },
    mutations: runMetrics,
    evidence: evidenceChain,
    analytics: { datasets: listDatasets().length, experiments: getExperiments().length },
    dataDir: { path: REYOU_DIR, exists: existsSync(REYOU_DIR), sizeBytes: diskFree },
    warnings: integrityWarnings,
  });
});

// ─── Alpha Operations: Workstream 3+4 — Backup & Recovery ──

const BACKUP_DIR = join(REYOU_DIR, "backups");
const MAX_BACKUPS = 30;

function ensureBackupDir(): void {
  if (!existsSync(BACKUP_DIR)) mkdirSync(BACKUP_DIR, { recursive: true });
}

interface BackupManifest {
  id: string;
  createdAt: string;
  runtimeVersion: number;
  stateFileSize: number;
  evidenceCount: number;
  datasetCount: number;
  integrity: string;
}

function createBackup(): BackupManifest {
  ensureBackupDir();
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const id = `backup-${timestamp}`;
  const backupPath = join(BACKUP_DIR, id);
  mkdirSync(backupPath, { recursive: true });

  // Backup runtime state.json
  const stateFile = join(REYOU_DIR, "state.json");
  let stateFileSize = 0;
  if (existsSync(stateFile)) {
    copyFileSync(stateFile, join(backupPath, "state.json"));
    stateFileSize = statSync(stateFile).size;
  }

  // Backup analytics data
  const analyticsDir = join(REYOU_DIR, "analytics");
  if (existsSync(analyticsDir)) {
    const analyticsBackup = join(backupPath, "analytics");
    mkdirSync(analyticsBackup, { recursive: true });
    for (const f of readdirSync(analyticsDir)) {
      copyFileSync(join(analyticsDir, f), join(analyticsBackup, f));
    }
  }

  const manifest: BackupManifest = {
    id,
    createdAt: new Date().toISOString(),
    runtimeVersion: getState().version,
    stateFileSize,
    evidenceCount: evidenceRuntime.getCount(),
    datasetCount: listDatasets().length,
    integrity: verifyEvidenceChain().valid ? "ok" : "chain_broken",
  };

  writeFileSync(join(backupPath, "manifest.json"), JSON.stringify(manifest, null, 2), "utf-8");
  writeFileSync(join(backupPath, "evidence.json"), JSON.stringify(evidenceRuntime.getAll()), "utf-8");

  // Rotate old backups
  const all = readdirSync(BACKUP_DIR).filter((f) => f.startsWith("backup-")).sort();
  while (all.length > MAX_BACKUPS) {
    const oldest = all.shift()!;
    rmSync(join(BACKUP_DIR, oldest), { recursive: true, force: true });
  }

  return manifest;
}

function verifyBackupIntegrity(backupId: string): { valid: boolean; error?: string } {
  const backupPath = join(BACKUP_DIR, backupId);
  if (!existsSync(backupPath)) return { valid: false, error: "Backup not found" };
  const manifestFile = join(backupPath, "manifest.json");
  if (!existsSync(manifestFile)) return { valid: false, error: "Manifest missing" };
  const stateFile = join(backupPath, "state.json");
  if (!existsSync(stateFile)) return { valid: false, error: "State file missing" };
  try {
    const manifest = JSON.parse(readFileSync(manifestFile, "utf-8")) as BackupManifest;
    const actualSize = statSync(stateFile).size;
    if (actualSize !== manifest.stateFileSize) return { valid: false, error: "State file size mismatch" };
    return { valid: true };
  } catch (e) {
    return { valid: false, error: String(e) };
  }
}

app.post("/api/ops/backup", (_req, res) => {
  const manifest = createBackup();
  res.status(201).json({ backup: manifest });
});

app.get("/api/ops/backups", (_req, res) => {
  ensureBackupDir();
  const backups = readdirSync(BACKUP_DIR).filter((f) => f.startsWith("backup-")).sort().reverse();
  const details = backups.map((id) => {
    const manifestFile = join(BACKUP_DIR, id, "manifest.json");
    try { return JSON.parse(readFileSync(manifestFile, "utf-8")) as BackupManifest; }
    catch { return { id, createdAt: "unknown", runtimeVersion: 0, stateFileSize: 0, evidenceCount: 0, datasetCount: 0, integrity: "unknown" }; }
  });
  res.json({ backups: details, count: details.length });
});

app.post("/api/ops/backups/:id/verify", (req, res) => {
  const result = verifyBackupIntegrity(req.params.id!);
  res.json({ backupId: req.params.id, ...result });
});

// ─── Alpha Operations: Workstream 5 — Observability Dashboards ──

function opsHtmlPage(title: string, body: string): string {
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>${title} — RE-YU Ops</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#0a0a0a;color:#e0e0e0;padding:20px}
h1{font-size:18px;font-weight:600;color:#d4af37;margin-bottom:16px;text-transform:uppercase;letter-spacing:1px}
h2{font-size:14px;color:#888;margin:16px 0 8px;text-transform:uppercase;letter-spacing:0.5px}
.metric{background:#141414;border:1px solid #222;border-radius:6px;padding:12px 16px;margin-bottom:8px}
.metric .label{font-size:11px;color:#666;text-transform:uppercase}
.metric .value{font-size:22px;font-weight:700;color:#fff;margin-top:2px}
.metric .value.warn{color:#f59e0b}.metric .value.err{color:#ef4444}.metric .value.ok{color:#22c55e}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:8px;margin-bottom:16px}
pre{font-size:11px;color:#888;overflow-x:auto;background:#0d0d0d;padding:12px;border-radius:6px;border:1px solid #1a1a1a}
.warning{color:#f59e0b;font-size:12px;padding:8px 12px;background:#1a1500;border-radius:6px;border:1px solid #3a3000;margin-bottom:8px}
table{width:100%;border-collapse:collapse;font-size:12px;margin-bottom:16px}
th{text-align:left;color:#666;padding:6px 8px;border-bottom:1px solid #222;font-size:10px;text-transform:uppercase}
td{padding:6px 8px;border-bottom:1px solid #111;color:#aaa}
td.num{font-family:monospace;text-align:right;color:#fff}
.nav{display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap}
.nav a{color:#888;text-decoration:none;font-size:12px;padding:6px 12px;border:1px solid #222;border-radius:4px}
.nav a:hover{color:#d4af37;border-color:#d4af37}
a{color:#60a5fa}</style></head><body>${body}</body></html>`;
}

app.get("/api/ops/dashboard/operational", (_req, res) => {
  const last = opMetrics.snapshots[opMetrics.snapshots.length - 1];
  const uptime = Math.floor((Date.now() - serverStartTime) / 1000);
  const uptimeStr = `${Math.floor(uptime / 86400)}d ${Math.floor((uptime % 86400) / 3600)}h ${Math.floor((uptime % 3600) / 60)}m`;
  const snapshots = opMetrics.snapshots.slice(-60);
  const latencyChart = snapshots.map((s) => s.latencyP95).join(",");
  const rssChart = snapshots.map((s) => s.rssMb).join(",");

  const body = `<div class="nav">
    <a href="/api/ops/dashboard/operational">Operational</a>
    <a href="/api/ops/dashboard/errors">Errors</a>
    <a href="/api/ops/dashboard/performance">Performance</a>
  </div>
  <h1>Operational Dashboard</h1>
  <p style="font-size:12px;color:#666;margin-bottom:12px">Server: ${SERVER_ID} | Uptime: ${uptimeStr}</p>
  ${allWarnings.map((w) => `<div class="warning">${w}</div>`).join("")}
  <div class="grid">
    <div class="metric"><div class="label">Uptime</div><div class="value">${uptimeStr}</div></div>
    <div class="metric"><div class="label">Requests</div><div class="value">${requestCount}</div></div>
    <div class="metric"><div class="label">Errors</div><div class="value ${errorCount > 0 ? 'warn' : 'ok'}">${errorCount}</div></div>
    <div class="metric"><div class="label">Error Rate</div><div class="value ${(last?.errorRate ?? 0) > 0.05 ? 'err' : 'ok'}">${last ? (last.errorRate * 100).toFixed(1) : '0.0'}%</div></div>
    <div class="metric"><div class="label">P95 Latency</div><div class="value ${(last?.latencyP95 ?? 0) > 500 ? 'warn' : 'ok'}">${last?.latencyP95 ?? 0}ms</div></div>
    <div class="metric"><div class="label">WS Clients</div><div class="value">${wsClientCount}</div></div>
    <div class="metric"><div class="label">Memory RSS</div><div class="value">${last?.rssMb ?? 0} MB</div></div>
    <div class="metric"><div class="label">Heap Used</div><div class="value">${last?.heapUsedMb ?? 0} MB</div></div>
    <div class="metric"><div class="label">Runtime Version</div><div class="value">${getState().version}</div></div>
    <div class="metric"><div class="label">Restarts</div><div class="value">${serverRestartCount}</div></div>
  </div>
  <h2>Latency (P95) — Last 60 min</h2>
  <pre>${latencyChart || "no data"}</pre>
  <h2>Memory RSS — Last 60 min</h2>
  <pre>${rssChart || "no data"}</pre>`;

  res.type("html").send(opsHtmlPage("Operational", body));
});

app.get("/api/ops/dashboard/errors", (_req, res) => {
  const recent = recentRequests.filter((r) => r.status >= 400).slice(0, 50);
  const rows = recent.map((r) =>
    `<tr><td>${r.method}</td><td>${r.path}</td><td class="num" style="color:${r.status >= 500 ? '#ef4444' : '#f59e0b'}">${r.status}</td><td class="num">${r.duration}ms</td><td style="font-size:10px;color:#555">${new Date(r.timestamp).toISOString()}</td></tr>`
  ).join("");

  const body = `<div class="nav">
    <a href="/api/ops/dashboard/operational">Operational</a>
    <a href="/api/ops/dashboard/errors">Errors</a>
    <a href="/api/ops/dashboard/performance">Performance</a>
  </div>
  <h1>Error Dashboard</h1>
  <div class="grid">
    <div class="metric"><div class="label">Total Errors</div><div class="value ${errorCount > 0 ? 'warn' : 'ok'}">${errorCount}</div></div>
    <div class="metric"><div class="label">Error Rate</div><div class="value">${requestCount > 0 ? (errorCount / requestCount * 100).toFixed(2) : '0'}%</div></div>
    <div class="metric"><div class="label">Recent Errors</div><div class="value">${recent.length}</div></div>
  </div>
  <h2>Recent Errors (last 50)</h2>
  <table><thead><tr><th>Method</th><th>Path</th><th>Status</th><th>Duration</th><th>Time</th></tr></thead><tbody>${rows || '<tr><td colspan="5" style="color:#555;text-align:center">No errors</td></tr>'}</tbody></table>`;

  res.type("html").send(opsHtmlPage("Errors", body));
});

app.get("/api/ops/dashboard/performance", (_req, res) => {
  const paths = Object.entries(opMetrics.perPath).sort((a, b) => b[1].length - a[1].length).slice(0, 20);
  const rows = paths.map(([path, latencies]) => {
    const avg = latencies.reduce((s, v) => s + v, 0) / latencies.length;
    const sorted = [...latencies].sort((a, b) => a - b);
    const p95 = sorted[Math.floor(sorted.length * 0.95)] ?? 0;
    return `<tr><td style="font-family:monospace;font-size:11px">${path}</td><td class="num">${latencies.length}</td><td class="num">${Math.round(avg)}ms</td><td class="num">${p95}ms</td></tr>`;
  }).join("");

  const body = `<div class="nav">
    <a href="/api/ops/dashboard/operational">Operational</a>
    <a href="/api/ops/dashboard/errors">Errors</a>
    <a href="/api/ops/dashboard/performance">Performance</a>
  </div>
  <h1>Performance Dashboard</h1>
  <h2>Per-Endpoint Latency</h2>
  <table><thead><tr><th>Path</th><th>Requests</th><th>Avg (ms)</th><th>P95 (ms)</th></tr></thead><tbody>${rows || '<tr><td colspan="4" style="color:#555;text-align:center">No data</td></tr>'}</tbody></table>`;

  res.type("html").send(opsHtmlPage("Performance", body));
});

// ─── Alpha Operations: Workstream 7 — Security ──────────

function auditLog(action: string, detail: string): void {
  const auditFile = join(REYOU_DIR, "audit.log");
  try {
    appendFileSync(auditFile, JSON.stringify({ timestamp: new Date().toISOString(), action, detail, serverId: SERVER_ID }) + "\n", "utf-8");
  } catch { /* fail silently */ }
}

app.get("/api/ops/audit", (_req, res) => {
  const auditFile = join(REYOU_DIR, "audit.log");
  if (!existsSync(auditFile)) return res.json({ entries: [] });
  const lines = readFileSync(auditFile, "utf-8").trim().split("\n").filter(Boolean).reverse().slice(0, 100);
  const entries = lines.map((l) => JSON.parse(l));
  res.json({ entries, total: entries.length });
});

// Audit all mutation endpoints
const AUDITED_ROUTES = ["/api/presence", "/api/founder-mode", "/api/continuity", "/api/burden", "/api/decisions"];
app.use("/api", (req, res, next) => {
  if (AUDITED_ROUTES.includes(req.path)) {
    auditLog("api_call", `${req.method} ${req.path}`);
  }
  next();
});

// ─── Update root route ──────────────────────────────────

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
    "/api/analytics": { get: { summary: "Founder analytics — resume latency, context recovery, burden trend", tags: ["Analytics"], responses: { "200": { description: "Analytics" } } } },
    "/api/analytics/timeline": { get: { summary: "Founder timeline — reconstructed day from evidence", tags: ["Analytics"], responses: { "200": { description: "Timeline" } } } },
    "/api/analytics/continuity-accuracy": { get: { summary: "Continuity accuracy scoring", tags: ["Analytics"], responses: { "200": { description: "Accuracy" } } } },
    "/api/analytics/burden-calibration": { get: { summary: "Burden prediction calibration", tags: ["Analytics"], responses: { "200": { description: "Calibration" } } } },
    "/api/analytics/dataset/{date}": { get: { summary: "Scientific dataset for a date", tags: ["Analytics"], responses: { "200": { description: "Dataset" } } } },
    "/api/analytics/datasets": { get: { summary: "List available dataset dates", tags: ["Analytics"], responses: { "200": { description: "Dates" } } } },
    "/api/analytics/dataset/generate": { post: { summary: "Generate and save today's dataset", tags: ["Analytics"], responses: { "200": { description: "Dataset saved" } } } },
    "/api/analytics/summary": { get: { summary: "Daily summary for founder dashboard", tags: ["Analytics"], responses: { "200": { description: "Summary" } } } },
    "/api/analytics/experiments": { get: { summary: "Self-validation experiments", tags: ["Analytics"], responses: { "200": { description: "Experiments" } } }, post: { summary: "Record a new recommendation experiment", tags: ["Analytics"], responses: { "201": { description: "Recorded" } } } },
    "/api/analytics/experiments/{id}/outcome": { post: { summary: "Record experiment outcome", tags: ["Analytics"], responses: { "200": { description: "Recorded" } } } },
    "/api/dogfood/run": { post: { summary: "Run dogfood daily cycle", tags: ["Dogfood"], responses: { "200": { description: "Cycle result" } } } },
    "/api/dogfood/report": { get: { summary: "Dogfood daily report", tags: ["Dogfood"], responses: { "200": { description: "Report" } } } },
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
const MAX_WS_CLIENTS = 100;
const WS_HEARTBEAT_INTERVAL = 30_000;
const WS_IDLE_TIMEOUT = 120_000;
const WS_MAX_MESSAGE_SIZE = 64 * 1024;

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

// WebSocket heartbeat — detect stale connections
const wsAlive = new Map<WebSocket, boolean>();
const wsLastActivity = new Map<WebSocket, number>();

const heartbeatInterval = setInterval(() => {
  wss.clients.forEach((ws) => {
    if (wsAlive.get(ws) === false) {
      wsLastActivity.delete(ws);
      wsAlive.delete(ws);
      return ws.terminate();
    }
    wsAlive.set(ws, false);
    if (ws.readyState === WebSocket.OPEN) ws.ping();
  });
}, WS_HEARTBEAT_INTERVAL);

wss.on("close", () => { clearInterval(heartbeatInterval); });

wss.on("connection", (ws, req) => {
  // Connection limit
  if (wsClientCount >= MAX_WS_CLIENTS) {
    ws.close(1013, "Too many connections");
    return;
  }

  wsClientCount++;
  wsAlive.set(ws, true);
  wsLastActivity.set(ws, Date.now());

  // Rate limit: reject oversized messages
  ws.on("message", (data, isBinary) => {
    const msgLen = Buffer.isBuffer(data) ? data.length : ArrayBuffer.isView(data) ? data.byteLength : 0;
    if (!isBinary && msgLen > WS_MAX_MESSAGE_SIZE) {
      ws.close(1009, "Message too large");
      return;
    }
    wsLastActivity.set(ws, Date.now());
    // Reject client mutations — WebSocket is read-only for clients
    try {
      const msg = JSON.parse(data.toString());
      if (msg.type === "mutate" || msg.type === "state:set") {
        ws.send(JSON.stringify({ type: "error", error: "Mutations not allowed via WebSocket" }));
        return;
      }
    } catch { /* ignore non-JSON */ }
  });

  ws.on("pong", () => { wsAlive.set(ws, true); });

  const state = getState();
  ws.send(JSON.stringify({ type: "state:initial", version: state.version, timestamp: state.timestamp }));

  ws.on("close", () => {
    wsClientCount--;
    wsAlive.delete(ws);
    wsLastActivity.delete(ws);
  });
});

// Idle timeout — close inactive connections
setInterval(() => {
  const now = Date.now();
  wss.clients.forEach((ws) => {
    const lastActivity = wsLastActivity.get(ws) ?? 0;
    if (now - lastActivity > WS_IDLE_TIMEOUT && ws.readyState === WebSocket.OPEN) {
      ws.close(1000, "Idle timeout");
    }
  });
}, WS_IDLE_TIMEOUT / 2);

// ─── Global Error Handler ───────────────────────────────

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const errId = randomUUID();
  console.error(`[${errId}] Unhandled:`, err.message);
  if (!res.headersSent) {
    res.status(500).json({ error: "Internal server error", id: errId });
  }
});

// ─── Start ────────────────────────────────────────────────

const PORT = process.env.PORT ?? 3001;

server.listen(PORT, () => {
  const runtimeLoaded = getState().version > 0;
  console.log(`  RE-YOU OS Runtime Gateway v${APP_VERSION}`);
  console.log(`  Server ID: ${SERVER_ID}`);
  console.log(`  http://localhost:${PORT}`);
  console.log(`  ws://localhost:${PORT}/ws`);
  console.log(`  docs: http://localhost:${PORT}/api/docs`);
  console.log(`  health: http://localhost:${PORT}/api/health`);
  console.log(`  status: http://localhost:${PORT}/api/status`);
  console.log(`  runtime: ${runtimeLoaded ? "loaded" : "empty"}`);
  console.log(`  restarts: ${serverRestartCount}`);
  console.log(`  warnings: ${allWarnings.length > 0 ? allWarnings.join(", ") : "none"}`);
  console.log(`  security: helmet + cors + rate-limit + compression`);
  console.log(`  observability: request-id + timing + memory + monitoring`);
});
