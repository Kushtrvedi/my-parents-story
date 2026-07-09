import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Recovery = capacity to bounce back, increases with rest, penalized by burden. */
export function calculate(input: ModelInput): ModelResult {
  const baseRate = C.RECOVERY_BASE_RATE;
  const burdenPenalty = input.burden * C.RECOVERY_BURDEN_PENALTY;
  const restBonus = (1 - input.burden) * C.RECOVERY_REST_MULTIPLIER * baseRate;
  const value = clamp(input.recovery + restBonus - burdenPenalty);
  return { value, confidence: 0.85 };
}
