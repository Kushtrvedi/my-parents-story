import type { ExperienceRuntime } from "@reyou/experience-runtime";
import type { HumanStateVector } from "@reyou/human-runtime";

// ─── Decision Types ─────────────────────────────────────

export type DecisionAction = "speak" | "silence" | "recommend" | "interrupt" | "wait" | "escape" | "ignore";

export interface DecisionTrace {
  timestamp: number;
  action: DecisionAction;
  reason: string;
  inputs: Record<string, unknown>;
}

export interface Decision {
  action: DecisionAction;
  reason: string;
  confidence: number;
  evidence: string[];
  attentionCost: number;
  benefit: number;
  risk: number;
  trace: DecisionTrace;
}

// ─── Policy Engine ──────────────────────────────────────

export interface Rule {
  id: string;
  condition: (ctx: DecisionContext) => boolean;
  action: DecisionAction;
  weight: number;
  reason: string;
}

export interface Policy {
  id: string;
  name: string;
  rules: Rule[];
  fallback: DecisionAction;
  enabled: boolean;
}

export interface PolicyEvaluation {
  policyId: string;
  triggered: boolean;
  action?: DecisionAction;
  reason?: string;
  confidence: number;
}

// ─── Decision Context ───────────────────────────────────

export interface DecisionContext {
  attentionBudget: number;
  interactionCost: number;
  hospitality: string;
  tokens: unknown[];
  burden: number;
  entropy: number;
  recovery: number;
  trust: number;
  agency: number;
  risk: number;
  opportunity: number;
}

// ─── ProductIntelligence ────────────────────────────────

export class ProductIntelligence {
  private policies: Policy[] = [];
  private history: Decision[] = [];
  private stateAccessor: (() => HumanStateVector) | null = null;

  constructor(private experience: ExperienceRuntime) {}

  // ─── State Access ─────────────────────────────────────

  /** Set a function to access runtime state for context building */
  setStateAccessor(accessor: () => HumanStateVector): void {
    this.stateAccessor = accessor;
  }

  // ─── Policy Management ──────────────────────────────

  addPolicy(policy: Policy): void {
    this.policies.push(policy);
  }

  removePolicy(id: string): void {
    this.policies = this.policies.filter((p) => p.id !== id);
  }

  getPolicy(id: string): Policy | undefined {
    return this.policies.find((p) => p.id === id);
  }

  listPolicies(): Policy[] {
    return [...this.policies];
  }

  // ─── Core Decision Methods (backward compatible) ────

  shouldSpeak(): boolean {
    const decision = this.decide();
    return decision.action === "speak";
  }

  shouldWait(): boolean {
    return this.experience.getInteractionCost() > 5;
  }

  shouldInterrupt(): boolean {
    return this.experience.getHospitalitySignal() === "high";
  }

  shouldRecommend(): boolean {
    return this.experience.getTokens().length > 0;
  }

  shouldStaySilent(): boolean {
    return !this.shouldSpeak() && !this.shouldRecommend();
  }

  priorityScore(): number {
    return this.experience.getAttentionBudget() - this.experience.getInteractionCost();
  }

  // ─── Explainable Decision Engine ────────────────────

