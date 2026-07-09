import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Reflection Strength = self-awareness depth, increases with observation, decays without. */
export function calculate(input: ModelInput): ModelResult {
  const observationBonus = input.attention * C.REFLECTION_OBSERVATION_WEIGHT;
  const depthBonus = input.learning * C.REFLECTION_DEPTH_BONUS;
  const decay = input.reflectionStrength * C.REFLECTION_DECAY_RATE;
  const value = clamp(input.reflectionStrength + observationBonus + depthBonus - decay);
  return { value, confidence: 0.85 };
}
