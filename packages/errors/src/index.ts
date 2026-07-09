import type { ErrorCategory, RuntimeError } from "@reyou/contracts";

// ─── Error Codes ──────────────────────────────────────────
export const ErrorCodes = {
  VALIDATION_FAILED: "ERR_VALIDATION_FAILED",
  CONFIG_MISSING: "ERR_CONFIG_MISSING",
  CONFIG_INVALID: "ERR_CONFIG_INVALID",
  SERVICE_UNAVAILABLE: "ERR_SERVICE_UNAVAILABLE",
  DEPENDENCY_FAILED: "ERR_DEPENDENCY_FAILED",
  INITIALIZATION_FAILED: "ERR_INITIALIZATION_FAILED",
  OPERATION_FAILED: "ERR_OPERATION_FAILED",
  NOT_FOUND: "ERR_NOT_FOUND",
  ALREADY_EXISTS: "ERR_ALREADY_EXISTS",
  PERMISSION_DENIED: "ERR_PERMISSION_DENIED",
  TIMEOUT: "ERR_TIMEOUT",
  RETRY_EXHAUSTED: "ERR_RETRY_EXHAUSTED",
  INTERNAL: "ERR_INTERNAL",
  UNKNOWN: "ERR_UNKNOWN",
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

// ─── Category Map ─────────────────────────────────────────
const CATEGORY_MAP: Record<ErrorCode, ErrorCategory> = {
  [ErrorCodes.VALIDATION_FAILED]: "validation",
  [ErrorCodes.CONFIG_MISSING]: "configuration",
  [ErrorCodes.CONFIG_INVALID]: "configuration",
  [ErrorCodes.SERVICE_UNAVAILABLE]: "runtime",
  [ErrorCodes.DEPENDENCY_FAILED]: "runtime",
  [ErrorCodes.INITIALIZATION_FAILED]: "fatal",
  [ErrorCodes.OPERATION_FAILED]: "runtime",
  [ErrorCodes.NOT_FOUND]: "runtime",
  [ErrorCodes.ALREADY_EXISTS]: "runtime",
  [ErrorCodes.PERMISSION_DENIED]: "security",
  [ErrorCodes.TIMEOUT]: "retryable",
  [ErrorCodes.RETRY_EXHAUSTED]: "fatal",
  [ErrorCodes.INTERNAL]: "fatal",
  [ErrorCodes.UNKNOWN]: "fatal",
};

// ─── Base Error Class ─────────────────────────────────────
export class AppError extends Error {
  public readonly code: ErrorCode;
  public readonly category: ErrorCategory;
  public readonly metadata: Record<string, unknown>;
  public readonly timestamp: number;

  constructor(
    code: ErrorCode,
    message: string,
    metadata?: Record<string, unknown>,
    cause?: Error
  ) {
    super(message);
    this.name = "AppError";
    this.code = code;
    this.category = CATEGORY_MAP[code] ?? "runtime";
    this.metadata = metadata ?? {};
    this.timestamp = Date.now();
    if (cause) this.cause = cause;
  }

  toRuntimeError(): RuntimeError {
    return {
      code: this.code,
      category: this.category,
      message: this.message,
      metadata: this.metadata,
      timestamp: this.timestamp,
      cause: this.cause instanceof Error ? this.cause : undefined,
    };
  }

  isRetryable(): boolean {
    return this.category === "retryable";
  }

  isRecoverable(): boolean {
    return this.category === "recoverable" || this.category === "retryable";
  }

  isFatal(): boolean {
    return this.category === "fatal";
  }
}

// ─── Error Factory ────────────────────────────────────────
export function validationError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.VALIDATION_FAILED, message, metadata, cause);
}

export function configError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.CONFIG_MISSING, message, metadata, cause);
}

export function serviceError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.SERVICE_UNAVAILABLE, message, metadata, cause);
}

export function dependencyError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.DEPENDENCY_FAILED, message, metadata, cause);
}

export function initError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.INITIALIZATION_FAILED, message, metadata, cause);
}

export function notFoundError(message: string, metadata?: Record<string, unknown>): AppError {
  return new AppError(ErrorCodes.NOT_FOUND, message, metadata);
}

export function permissionError(message: string, metadata?: Record<string, unknown>): AppError {
  return new AppError(ErrorCodes.PERMISSION_DENIED, message, metadata);
}

export function timeoutError(message: string, metadata?: Record<string, unknown>): AppError {
  return new AppError(ErrorCodes.TIMEOUT, message, metadata);
}

export function retryExhaustedError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.RETRY_EXHAUSTED, message, metadata, cause);
}

export function internalError(message: string, metadata?: Record<string, unknown>, cause?: Error): AppError {
  return new AppError(ErrorCodes.INTERNAL, message, metadata, cause);
}

// ─── Guard Utilities ──────────────────────────────────────
export function assertDefined<T>(value: T | null | undefined, name: string): asserts value is T {
  if (value === null || value === undefined) {
    throw validationError(`${name} is required`);
  }
}

export function assertString(value: unknown, name: string): asserts value is string {
  if (typeof value !== "string") {
    throw validationError(`${name} must be a string`, { actual: typeof value });
  }
}

export function assertNumber(value: unknown, name: string): asserts value is number {
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw validationError(`${name} must be a valid number`, { actual: typeof value });
  }
}

export function assertBoolean(value: unknown, name: string): asserts value is boolean {
  if (typeof value !== "boolean") {
    throw validationError(`${name} must be a boolean`, { actual: typeof value });
  }
}

// ─── Retry Utility ────────────────────────────────────────
export interface RetryOptions {
  maxAttempts: number;
  baseDelayMs: number;
  maxDelayMs: number;
  retryableErrors?: ErrorCode[];
}

const DEFAULT_RETRY: RetryOptions = {
  maxAttempts: 3,
  baseDelayMs: 100,
  maxDelayMs: 5000,
};

export async function withRetry<T>(
  fn: () => Promise<T>,
  options?: Partial<RetryOptions>
): Promise<T> {
  const opts = { ...DEFAULT_RETRY, ...options };
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));

      if (attempt === opts.maxAttempts) break;

      const isRetryable = err instanceof AppError
        ? err.isRetryable()
        : opts.retryableErrors === undefined;

      if (!isRetryable) break;

      const delay = Math.min(opts.baseDelayMs * Math.pow(2, attempt - 1), opts.maxDelayMs);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw lastError ?? new AppError(ErrorCodes.RETRY_EXHAUSTED, "All retry attempts failed");
}
