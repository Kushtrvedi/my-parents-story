import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Opportunity = potential for beneficial outcomes, weighted by agency, learning, and context. */
export function calculate(input: ModelInput): ModelResult {
  const raw =
    C.OPPORTUNITY_BASE +
    C.OPPORTUNITY_AGENCY_WEIGHT * input.agency +
    C.OPPORTUNITY_LEARNING_WEIGHT * input.learning +
    C.OPPORTUNITY_CONTEXT_WEIGHT * (1 - input.entropy);
  const value = clamp(raw);
  return { value, confidence: 0.8 };
}
