import { describe, it, expect } from "vitest";
import {
  AppError,
  ErrorCodes,
  validationError,
  withRetry,
  assertDefined,
} from "./index.js";

describe("AppError", () => {
  it("creates error with correct code and category", () => {
    const err = validationError("Invalid input");
    expect(err.code).toBe(ErrorCodes.VALIDATION_FAILED);
    expect(err.category).toBe("validation");
    expect(err.message).toBe("Invalid input");
  });

  it("marks retryable errors", () => {
    const err = new AppError(ErrorCodes.TIMEOUT, "timeout");
    expect(err.isRetryable()).toBe(true);
    expect(err.isRecoverable()).toBe(true);
  });

  it("marks fatal errors", () => {
    const err = new AppError(ErrorCodes.INTERNAL, "internal");
    expect(err.isFatal()).toBe(true);
    expect(err.isRetryable()).toBe(false);
  });

  it("converts to RuntimeError", () => {
    const err = validationError("test", { key: "value" });
    const rt = err.toRuntimeError();
    expect(rt.code).toBe(ErrorCodes.VALIDATION_FAILED);
    expect(rt.metadata).toEqual({ key: "value" });
  });
});

describe("withRetry", () => {
  it("succeeds on first attempt", async () => {
    const result = await withRetry(async () => "ok");
    expect(result).toBe("ok");
  });

  it("retries on failure", async () => {
    let attempts = 0;
    const result = await withRetry(async () => {
      attempts++;
      if (attempts < 3) throw new AppError(ErrorCodes.TIMEOUT, "timeout");
      return "ok";
    }, { maxAttempts: 3, baseDelayMs: 10 });
    expect(result).toBe("ok");
    expect(attempts).toBe(3);
  });

  it("throws after exhausting retries", async () => {
    await expect(
      withRetry(async () => {
        throw new AppError(ErrorCodes.TIMEOUT, "always fails");
      }, { maxAttempts: 2, baseDelayMs: 10 })
    ).rejects.toThrow(AppError);
  });
});

describe("assertDefined", () => {
  it("passes for defined values", () => {
    expect(() => assertDefined("hello", "test")).not.toThrow();
    expect(() => assertDefined(0, "test")).not.toThrow();
    expect(() => assertDefined(false, "test")).not.toThrow();
  });

  it("throws for null/undefined", () => {
    expect(() => assertDefined(null, "test")).toThrow();
    expect(() => assertDefined(undefined, "test")).toThrow();
  });
});

