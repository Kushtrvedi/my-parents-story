import type { Event, EventHandler, EventSubscription } from "@reyou/contracts";
import { internalError, timeoutError } from "@reyou/errors";

// ─── ID Generator ─────────────────────────────────────
function generateId(): string {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}

// ─── Middleware ────────────────────────────────────────
export type EventMiddleware = (
  event: Event,
  next: (event: Event) => Promise<void>
) => Promise<void>;

// ─── Event Bus ─────────────────────────────────────────
export interface EventBusOptions {
  maxListeners?: number;
  asyncTimeoutMs?: number;
  middleware?: EventMiddleware[];
}

const DEFAULT_OPTIONS: EventBusOptions = {
  maxListeners: 100,
  asyncTimeoutMs: 30000,
};

export class EventBus {
  private subscriptions: Map<string, EventSubscription[]> = new Map();
  private middleware: EventMiddleware[];
  private options: EventBusOptions;
  private publishedCount = 0;

  constructor(options?: EventBusOptions) {
    this.options = { ...DEFAULT_OPTIONS, ...options };
    this.middleware = [...(options?.middleware ?? [])];
  }

  // ─── Subscription ───────────────────────────────────
  subscribe<T = unknown>(
    eventType: string,
    handler: EventHandler<T>,
    filter?: (event: Event<T>) => boolean
  ): { unsubscribe: () => void } {
    const existing = this.subscriptions.get(eventType) ?? [];
    if (existing.length >= (this.options.maxListeners ?? 100)) {
      throw internalError(`Max listeners (${this.options.maxListeners}) reached for event: ${eventType}`);
    }

    const sub: EventSubscription = {
      id: generateId(),
      eventType,
      handler: handler as EventHandler,
      filter: filter as ((event: Event) => boolean) | undefined,
    };

    existing.push(sub);
    this.subscriptions.set(eventType, existing);

    return {
      unsubscribe: () => this.unsubscribe(sub.id),
    };
  }

  subscribeOnce<T = unknown>(
    eventType: string,
    handler: EventHandler<T>,
    filter?: (event: Event<T>) => boolean
  ): void {
    const wrapped: EventHandler<T> = async (event) => {
      this.unsubscribe(wrappedId);
      await handler(event);
    };
    const wrappedId = generateId();
    const { unsubscribe } = this.subscribe(eventType, wrapped, filter);
    // Store the unsubscribe id
    void unsubscribe;
  }

  private unsubscribe(id: string): void {
    for (const [type, subs] of this.subscriptions.entries()) {
      const filtered = subs.filter(s => s.id !== id);
      if (filtered.length === 0) {
        this.subscriptions.delete(type);
      } else {
        this.subscriptions.set(type, filtered);
      }
    }
  }

  // ─── Publishing ──────────────────────────────────────
  async publish<T = unknown>(
    type: string,
    payload: T,
    options?: { correlationId?: string; causationId?: string }
  ): Promise<Event<T>> {
    const event: Event<T> = {
      id: generateId(),
      type,
      payload,
      timestamp: Date.now(),
      correlationId: options?.correlationId ?? generateId(),
      causationId: options?.causationId,
    };

    this.publishedCount++;

    const subs = this.subscriptions.get(type) ?? [];
    if (subs.length === 0) return event;

    // Apply middleware chain
    const handlers = subs
      .filter(s => !s.filter || s.filter(event as Event))
      .map(s => s.handler);

    if (this.middleware.length > 0) {
      await this.runMiddleware(event, handlers);
    } else {
      await this.runHandlers(event, handlers);
    }

    return event;
  }

  async publishSync<T = unknown>(
    type: string,
    payload: T,
    options?: { correlationId?: string; causationId?: string }
  ): Promise<Event<T>> {
    const event: Event<T> = {
      id: generateId(),
      type,
      payload,
      timestamp: Date.now(),
      correlationId: options?.correlationId ?? generateId(),
      causationId: options?.causationId,
    };

    this.publishedCount++;

    const subs = this.subscriptions.get(type) ?? [];
    for (const sub of subs) {
      if (!sub.filter || sub.filter(event as Event)) {
        try {
          await sub.handler(event as Event);
        } catch (err) {
          console.error(`[EventBus] Handler ${sub.id} failed:`, err);
        }
      }
    }

    return event;
  }

  private async runMiddleware(event: Event, handlers: Array<EventHandler>): Promise<void> {
    let index = -1;

    const dispatch = async (idx: number): Promise<void> => {
      if (idx === index) throw internalError("next() called multiple times");
      index = idx;

      if (idx < this.middleware.length) {
        await this.middleware[idx]!(event, async (_e) => {
          await dispatch(idx + 1);
        });
      } else {
        await this.runHandlers(event, handlers);
      }
    };

    await dispatch(0);
  }

  private async runHandlers(event: Event, handlers: Array<EventHandler>): Promise<void> {
    const timeoutMs = this.options.asyncTimeoutMs ?? 30000;
    const promises = handlers.map(handler =>
      this.runWithTimeout(handler, event, timeoutMs)
    );
    await Promise.allSettled(promises);
  }

  private async runWithTimeout(
    handler: EventHandler,
    event: Event,
    timeoutMs: number
  ): Promise<void> {
    const result = handler(event);
    if (result instanceof Promise) {
      const timeout = new Promise<void>((_, reject) =>
        setTimeout(() => reject(timeoutError("Event handler timeout")), timeoutMs)
      );
      await Promise.race([result, timeout]);
    }
  }

  // ─── Lifecycle ───────────────────────────────────────
  clear(): void {
    this.subscriptions.clear();
    this.publishedCount = 0;
  }

  listenerCount(eventType?: string): number {
    if (eventType) {
      return (this.subscriptions.get(eventType) ?? []).length;
    }
    let count = 0;
    for (const subs of this.subscriptions.values()) count += subs.length;
    return count;
  }

  totalPublished(): number {
    return this.publishedCount;
  }

  addMiddleware(mw: EventMiddleware): void {
    this.middleware.push(mw);
  }
}
