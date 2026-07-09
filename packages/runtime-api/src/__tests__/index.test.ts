import {
  getState,
  mutate,
  snapshot,
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  getTransactionState,
  getVersionHistory,
  getVersion,
  rollbackToVersion,
  trimHistory,
  schedule,
  getMetrics,
  health,
  scheduler,
} from "../index";
import { describe, it, expect } from "vitest";

describe("runtime-api", () => {
  describe("state access", () => {
    it("getState returns initial version", () => {
      const state = getState();
      expect(state.version).toBeGreaterThanOrEqual(0);
    });

    it("snapshot returns current state", () => {
      const snap = snapshot();
      expect(typeof snap.capturedAt).toBe("number");
    });
  });

  describe("mutations", () => {
    it("mutate via API increments version", async () => {
      const before = getState().version;
      await mutate((s) => ({ ...s, data: { ...s.data, test: true } }));
      expect(getState().version).toBe(before + 1);
    });
  });

  describe("transactions", () => {
    it("beginTransaction returns a handle", () => {
      const handle = beginTransaction();
      expect(handle.id).toMatch(/^hr-tx-/);
      expect(handle.state).toBe("active");
    });

    it("commitTransaction applies mutations", async () => {
      const handle = beginTransaction();
      await commitTransaction(handle.id, (s) => ({ ...s, data: { ...s.data, committed: true } }));
      expect(getState().data.committed).toBe(true);
    });

    it("rollbackTransaction discards changes", async () => {
      const before = getState().version;
      const handle = beginTransaction();
      rollbackTransaction(handle.id);
      expect(getState().version).toBe(before);
    });

    it("getTransactionState returns isolated copy", () => {
      const handle = beginTransaction();
      const txState = getTransactionState(handle.id);
      expect(txState).not.toBeNull();
    });
  });

  describe("version management", () => {
    it("getVersionHistory returns array", () => {
      const history = getVersionHistory();
      expect(Array.isArray(history)).toBe(true);
      expect(history.length).toBeGreaterThan(0);
    });

    it("getVersion returns specific version", () => {
      const v = getVersion(0);
      expect(v).not.toBeNull();
    });

    it("rollbackToVersion reverts state", async () => {
      const currentVersion = getState().version;
      await rollbackToVersion(0);
      expect(getState().version).toBe(0);
      // Restore to current
      await rollbackToVersion(currentVersion);
    });

    it("trimHistory reduces history", () => {
      const before = getVersionHistory().length;
      trimHistory(1);
      expect(getVersionHistory().length).toBeLessThanOrEqual(before);
    });
  });

  describe("scheduling", () => {
    it("schedule adds task and runs tick", async () => {
      const order: number[] = [];
      schedule(() => { order.push(1); }, 1);
      schedule(() => { order.push(2); }, 0);
      await scheduler.tick();
      expect(order).toEqual([1, 2]);
    });
  });

  describe("metrics", () => {
    it("getMetrics returns runtime metrics", () => {
      const m = getMetrics();
      expect(typeof m.mutationCount).toBe("number");
      expect(typeof m.uptimeMs).toBe("number");
      expect(typeof m.currentVersion).toBe("number");
    });
  });

  describe("health", () => {
    it("health returns healthy status", () => {
      const h = health();
      expect(h.status).toBe("healthy");
    });
  });
});
