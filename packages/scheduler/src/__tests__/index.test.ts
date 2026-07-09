import { Scheduler } from "../index";

import { test, expect } from "vitest";

test("tasks run in priority order", async () => {
  const scheduler = new Scheduler();
  const order: number[] = [];
  scheduler.schedule(() => { order.push(2); }, 0);
  scheduler.schedule(() => { order.push(1); }, 5);
  await scheduler.tick();
  expect(order).toEqual([1, 2]);
});
