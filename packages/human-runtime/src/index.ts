import { EventBus } from "@reyou/event-bus";
import { createDefaultLogger, RuntimeLogger } from "@reyou/logger";
import type { EventHandler } from "@reyou/contracts";

// ─── Types ──────────────────────────────────────────────

export interface HumanStateVector {
  version: number;
  timestamp: number;
  data: Record<string, unknown>;
}

export type Mutation<T = HumanStateVector> = (state: T) => T | Promise<T>;

export interface Snapshot {
  state: HumanStateVector;
  capturedAt: number;
  version: number;
}

export interface TransactionHandle {
  id: string;
  state: "active" | "committed" | "rolled_back";
  snapshot: HumanStateVector;
}

export interface RuntimeMetrics {
  mutationCount: number;
  transactionCount: number;
  committedTransactions: number;
  rolledBackTransactions: number;
  eventCount: number;
  uptimeMs: number;
  currentVersion: number;
}

// ─── HumanRuntime ───────────────────────────────────────

export class HumanRuntime {
  private state: HumanStateVector;
  private eventBus: EventBus;
  private logger: RuntimeLogger;
  private versionHistory: HumanStateVector[] = [];
  private activeTransactions: Map<string, TransactionHandle> = new Map();
  private metrics = {
    mutationCount: 0,
    transactionCount: 0,
    committedTransactions: 0,
    rolledBackTransactions: 0,
    eventCount: 0,
  };
  private readonly createdAt: number;

  constructor(initial?: Partial<HumanStateVector>) {
    this.createdAt = Date.now();
    this.state = {
      version: 0,
      timestamp: Date.now(),
      data: {},
      ...initial,
    };
    this.eventBus = new EventBus();
    this.logger = createDefaultLogger({ minLevel: "debug", format: "pretty" });
    this.versionHistory.push({ ...this.state });
  }

  /** Current state snapshot (immutable copy). */
  getState(): HumanStateVector {
    return { ...this.state };
  }

  /**
   * Apply an atomic mutation. Bumps version, updates timestamp,
   * records in version history, and emits an event.
   */
  async mutate(mutator: Mutation<HumanStateVector>): Promise<HumanStateVector> {
    const prevVersion = this.state.version;
    const newState = await mutator({ ...this.state });
    this.state = {
      ...newState,
      version: prevVersion + 1,
      timestamp: Date.now(),
    };
    this.versionHistory.push({ ...this.state });
    this.metrics.mutationCount++;
    await this.eventBus.publish(
      "HumanStateMutation",
      { previousVersion: prevVersion, newVersion: this.state.version },
      { correlationId: "HumanRuntime" },
    );
    this.metrics.eventCount++;
    this.logger.debug("HumanRuntime mutated", { prevVersion, newVersion: this.state.version });
    return this.getState();
  }

  /** Subscribe to a specific event type. */
  subscribe<T = unknown>(eventType: string, handler: EventHandler<T>): { unsubscribe: () => void } {
    return this.eventBus.subscribe(eventType, handler);
  }

  /** Publish a typed event to the runtime event bus. */
  async publish<T = unknown>(
    type: string,
    payload: T,
    options?: { correlationId?: string; causationId?: string }
  ): Promise<void> {
    await this.eventBus.publish(type, payload, options);
  }

  /** Capture a snapshot of the full state. */
  snapshot(): Snapshot {
    return {
      state: this.getState(),
      capturedAt: Date.now(),
      version: this.state.version,
    };
  }

  /** Restore state from a snapshot without emitting a mutation event. */
  restore(snapshot: HumanStateVector): void {
    this.state = { ...snapshot };
    this.logger.info("HumanRuntime restored from snapshot", { version: snapshot.version });
  }

  // ─── Transaction Management ──────────────────────────

