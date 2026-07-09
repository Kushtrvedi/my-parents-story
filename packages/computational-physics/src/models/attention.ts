import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Attention = focus budget, recharges over time, drains under burden. */
export function calculate(input: ModelInput): ModelResult {
  const recharge = input.attention + C.ATTENTION_RECHARGE_RATE;
  const burdenDrain = input.burden * C.ATTENTION_BURDEN_SENSITIVITY;
  const naturalDrain = C.ATTENTION_DRAIN_RATE;
  const value = clamp(recharge - burdenDrain - naturalDrain, 0, C.ATTENTION_MAX);
  return { value, confidence: 0.9 };
}
