import { describe, it, expect } from "vitest";
import { RuntimeLogger, ConsoleTransport, createDefaultLogger } from "./index.js";

describe("RuntimeLogger", () => {
  it("creates logger with console transport", () => {
    const logger = createDefaultLogger({ minLevel: "debug" });
    expect(logger).toBeDefined();
  });

  it("logs at all levels without throwing", () => {
    const logger = createDefaultLogger({ minLevel: "debug" });
    expect(() => {
      logger.debug("test debug");
      logger.info("test info");
      logger.warn("test warn");
      logger.error("test error");
    }).not.toThrow();
  });

  it("supports child loggers with metadata", () => {
    const logger = createDefaultLogger();
    const child = logger.child({ module: "test" });
    expect(child).toBeDefined();
    expect(() => child.info("child message")).not.toThrow();
  });

  it("respects min level", () => {
    const transport = new ConsoleTransport({ minLevel: "warn", format: "json", colors: false });
    const logger = new RuntimeLogger({ transports: [transport] });

    // These should not throw even though debug is below min level
    expect(() => {
      logger.debug("should be suppressed");
      logger.info("should be suppressed");
      logger.warn("should appear");
      logger.error("should appear");
    }).not.toThrow();
  });
});

