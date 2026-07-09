import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp, sigmoid } from "./utils.js";

/** Agency = capacity for autonomous action, driven by attention, trust, and momentum. */
export function calculate(input: ModelInput): ModelResult {
  const raw =
    C.AGENCY_BASE +
    C.AGENCY_ATTENTION_WEIGHT * sigmoid(input.attention) +
    C.AGENCY_TRUST_WEIGHT * sigmoid(input.trust) +
    C.AGENCY_MOMENTUM_WEIGHT * clamp(input.momentum);
  const value = clamp(raw);
  return { value, confidence: 0.9 };
}
