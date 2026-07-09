/**
 * Calibration constants for computational physics models.
 * All magic numbers live here. Models reference these by name.
 */

// ─── Agency ─────────────────────────────────────────────
export const AGENCY_BASE = 0.1;
export const AGENCY_ATTENTION_WEIGHT = 0.4;
export const AGENCY_TRUST_WEIGHT = 0.3;
export const AGENCY_MOMENTUM_WEIGHT = 0.2;

// ─── Burden ─────────────────────────────────────────────
export const BURDEN_ENTROPY_WEIGHT = 0.5;
export const BURDEN_RECOVERY_DAMPING = 0.3;
export const BURDEN_ATTENTION_RELIEF = 0.2;

// ─── Attention ──────────────────────────────────────────
export const ATTENTION_MAX = 1.0;
export const ATTENTION_RECHARGE_RATE = 0.05;
export const ATTENTION_DRAIN_RATE = 0.02;
export const ATTENTION_BURDEN_SENSITIVITY = 0.3;

// ─── Momentum ───────────────────────────────────────────
export const MOMENTUM_AGENCY_MULTIPLIER = 0.15;
export const MOMENTUM_DECAY_RATE = 0.05;
export const MOMENTUM_FRICTION = 0.01;

// ─── Resistance ─────────────────────────────────────────
export const RESISTANCE_BASE = 0.1;
export const RESISTANCE_IDENTITY_WEIGHT = 0.4;
export const RESISTANCE_CHANGE_SENSITIVITY = 0.5;
export const RESISTANCE_DECAY_RATE = 0.02;

// ─── Recovery ───────────────────────────────────────────
export const RECOVERY_BASE_RATE = 0.1;
export const RECOVERY_BURDEN_PENALTY = 0.3;
export const RECOVERY_REST_MULTIPLIER = 1.5;

// ─── Trust ──────────────────────────────────────────────
export const TRUST_BASE = 0.5;
export const TRUST_CONSISTENCY_WEIGHT = 0.3;
export const TRUST_EVIDENCE_WEIGHT = 0.4;
export const TRUST_DECAY_RATE = 0.01;
export const TRUST_REBUILD_RATE = 0.05;

// ─── Opportunity ────────────────────────────────────────
export const OPPORTUNITY_BASE = 0.0;
export const OPPORTUNITY_AGENCY_WEIGHT = 0.3;
export const OPPORTUNITY_LEARNING_WEIGHT = 0.3;
export const OPPORTUNITY_CONTEXT_WEIGHT = 0.4;

// ─── Learning ───────────────────────────────────────────
export const LEARNING_RATE = 0.1;
export const LEARNING_RETENTION = 0.95;
export const LEARNING_DIMINISHING_RETURNS = 0.6;
export const LEARNING_MAX = 1.0;

// ─── Entropy ────────────────────────────────────────────
export const ENTROPY_BASE = 0.0;
export const ENTROPY_GROWTH_RATE = 0.02;
export const ENTROPY_REDUCTION_RATE = 0.03;
export const ENTROPY_MAX = 1.0;

// ─── Identity Stability ─────────────────────────────────
export const IDENTITY_BASE = 0.7;
export const IDENTITY_CONSISTENCY_WEIGHT = 0.4;
export const IDENTITY_CHANGE_PENALTY = 0.3;
export const IDENTITY_RECOVERY_RATE = 0.02;

// ─── Reflection Strength ────────────────────────────────
export const REFLECTION_BASE = 0.0;
export const REFLECTION_OBSERVATION_WEIGHT = 0.5;
export const REFLECTION_DEPTH_BONUS = 0.3;
export const REFLECTION_DECAY_RATE = 0.01;

// ─── Dream Momentum ─────────────────────────────────────
export const DREAM_BASE = 0.3;
export const DREAM_AGENCY_WEIGHT = 0.3;
export const DREAM_REFLECTION_WEIGHT = 0.3;
export const DREAM_DECAY_RATE = 0.04;

// ─── Validation ─────────────────────────────────────────
export const VALID_MIN = 0.0;
export const VALID_MAX = 1.0;
export const VALID_EPSILON = 1e-10;
