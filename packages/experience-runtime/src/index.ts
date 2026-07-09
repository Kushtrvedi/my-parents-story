import { getState } from "@reyou/runtime-api";

export interface ExperienceToken {
  id: string;
  type: string;
  payload: unknown;
}

export class ExperienceRuntime {
  private tokens: ExperienceToken[] = [];

  addToken(token: ExperienceToken): void {
    this.tokens.push(token);
  }

  getTokens(): ExperienceToken[] {
    return [...this.tokens];
  }

  getInteractionCost(): number {
    return this.tokens.length * 1;
  }

  getAttentionBudget(): number {
    const state = getState();
    const data = state.data as any;
    const activeTasks = Object.values(data.execution?.tasks ?? {}).filter((t: any) => t.status === "in_progress").length;
    const pendingTasks = Object.values(data.execution?.tasks ?? {}).filter((t: any) => t.status === "pending").length;
    return Math.max(0, 100 - (activeTasks * 20) - (pendingTasks * 5));
  }

  getHospitalitySignal(): string {
    const state = getState();
    const data = state.data as any;
    const recentEmotions = Object.values(data.emotion?.observations ?? {}).slice(0, 3);
    const hasNegative = recentEmotions.some((e: any) => e.valence < 0);
    if (hasNegative) return "high";
    if (recentEmotions.length > 3) return "medium";
    return "low";
  }
}