  private buildContext(): DecisionContext {
    // Read from runtime state if available
    if (this.stateAccessor) {
      const state = this.stateAccessor();
      const data = state.data as any;

      const tasks = Object.values(data.execution?.tasks ?? {}) as any[];
      const activeTasks = tasks.filter(t => t.status === "in_progress").length;
      const pendingTasks = tasks.filter(t => t.status === "pending").length;
      const blockedTasks = tasks.filter(t => t.status === "blocked").length;

      const emotions = Object.values(data.emotion?.observations ?? {}) as any[];
      const recentEmotions = emotions.slice(-5);
      const negativeEmotions = recentEmotions.filter(e =>
        e.confidence > 0.6 && ["stressed", "overwhelmed", "anxious", "tired", "frustrated"].includes(e.observation)
      ).length;

      const dreams = Object.values(data.dreams ?? {}) as any[];
      const activeDreams = dreams.filter(d => d.activated).length;

      const projects = Object.values(data.execution?.projects ?? {}) as any[];
      const activeProjects = projects.filter(p => p.status === "active").length;

      // Calculate burden from state
      const openLoops = pendingTasks + blockedTasks + activeDreams + activeProjects;
      const attentionCost = activeTasks * 25 + pendingTasks * 10 + blockedTasks * 15 + negativeEmotions * 20 + Math.min(openLoops * 5, 50);
      const burden = Math.min(1, attentionCost / 100);

      // Calculate recovery
      const timeSinceLastActive = Date.now() - state.timestamp;
      const hoursSinceActive = timeSinceLastActive / 3600000;
      let recovery = 0.5;
      if (hoursSinceActive > 8) recovery += 0.2;
      if (negativeEmotions === 0 && activeTasks > 0) recovery += 0.1;
      recovery = Math.min(1, recovery);

      // Calculate entropy (complexity of current state)
      const entropy = Math.min(1, (activeTasks + pendingTasks + blockedTasks) / 10);

      // Calculate trust (based on completion rate)
      const completedTasks = tasks.filter(t => t.status === "completed").length;
      const trust = tasks.length > 0 ? completedTasks / tasks.length : 0.5;

      // Calculate agency (based on active engagement)
      const agency = activeTasks > 0 ? 0.8 : pendingTasks > 0 ? 0.5 : 0.2;

      // Calculate risk (based on blocked tasks and negative emotions)
      const risk = Math.min(1, (blockedTasks * 0.3 + negativeEmotions * 0.2));

      // Calculate opportunity (based on pending tasks and dreams)
      const opportunity = Math.min(1, (pendingTasks * 0.2 + activeDreams * 0.3));

      return {
        attentionBudget: this.experience.getAttentionBudget(),
        interactionCost: this.experience.getInteractionCost(),
        hospitality: this.experience.getHospitalitySignal(),
        tokens: this.experience.getTokens(),
        burden,
        entropy,
        recovery,
        trust,
        agency,
        risk,
        opportunity,
      };
    }

    // Fallback to experience runtime values
    return {
      attentionBudget: this.experience.getAttentionBudget(),
      interactionCost: this.experience.getInteractionCost(),
      hospitality: this.experience.getHospitalitySignal(),
      tokens: this.experience.getTokens(),
      burden: 0.3,
      entropy: 0.1,
      recovery: 0.6,
      trust: 0.5,
      agency: 0.5,
      risk: 0.2,
      opportunity: 0.4,
    };
  }

  decide(): Decision {
    const ctx = this.buildContext();
    const evaluations = this.evaluatePolicies(ctx);

    // Find the highest-weight triggered rule across all policies
    let bestAction: DecisionAction = "ignore";
    let bestReason = "No policy matched";
    let bestWeight = 0;
    let bestPolicyId = "";

    for (const evalResult of evaluations) {
      if (evalResult.triggered && evalResult.action && evalResult.confidence > bestWeight) {
        bestAction = evalResult.action;
        bestReason = evalResult.reason ?? "Policy triggered";
        bestWeight = evalResult.confidence;
        bestPolicyId = evalResult.policyId;
      }
    }

    // Fallback to heuristic if no policy matched
    if (bestWeight === 0) {
      const heuristic = this.heuristicDecision(ctx);
      bestAction = heuristic.action;
      bestReason = heuristic.reason;
      bestWeight = heuristic.confidence;
    }

    const attentionCost = this.calculateAttentionCost(ctx, bestAction);
    const benefit = this.calculateBenefit(ctx, bestAction);
    const risk = this.calculateRisk(ctx, bestAction);
    const confidence = Math.min(1, bestWeight);

    const decision: Decision = {
      action: bestAction,
      reason: bestReason,
      confidence,
      evidence: this.gatherEvidence(ctx, bestAction),
      attentionCost,
      benefit,
      risk,
      trace: {
        timestamp: Date.now(),
        action: bestAction,
        reason: bestReason,
        inputs: { ...ctx, policyId: bestPolicyId, evaluations: evaluations.length },
      },
    };

    this.history.push(decision);
    return decision;
  }