  /** Begin a new transaction with snapshot isolation. */
  beginTransaction(): TransactionHandle {
    const id = `hr-tx-${++this.metrics.transactionCount}-${Date.now().toString(36)}`;
    const handle: TransactionHandle = {
      id,
      state: "active",
      snapshot: this.getState(),
    };
    this.activeTransactions.set(id, handle);
    this.logger.debug("Transaction started", { transactionId: id });
    return handle;
  }

  /** Commit a transaction, applying any mutations made during it. */
  async commitTransaction(
    transactionId: string,
    mutator?: Mutation<HumanStateVector>,
  ): Promise<HumanStateVector> {
    const handle = this.activeTransactions.get(transactionId);
    if (!handle || handle.state !== "active") {
      throw new Error(`Transaction ${transactionId} is not active`);
    }

    if (mutator) {
      await this.mutate(mutator);
    }

    handle.state = "committed";
    this.activeTransactions.delete(transactionId);
    this.metrics.committedTransactions++;
    this.logger.debug("Transaction committed", { transactionId });
    return this.getState();
  }

  /** Roll back a transaction, discarding any changes. */
  rollbackTransaction(transactionId: string): void {
    const handle = this.activeTransactions.get(transactionId);
    if (!handle) {
      throw new Error(`Transaction ${transactionId} not found`);
    }

    if (handle.state === "active") {
      this.restore(handle.snapshot);
    }

    handle.state = "rolled_back";
    this.activeTransactions.delete(transactionId);
    this.metrics.rolledBackTransactions++;
    this.logger.debug("Transaction rolled back", { transactionId });
  }

  /** Get an isolated read copy for a transaction. */
  getTransactionState(transactionId: string): HumanStateVector | null {
    const handle = this.activeTransactions.get(transactionId);
    if (!handle || handle.state !== "active") return null;
    return { ...handle.snapshot };
  }

  // ─── Version Management ──────────────────────────────

  /** Get the version history. */
  getVersionHistory(): readonly HumanStateVector[] {
    return this.versionHistory;
  }

  /** Get a specific version by number. */
  getVersion(version: number): HumanStateVector | null {
    return this.versionHistory.find((s) => s.version === version) ?? null;
  }

  /** Rollback to a specific version number. */
  async rollbackToVersion(version: number): Promise<HumanStateVector> {
    const target = this.getVersion(version);
    if (!target) {
      throw new Error(`Version ${version} not found in history`);
    }
    this.restore(target);
    this.metrics.mutationCount++;
    await this.eventBus.publish(
      "HumanStateMutation",
      { previousVersion: this.state.version, newVersion: version, type: "rollback" },
      { correlationId: "HumanRuntime" },
    );
    this.metrics.eventCount++;
    this.logger.info("Rolled back to version", { version });
    return this.getState();
  }

  /** Trim version history to keep only the last N versions. */
  trimHistory(keepLast: number): number {
    const before = this.versionHistory.length;
    if (keepLast < this.versionHistory.length) {
      this.versionHistory = this.versionHistory.slice(-keepLast);
    }
    return before - this.versionHistory.length;
  }

  /** Reset the runtime state and history back to default. */
  reset(initial?: Partial<HumanStateVector>): void {
    this.state = {
      version: 0,
      timestamp: Date.now(),
      data: {},
      ...initial,
    };
    this.versionHistory = [{ ...this.state }];
    this.activeTransactions.clear();
    this.metrics = {
      mutationCount: 0,
      transactionCount: 0,
      committedTransactions: 0,
      rolledBackTransactions: 0,
      eventCount: 0,
    };
    this.logger.info("HumanRuntime reset to initial state");
  }

  // ─── Metrics ─────────────────────────────────────────

  /** Get runtime metrics. */
  getMetrics(): RuntimeMetrics {
    return {
      ...this.metrics,
      uptimeMs: Date.now() - this.createdAt,
      currentVersion: this.state.version,
    };
  }

  /** Simple health accessor. */
  health() {
    return {
      status: "healthy" as const,
      uptime: Math.floor((Date.now() - this.state.timestamp) / 1000),
      services: {},
      checks: [],
    };
  }
}
