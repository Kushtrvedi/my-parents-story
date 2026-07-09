import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Learning = knowledge accumulation, with diminishing returns and retention. */
export function calculate(input: ModelInput): ModelResult {
  const retained = input.learning * C.LEARNING_RETENTION;
  const newLearning = C.LEARNING_RATE * input.attention * (1 - input.learning * C.LEARNING_DIMINISHING_RETURNS);
  const value = clamp(retained + newLearning, 0, C.LEARNING_MAX);
  return { value, confidence: 0.85 };
}
