import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Entropy = system disorder, grows without correction, reduced by recovery and reflection. */
export function calculate(input: ModelInput): ModelResult {
  const growth = input.entropy * C.ENTROPY_GROWTH_RATE + (1 - input.recovery) * 0.01;
  const reduction = input.recovery * C.ENTROPY_REDUCTION_RATE + input.reflectionStrength * 0.02;
  const value = clamp(input.entropy + growth - reduction, C.ENTROPY_BASE, C.ENTROPY_MAX);
  return { value, confidence: 0.8 };
}
