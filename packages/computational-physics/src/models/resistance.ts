import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Resistance = force opposing change, increases with identity stability and change sensitivity. */
export function calculate(input: ModelInput): ModelResult {
  const base = C.RESISTANCE_BASE;
  const identityPush = input.identityStability * C.RESISTANCE_IDENTITY_WEIGHT;
  const changePush = (1 - input.agency) * C.RESISTANCE_CHANGE_SENSITIVITY;
  const decay = input.resistance * C.RESISTANCE_DECAY_RATE;
  const value = clamp(base + identityPush + changePush - decay);
  return { value, confidence: 0.8 };
}
