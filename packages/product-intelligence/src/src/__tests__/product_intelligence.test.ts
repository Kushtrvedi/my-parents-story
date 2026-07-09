import { test, expect } from "vitest";
import { ProductIntelligence } from "../index";
import { ExperienceRuntime } from "@reyou/experience-runtime";

test("ProductIntelligence deterministic decisions", () => {
  const exp = new ExperienceRuntime();
  // stub methods to deterministic values
  (exp as any).getAttentionBudget = () => 30;
  (exp as any).getInteractionCost = () => 2;
  (exp as any).getHospitalitySignal = () => "low";
  (exp as any).getTokens = () => [];

  const pi = new ProductIntelligence(exp);
  expect(pi.shouldSpeak()).toBe(true);
  expect(pi.shouldWait()).toBe(false);
  expect(pi.shouldInterrupt()).toBe(false);
  expect(pi.shouldRecommend()).toBe(false);
  expect(pi.shouldStaySilent()).toBe(false);
  expect(pi.priorityScore()).toBe(28);
});
