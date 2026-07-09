import type { LogLevel, LogEntry, Logger } from "@reyou/contracts";

// ─── Log Level Priority ──────────────────────────────
const LEVEL_PRIORITY: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
  fatal: 4,
};

// ─── Transport Interface ─────────────────────────────
export interface LogTransport {
  write(entry: LogEntry): void | Promise<void>;
}

// ─── Console Transport ───────────────────────────────
export interface ConsoleTransportOptions {
  format: "json" | "pretty";
  colors: boolean;
  minLevel: LogLevel;
}

const DEFAULT_CONSOLE_OPTIONS: ConsoleTransportOptions = {
  format: "json",
  colors: true,
  minLevel: "debug",
};

const LEVEL_COLORS: Record<LogLevel, string> = {
  debug: "\x1b[36m",
  info: "\x1b[32m",
  warn: "\x1b[33m",
  error: "\x1b[31m",
  fatal: "\x1b[35m",
};

const RESET = "\x1b[0m";

export class ConsoleTransport implements LogTransport {
  private options: ConsoleTransportOptions;

  constructor(options?: Partial<ConsoleTransportOptions>) {
    this.options = { ...DEFAULT_CONSOLE_OPTIONS, ...options };
  }

  write(entry: LogEntry): void {
    if (LEVEL_PRIORITY[entry.level] < LEVEL_PRIORITY[this.options.minLevel]) return;

    if (this.options.format === "pretty") {
      this.writePretty(entry);
    } else {
      this.writeJson(entry);
    }
  }

  private writeJson(entry: LogEntry): void {
    const line = JSON.stringify(entry);
    if (entry.level === "error" || entry.level === "fatal") {
      console.error(line);
    } else if (entry.level === "warn") {
      console.warn(line);
    } else {
      console.log(line);
    }
  }

  private writePretty(entry: LogEntry): void {
    const color = this.options.colors ? LEVEL_COLORS[entry.level] ?? "" : "";
    const reset = this.options.colors ? RESET : "";
    const level = entry.level.toUpperCase().padEnd(5);
    const timestamp = entry.timestamp ? new Date(entry.timestamp).toISOString().slice(11, 19) : "";
    const meta = entry.metadata && Object.keys(entry.metadata).length > 0 ? ` ${JSON.stringify(entry.metadata)}` : "";
    const trace = entry.correlationId ? ` [${entry.correlationId}]` : "";

    const line = `${timestamp} ${color}${level}${reset} ${entry.message}${trace}${meta}`;
    if (entry.level === "error" || entry.level === "fatal") {
      console.error(line);
      if (entry.error) console.error(`  ${entry.error.message}`);
    } else if (entry.level === "warn") {
      console.warn(line);
    } else {
      console.log(line);
    }
  }

  setMinLevel(level: LogLevel): void {
    this.options.minLevel = level;
  }

  setFormat(format: "json" | "pretty"): void {
    this.options.format = format;
  }
}

// ─── File Transport ──────────────────────────────────
export interface FileTransportOptions {
  filePath: string;
  minLevel: LogLevel;
  maxSizeBytes?: number;
  rotate?: boolean;
}

export class FileTransport implements LogTransport {
  private options: FileTransportOptions;
  private writeQueue: string[] = [];

  constructor(options: FileTransportOptions) {
    this.options = options;
  }

  write(entry: LogEntry): void {
    if (LEVEL_PRIORITY[entry.level] < LEVEL_PRIORITY[this.options.minLevel]) return;
    this.writeQueue.push(JSON.stringify(entry));
    if (this.writeQueue.length >= 10) {
      void this.flush();
    }
  }

  async flush(): Promise<void> {
    if (this.writeQueue.length === 0) return;
    const { appendFile } = await import("fs/promises");
    const lines = this.writeQueue.splice(0);
    try {
      await appendFile(this.options.filePath, lines.join("\n") + "\n", "utf-8");
    } catch {
      // Silently fail file writes - don't crash the app for logging
    }
  }
}

// ─── Logger Implementation ────────────────────────────
export interface LoggerOptions {
  transports: LogTransport[];
  defaultMetadata?: Record<string, unknown>;
  correlationId?: string;
  requestId?: string;
}

export class RuntimeLogger implements Logger {
  private transports: LogTransport[];
  private defaultMetadata: Record<string, unknown>;
  private correlationId?: string;
  private requestId?: string;

  constructor(options: LoggerOptions) {
    this.transports = [...options.transports];
    this.defaultMetadata = options.defaultMetadata ?? {};
    this.correlationId = options.correlationId;
    this.requestId = options.requestId;
  }

  debug(message: string, meta?: Record<string, unknown>): void {
    this.emit("debug", message, meta);
  }

  info(message: string, meta?: Record<string, unknown>): void {
    this.emit("info", message, meta);
  }

  warn(message: string, meta?: Record<string, unknown>): void {
    this.emit("warn", message, meta);
  }

  error(message: string, meta?: Record<string, unknown>): void {
    this.emit("error", message, meta);
  }

  fatal(message: string, meta?: Record<string, unknown>): void {
    this.emit("fatal", message, meta);
  }

  child(context: Record<string, unknown>): Logger {
    return new RuntimeLogger({
      transports: this.transports,
      defaultMetadata: { ...this.defaultMetadata, ...context },
      correlationId: this.correlationId,
      requestId: this.requestId,
    });
  }

  addTransport(transport: LogTransport): void {
    this.transports.push(transport);
  }

  setCorrelationId(id: string): void {
    this.correlationId = id;
  }

  private emit(level: LogLevel, message: string, meta?: Record<string, unknown>): void {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      correlationId: this.correlationId,
      requestId: this.requestId,
      metadata: { ...this.defaultMetadata, ...meta },
    };

    for (const transport of this.transports) {
      transport.write(entry);
    }
  }
}

// ─── Factory ──────────────────────────────────────────
export function createDefaultLogger(options?: {
  minLevel?: LogLevel;
  format?: "json" | "pretty";
  metadata?: Record<string, unknown>;
}): RuntimeLogger {
  const transport = new ConsoleTransport({
    minLevel: options?.minLevel ?? "debug",
    format: options?.format ?? "pretty",
    colors: true,
  });
  return new RuntimeLogger({
    transports: [transport],
    defaultMetadata: options?.metadata,
  });
}
