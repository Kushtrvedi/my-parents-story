type Task = () => Promise<void> | void;

export interface ScheduledTask {
  id: string;
  priority: number;
  fn: Task;
}

export class Scheduler {
  private queue: ScheduledTask[] = [];

  /** Schedule a task with an optional priority (higher runs first). */
  schedule(fn: Task, priority = 0): string {
    const id = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    this.queue.push({ id, priority, fn });
    // highest priority first
    this.queue.sort((a, b) => b.priority - a.priority);
    return id;
  }

  /** Execute all queued tasks in priority order. */
  async tick(): Promise<void> {
    const tasks = [...this.queue];
    this.queue = [];
    for (const t of tasks) {
      try {
        await t.fn();
      } catch (e) {
        // Swallow task errors – a real implementation would log.
      }
    }
  }
}
