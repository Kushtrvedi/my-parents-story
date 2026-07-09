import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Dream Momentum = aspiration drive, fueled by agency and reflection, decays without action. */
export function calculate(input: ModelInput): ModelResult {
  const agencyBonus = input.agency * C.DREAM_AGENCY_WEIGHT;
  const reflectionBonus = input.reflectionStrength * C.DREAM_REFLECTION_WEIGHT;
  const decay = input.dreamMomentum * C.DREAM_DECAY_RATE;
  const value = clamp(input.dreamMomentum + agencyBonus + reflectionBonus - decay);
  return { value, confidence: 0.8 };
}