  private evaluatePolicies(ctx: DecisionContext): PolicyEvaluation[] {
    return this.policies
      .filter((p) => p.enabled)
      .map((policy) => {
        let bestRule: Rule | undefined;
        for (const rule of policy.rules) {
          if (rule.condition(ctx)) {
            if (!bestRule || rule.weight > bestRule.weight) {
              bestRule = rule;
            }
          }
        }
        if (bestRule) {
          return {
            policyId: policy.id,
            triggered: true,
            action: bestRule.action,
            reason: bestRule.reason,
            confidence: bestRule.weight,
          };
        }
        return {
          policyId: policy.id,
          triggered: false,
          confidence: 0,
        };
      });
  }

  private heuristicDecision(ctx: DecisionContext): { action: DecisionAction; reason: string; confidence: number } {
    if (ctx.attentionBudget > 20 && ctx.interactionCost < 5) {
      return { action: "speak", reason: "High attention budget, low interaction cost", confidence: 0.7 };
    }
    if (ctx.tokens.length > 0 && ctx.interactionCost < 3) {
      return { action: "recommend", reason: "Pending tokens with low cost", confidence: 0.6 };
    }
    if (ctx.hospitality === "high") {
      return { action: "interrupt", reason: "High hospitality signal", confidence: 0.5 };
    }
    if (ctx.interactionCost > 5) {
      return { action: "wait", reason: "High interaction cost", confidence: 0.6 };
    }
    return { action: "silence", reason: "Default: no compelling reason to act", confidence: 0.4 };
  }

  private calculateAttentionCost(ctx: DecisionContext, action: DecisionAction): number {
    const baseCosts: Record<DecisionAction, number> = {
      speak: 0.3,
      silence: 0.0,
      recommend: 0.2,
      interrupt: 0.5,
      wait: 0.05,
      escape: 0.1,
      ignore: 0.0,
    };
    const base = baseCosts[action] ?? 0.1;
    return Math.min(1, base + ctx.burden * 0.2);
  }

  private calculateBenefit(ctx: DecisionContext, action: DecisionAction): number {
    const baseBenefits: Record<DecisionAction, number> = {
      speak: 0.4,
      silence: 0.1,
      recommend: 0.5,
      interrupt: 0.3,
      wait: 0.2,
      escape: 0.1,
      ignore: 0.0,
    };
    const base = baseBenefits[action] ?? 0.1;
    return Math.min(1, base + ctx.opportunity * 0.3 + ctx.trust * 0.2);
  }

  private calculateRisk(ctx: DecisionContext, action: DecisionAction): number {
    const baseRisks: Record<DecisionAction, number> = {
      speak: 0.2,
      silence: 0.05,
      recommend: 0.15,
      interrupt: 0.4,
      wait: 0.05,
      escape: 0.1,
      ignore: 0.02,
    };
    const base = baseRisks[action] ?? 0.1;
    return Math.min(1, base + ctx.risk * 0.3 + ctx.entropy * 0.2);
  }

  private gatherEvidence(ctx: DecisionContext, action: DecisionAction): string[] {
    const evidence: string[] = [];
    if (ctx.attentionBudget > 15) evidence.push("high-attention-budget");
    if (ctx.interactionCost < 3) evidence.push("low-interaction-cost");
    if (ctx.tokens.length > 0) evidence.push("pending-tokens");
    if (ctx.hospitality === "high") evidence.push("high-hospitality");
    if (ctx.trust > 0.7) evidence.push("high-trust");
    if (ctx.agency > 0.7) evidence.push("high-agency");
    evidence.push(`action:${action}`);
    return evidence;
  }

  // ─── History & Explanation ──────────────────────────

  getHistory(): Decision[] {
    return [...this.history];
  }

  getLastDecision(): Decision | undefined {
    return this.history[this.history.length - 1];
  }

  explainLastDecision(): string | undefined {
    const last = this.getLastDecision();
    if (!last) return undefined;
    return [
      `Action: ${last.action}`,
      `Reason: ${last.reason}`,
      `Confidence: ${(last.confidence * 100).toFixed(1)}%`,
      `Evidence: ${last.evidence.join(", ")}`,
      `Attention Cost: ${last.attentionCost.toFixed(3)}`,
      `Benefit: ${last.benefit.toFixed(3)}`,
      `Risk: ${last.risk.toFixed(3)}`,
    ].join("\n");
  }

  clearHistory(): void {
    this.history = [];
  }
}
