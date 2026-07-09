import { describe, it, expect, vi } from "vitest";
import { EventBus } from "./index.js";

describe("EventBus", () => {
  it("publishes and receives events", async () => {
    const bus = new EventBus();
    const handler = vi.fn();
    bus.subscribe("test.event", handler);
    await bus.publish("test.event", { data: 42 });
    expect(handler).toHaveBeenCalledTimes(1);
    const event = handler.mock.calls[0]![0]!;
    expect(event.type).toBe("test.event");
    expect(event.payload).toEqual({ data: 42 });
  });

  it("supports unsubscribe", async () => {
    const bus = new EventBus();
    const handler = vi.fn();
    const { unsubscribe } = bus.subscribe("test.event", handler);
    unsubscribe();
    await bus.publish("test.event", {});
    expect(handler).not.toHaveBeenCalled();
  });

  it("filters events", async () => {
    const bus = new EventBus();
    const handler = vi.fn();
    bus.subscribe("test.event", handler, (event) => (event.payload as { value: number }).value > 10);
    await bus.publish("test.event", { value: 5 });
    expect(handler).not.toHaveBeenCalled();
    await bus.publish("test.event", { value: 15 });
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it("runs middleware chain", async () => {
    const bus = new EventBus();
    const calls: string[] = [];
    bus.addMiddleware(async (event, next) => { calls.push("mw1-start"); await next(event); calls.push("mw1-end"); });
    bus.addMiddleware(async (event, next) => { calls.push("mw2-start"); await next(event); calls.push("mw2-end"); });
    bus.subscribe("test.event", async () => { calls.push("handler"); });
    await bus.publish("test.event", {});
    expect(calls).toEqual(["mw1-start", "mw2-start", "handler", "mw2-end", "mw1-end"]);
  });

  it("tracks published count", async () => {
    const bus = new EventBus();
    expect(bus.totalPublished()).toBe(0);
    await bus.publish("e1", {});
    await bus.publish("e2", {});
    expect(bus.totalPublished()).toBe(2);
  });

  it("clears all subscriptions", () => {
    const bus = new EventBus();
    bus.subscribe("test", () => {});
    bus.subscribe("test", () => {});
    expect(bus.listenerCount()).toBe(2);
    bus.clear();
    expect(bus.listenerCount()).toBe(0);
  });
});

