import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Burden = cognitive load, increased by entropy, decreased by recovery and attention. */
export function calculate(input: ModelInput): ModelResult {
  const raw =
    input.entropy * C.BURDEN_ENTROPY_WEIGHT +
    (1 - input.recovery) * C.BURDEN_RECOVERY_DAMPING +
    (1 - input.attention) * C.BURDEN_ATTENTION_RELIEF;
  const value = clamp(raw);
  return { value, confidence: 0.85 };
}
