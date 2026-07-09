import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Momentum = behavioral inertia, increases with agency, decays over time. */
export function calculate(input: ModelInput): ModelResult {
  const growth = input.agency * C.MOMENTUM_AGENCY_MULTIPLIER;
  const decay = input.momentum * C.MOMENTUM_DECAY_RATE;
  const friction = C.MOMENTUM_FRICTION;
  const value = clamp(input.momentum + growth - decay - friction);
  return { value, confidence: 0.85 };
}
