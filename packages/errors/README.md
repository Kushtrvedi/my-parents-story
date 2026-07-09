# @reyou/errors — RE-YOU OS Unified Error Framework

Standardized error handling, error codes, type guards, and retry logic for the entire RE-YOU OS ecosystem.

## Usage

```typescript
import { AppError, ErrorCodes, validationError, withRetry, assertDefined } from "@reyou/errors";

// Throw a typed error
throw validationError("Invalid email format", { field: "email" });

// Check error properties
try {
  // ...
} catch (err) {
  if (err instanceof AppError) {
    console.log(err.code);      // "ERR_VALIDATION_FAILED"
    console.log(err.category);  // "validation"
    console.log(err.isRetryable());
  }
}

// Retry with backoff
const result = await withRetry(
  () => fetchData(),
  { maxAttempts: 5, baseDelayMs: 200 }
);

// Assertion guards
assertDefined(config.apiKey, "apiKey");
```

## Error Categories

| Code                        | Category        | Retryable | Fatal |
|-----------------------------|-----------------|-----------|-------|
| `ERR_VALIDATION_FAILED`     | validation      |           |       |
| `ERR_CONFIG_MISSING`        | configuration   |           |       |
| `ERR_CONFIG_INVALID`        | configuration   |           |       |
| `ERR_SERVICE_UNAVAILABLE`   | runtime         |           |       |
| `ERR_DEPENDENCY_FAILED`     | runtime         |           |       |
| `ERR_INITIALIZATION_FAILED` | fatal           |           | ✓     |
| `ERR_OPERATION_FAILED`      | runtime         |           |       |
| `ERR_NOT_FOUND`             | runtime         |           |       |
| `ERR_ALREADY_EXISTS`        | runtime         |           |       |
| `ERR_PERMISSION_DENIED`     | security        |           |       |
| `ERR_TIMEOUT`               | retryable       | ✓         |       |
| `ERR_RETRY_EXHAUSTED`       | fatal           |           | ✓     |
| `ERR_INTERNAL`              | fatal           |           | ✓     |
| `ERR_UNKNOWN`               | fatal           |           | ✓     |

## API

### `AppError`

Base error class extended from `Error`.

- `code` — Machine-readable error code
- `category` — Logical category for routing/recovery
- `metadata` — Arbitrary structured data
- `timestamp` — Epoch ms when the error was created
- `cause` — Optional originating error

### Factory Functions

`validationError()`, `configError()`, `serviceError()`, `dependencyError()`, `initError()`, `notFoundError()`, `permissionError()`, `timeoutError()`, `retryExhaustedError()`, `internalError()`

### Guards

`assertDefined()`, `assertString()`, `assertNumber()`, `assertBoolean()`

### Retry

`withRetry()` — Exponential backoff with jitter support for retryable errors.
