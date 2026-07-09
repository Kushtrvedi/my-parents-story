import { HumanRuntime } from "@reyou/human-runtime";
import { Scheduler } from "@reyou/scheduler";
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

// ─── Persistence ────────────────────────────────────────

const REYOU_DIR = join(homedir(), ".reyou");
const STATE_FILE = join(REYOU_DIR, "state.json");

export interface PersistedState {
  version: number;
  timestamp: number;
  data: Record<string, unknown>;
  savedAt: string;
}

export function loadPersistedState(): PersistedState | null {
  try {
    if (existsSync(STATE_FILE)) {
      const raw = readFileSync(STATE_FILE, "utf-8");
      return JSON.parse(raw);
    }
  } catch {
    // Corrupted state — start fresh
  }
  return null;
}

export function savePersistedState(state: { version: number; timestamp: number; data: Record<string, unknown> }): void {
  if (!existsSync(REYOU_DIR)) {
    mkdirSync(REYOU_DIR, { recursive: true });
  }
  const persisted: PersistedState = {
    ...state,
    savedAt: new Date().toISOString(),
  };
  writeFileSync(STATE_FILE, JSON.stringify(persisted, null, 2), "utf-8");
}

export async function hydrateFromDisk(): Promise<boolean> {
  const persisted = loadPersistedState();
  if (persisted) {
    await humanRuntime.mutate(() => ({ version: persisted.version, timestamp: persisted.timestamp, data: persisted.data }));
    return true;
  }
  return false;
}

export function persistToDisk(): void {
  const state = humanRuntime.getState();
  savePersistedState(state);
}

export function getStatePath(): string {
  return STATE_FILE;
}

// ─── Singleton Instances ────────────────────────────────

export const humanRuntime = new HumanRuntime();
export const scheduler = new Scheduler();

// ─── State Access ───────────────────────────────────────

/** Get the current state vector. */
export const getState = () => humanRuntime.getState();

/** Take a snapshot of the current state. */
export const snapshot = () => humanRuntime.snapshot();

/** Restore state from a snapshot (requires explicit call). */
export const restore = (snap: Parameters<typeof humanRuntime.restore>[0]) =>
  humanRuntime.restore(snap);

/** Reset the runtime state and history back to default. */
export const reset = (initial?: Parameters<typeof humanRuntime.reset>[0]) =>
  humanRuntime.reset(initial);

// ─── Mutations ──────────────────────────────────────────

/** Apply an atomic mutation to the state. */
export const mutate = (mutator: Parameters<typeof humanRuntime.mutate>[0]) =>
  humanRuntime.mutate(mutator);

// ─── Subscriptions ──────────────────────────────────────

/** Subscribe to runtime events. */
export const subscribe = (eventType: string, handler: Parameters<typeof humanRuntime.subscribe>[1]) =>
  humanRuntime.subscribe(eventType, handler);

// ─── Transactions ───────────────────────────────────────

/** Begin a new transaction with snapshot isolation. */
export const beginTransaction = () => humanRuntime.beginTransaction();

/** Commit a transaction, optionally applying a mutation. */
export const commitTransaction = (
  transactionId: string,
  mutator?: Parameters<typeof humanRuntime.commitTransaction>[1],
) => humanRuntime.commitTransaction(transactionId, mutator);

/** Roll back a transaction. */
export const rollbackTransaction = (transactionId: string) =>
  humanRuntime.rollbackTransaction(transactionId);

/** Get isolated state for a transaction. */
export const getTransactionState = (transactionId: string) =>
  humanRuntime.getTransactionState(transactionId);

// ─── Version Management ─────────────────────────────────

/** Get version history. */
export const getVersionHistory = () => humanRuntime.getVersionHistory();

/** Get a specific version. */
export const getVersion = (version: number) => humanRuntime.getVersion(version);

/** Rollback to a specific version. */
export const rollbackToVersion = (version: number) => humanRuntime.rollbackToVersion(version);

/** Trim version history. */
export const trimHistory = (keepLast: number) => humanRuntime.trimHistory(keepLast);

// ─── Scheduling ─────────────────────────────────────────

/** Schedule a function with priority. */
export const schedule = (fn: () => void | Promise<void>, priority = 0) => scheduler.schedule(fn, priority);

// ─── Metrics & Health ───────────────────────────────────

/** Get runtime metrics. */
export const getMetrics = () => humanRuntime.getMetrics();

/** Health check. */
export const health = () => humanRuntime.health();

// ─── Event Publishing ──────────────────────────────────

/** Publish a typed event to the runtime event bus. */
export const publishEvent = <T = unknown>(
  type: string,
  payload: T,
  options?: { correlationId?: string; causationId?: string }
) => humanRuntime.publish(type, payload, options);
