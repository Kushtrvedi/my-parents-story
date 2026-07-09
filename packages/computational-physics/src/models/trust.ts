import type { ModelInput, ModelResult } from "./types.js";
import * as C from "../calibration/index.js";
import { clamp } from "./utils.js";

/** Trust = confidence measure, rebuilds with consistency, decays without evidence. */
export function calculate(input: ModelInput): ModelResult {
  const consistencyBonus = input.identityStability * C.TRUST_CONSISTENCY_WEIGHT;
  const evidenceBonus = input.reflectionStrength * C.TRUST_EVIDENCE_WEIGHT;
  const decay = input.trust * C.TRUST_DECAY_RATE;
  const rebuild = (1 - input.trust) * C.TRUST_REBUILD_RATE;
  const value = clamp(input.trust + consistencyBonus + evidenceBonus - decay + rebuild);
  return { value, confidence: 0.9 };
}
