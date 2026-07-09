import { ExperienceRuntime } from "../index";

import { test, expect } from "vitest";

test("experience runtime token flow", () => {
  const er = new ExperienceRuntime();
  er.addToken({ id: "1", type: "click", payload: {} });
  expect(er.getTokens()).toHaveLength(1);
  expect(er.getInteractionCost()).toBe(1);
  expect(er.getAttentionBudget()).toBe(100);
});
