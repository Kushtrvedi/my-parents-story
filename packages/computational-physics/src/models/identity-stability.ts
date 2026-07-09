import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Identity Stability = resistance to identity change, strengthens with consistency. */
export function calculate(input: ModelInput): ModelResult {
  const consistencyBonus = input.identityStability * C.IDENTITY_CONSISTENCY_WEIGHT;
  const changePenalty = input.entropy * C.IDENTITY_CHANGE_PENALTY;
  const recovery = C.IDENTITY_RECOVERY_RATE * (1 - input.identityStability);
  const value = clamp(input.identityStability + consistencyBonus - changePenalty + recovery);
  return { value, confidence: 0.9 };
}
