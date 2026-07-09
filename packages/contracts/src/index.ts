// ─── Lifecycle ──────────────────────────────────────────────────
export interface LifecycleState {
  phase: "init" | "booting" | "running" | "shutting_down" | "stopped" | "crashed";
  startedAt: number | null;
  uptimeMs: number;
}

export type LifecycleHook = "pre-init" | "post-init" | "pre-boot" | "post-boot" | "pre-shutdown" | "post-shutdown" | "crash";

export interface LifecycleHookHandler {
  hook: LifecycleHook;
  priority: number;
  handler: () => Promise<void>;
}

// ─── Service Registry ────────────────────────────────────────────
export interface ServiceDescriptor {
  name: string;
  version: string;
  dependencies: string[];
  status: "registered" | "initializing" | "ready" | "degraded" | "failed";
}

export interface ServiceRegistration {
  name: string;
  version: string;
  dependencies: string[];
  factory: () => Promise<unknown>;
  singleton?: boolean;
}

// ─── Dependency Injection ────────────────────────────────────────
export type Token<T> = string & { __type: T };

export interface Binding<T> {
  token: Token<T>;
  factory: () => T | Promise<T>;
  singleton: boolean;
  instance?: T;
}

// ─── Events ──────────────────────────────────────────────────────
export type EventId = string;
export type EventTimestamp = number;

export interface Event<TPayload = unknown> {
  id: EventId;
  type: string;
  payload: TPayload;
  timestamp: EventTimestamp;
  correlationId: string;
  causationId?: string;
}

export type EventHandler<T = unknown> = (event: Event<T>) => void | Promise<void>;

export interface EventSubscription {
  id: string;
  eventType: string;
  handler: EventHandler;
  filter?: (event: Event) => boolean;
}

// ─── Configuration ───────────────────────────────────────────────
export type ConfigValue = string | number | boolean | null | ConfigValue[] | { [key: string]: ConfigValue };

export interface ConfigSchema {
  [key: string]: {
    type: "string" | "number" | "boolean" | "array" | "object";
    required: boolean;
    default?: ConfigValue;
    description?: string;
  };
}

export interface ConfigReader {
  get<T extends ConfigValue>(key: string): T | undefined;
  getOrThrow<T extends ConfigValue>(key: string): T;
  has(key: string): boolean;
  all(): Record<string, ConfigValue>;
}

// ─── Logging ─────────────────────────────────────────────────────
export type LogLevel = "debug" | "info" | "warn" | "error" | "fatal";

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  requestId?: string;
  correlationId?: string;
  metadata?: Record<string, unknown>;
  error?: { message: string; stack?: string; code?: string };
}

export interface Logger {
  debug(message: string, meta?: Record<string, unknown>): void;
  info(message: string, meta?: Record<string, unknown>): void;
  warn(message: string, meta?: Record<string, unknown>): void;
  error(message: string, meta?: Record<string, unknown>): void;
  fatal(message: string, meta?: Record<string, unknown>): void;
  child(context: Record<string, unknown>): Logger;
}

// ─── Errors ──────────────────────────────────────────────────────
export type ErrorCategory = "validation" | "runtime" | "recoverable" | "fatal" | "retryable" | "configuration" | "security";

export interface RuntimeError {
  code: string;
  category: ErrorCategory;
  message: string;
  metadata?: Record<string, unknown>;
  timestamp: number;
  cause?: Error;
}

// ─── Storage ─────────────────────────────────────────────────────
export interface StorageAdapter {
  name: string;
  connect(): Promise<void>;
  disconnect(): Promise<void>;
  get<T>(key: string): Promise<T | null>;
  set<T>(key: string, value: T): Promise<void>;
  delete(key: string): Promise<void>;
  list(prefix: string): Promise<string[]>;
  isConnected(): boolean;
}

// ─── Security ────────────────────────────────────────────────────
export interface SecretManager {
  get(key: string): Promise<string | null>;
  set(key: string, value: string): Promise<void>;
  delete(key: string): Promise<void>;
  rotate(key: string): Promise<string>;
}

export interface Permission {
  action: string;
  resource: string;
  context?: Record<string, unknown>;
}

export interface AuthToken {
  subject: string;
  roles: string[];
  issuedAt: number;
  expiresAt: number;
  metadata?: Record<string, unknown>;
}

// ─── Health ──────────────────────────────────────────────────────
export interface HealthCheck {
  name: string;
  check(): Promise<HealthStatus>;
}

export interface HealthStatus {
  healthy: boolean;
  message?: string;
  metadata?: Record<string, unknown>;
  timestamp: number;
}

export interface RuntimeHealth {
  status: "healthy" | "degraded" | "unhealthy";
  uptime: number;
  services: Record<string, HealthStatus>;
  checks: HealthStatus[];
}

// ─── Telemetry ───────────────────────────────────────────────────
export interface Metric {
  name: string;
  value: number;
  tags?: Record<string, string>;
  timestamp: number;
}

export interface Span {
  id: string;
  parentId?: string;
  name: string;
  startTime: number;
  endTime?: number;
  status: "ok" | "error";
  metadata?: Record<string, unknown>;
}

// ─── Testing ─────────────────────────────────────────────────────
export interface MockContract<T> {
  readonly actual: T;
  setup(behavior: Partial<T>): void;
  verify(): void;
  reset(): void;
}
