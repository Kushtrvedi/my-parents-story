import { HumanRuntime } from "../index";
import { describe, it, expect } from "vitest";

describe("HumanRuntime", () => {
  describe("initialization", () => {
    it("initial version is zero", () => {
      const rt = new HumanRuntime();
      expect(rt.getState().version).toBe(0);
    });

    it("accepts initial state", () => {
      const rt = new HumanRuntime({ version: 5, data: { foo: "bar" } });
      expect(rt.getState().version).toBe(5);
      expect(rt.getState().data.foo).toBe("bar");
    });

    it("returns immutable copy from getState", () => {
      const rt = new HumanRuntime();
      const state1 = rt.getState();
      const state2 = rt.getState();
      expect(state1).not.toBe(state2);
      expect(state1).toEqual(state2);
    });
  });

  describe("mutate", () => {
    it("mutate increments version", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => ({ ...s, data: { foo: "bar" } }));
      expect(rt.getState().version).toBe(1);
    });

    it("mutate updates timestamp", async () => {
      const rt = new HumanRuntime();
      const before = rt.getState().timestamp;
      await new Promise((r) => setTimeout(r, 10));
      await rt.mutate((s) => s);
      expect(rt.getState().timestamp).toBeGreaterThan(before);
    });

    it("mutate applies changes", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => ({ ...s, data: { energy: 80 } }));
      expect(rt.getState().data.energy).toBe(80);
    });

    it("multiple mutations increment version sequentially", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      expect(rt.getState().version).toBe(3);
    });
  });

  describe("snapshot and restore", () => {
    it("snapshot captures current state", () => {
      const rt = new HumanRuntime();
      const snap = rt.snapshot();
      expect(snap.version).toBe(0);
      expect(typeof snap.capturedAt).toBe("number");
    });

    it("restore reverts state without bumping version", () => {
      const rt = new HumanRuntime();
      rt.snapshot(); // capture for later use
      rt.restore({ version: 99, timestamp: 0, data: {} });
      expect(rt.getState().version).toBe(99);
    });
  });

  describe("transactions", () => {
    it("beginTransaction returns a handle", () => {
      const rt = new HumanRuntime();
      const handle = rt.beginTransaction();
      expect(handle.id).toMatch(/^hr-tx-/);
      expect(handle.state).toBe("active");
    });

    it("getTransactionState returns isolated copy", () => {
      const rt = new HumanRuntime();
      const handle = rt.beginTransaction();
      const txState = rt.getTransactionState(handle.id);
      expect(txState).not.toBeNull();
      expect(txState!.version).toBe(0);
    });

    it("commitTransaction applies mutations", async () => {
      const rt = new HumanRuntime();
      const handle = rt.beginTransaction();
      await rt.commitTransaction(handle.id, (s) => ({ ...s, data: { x: 1 } }));
      expect(rt.getState().data.x).toBe(1);
    });

    it("rollbackTransaction discards changes", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => ({ ...s, data: { before: true } }));
      const handle = rt.beginTransaction();
      rt.rollbackTransaction(handle.id);
      expect(rt.getState().data.before).toBe(true);
    });

    it("commitTransaction marks handle as committed", async () => {
      const rt = new HumanRuntime();
      const handle = rt.beginTransaction();
      await rt.commitTransaction(handle.id);
      expect(rt.getTransactionState(handle.id)).toBeNull();
    });

    it("throws on commit of non-active transaction", async () => {
      const rt = new HumanRuntime();
      const handle = rt.beginTransaction();
      await rt.commitTransaction(handle.id);
      await expect(rt.commitTransaction(handle.id)).rejects.toThrow("not active");
    });

    it("throws on rollback of unknown transaction", () => {
      const rt = new HumanRuntime();
      expect(() => rt.rollbackTransaction("unknown")).toThrow("not found");
    });
  });

  describe("version management", () => {
    it("tracks version history", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      expect(rt.getVersionHistory()).toHaveLength(3); // initial + 2 mutations
    });

    it("getVersion returns specific version", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => ({ ...s, data: { v: 1 } }));
      const v0 = rt.getVersion(0);
      expect(v0).not.toBeNull();
      expect(v0!.data.v).toBeUndefined();
    });

    it("rollbackToVersion reverts to specific version", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => ({ ...s, data: { step: 1 } }));
      await rt.mutate((s) => ({ ...s, data: { step: 2 } }));
      await rt.rollbackToVersion(0);
      expect(rt.getState().data.step).toBeUndefined();
    });

    it("trimHistory reduces history size", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      const removed = rt.trimHistory(2);
      expect(removed).toBe(2);
      expect(rt.getVersionHistory()).toHaveLength(2);
    });
  });

  describe("metrics", () => {
    it("tracks mutation count", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => s);
      await rt.mutate((s) => s);
      expect(rt.getMetrics().mutationCount).toBe(2);
    });

    it("tracks transaction counts", async () => {
      const rt = new HumanRuntime();
      const h1 = rt.beginTransaction();
      const h2 = rt.beginTransaction();
      await rt.commitTransaction(h1.id);
      rt.rollbackTransaction(h2.id);
      const m = rt.getMetrics();
      expect(m.transactionCount).toBe(2);
      expect(m.committedTransactions).toBe(1);
      expect(m.rolledBackTransactions).toBe(1);
    });

    it("tracks uptime", () => {
      const rt = new HumanRuntime();
      expect(rt.getMetrics().uptimeMs).toBeGreaterThanOrEqual(0);
    });

    it("tracks current version in metrics", async () => {
      const rt = new HumanRuntime();
      await rt.mutate((s) => s);
      expect(rt.getMetrics().currentVersion).toBe(1);
    });
  });
});
