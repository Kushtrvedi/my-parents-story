import type { RuntimeHealth } from "@reyou/contracts";
import { HumanRuntime } from "./index.js";

const runtime = new HumanRuntime();

export function healthCheck(): RuntimeHealth {
  return runtime.health();
}

