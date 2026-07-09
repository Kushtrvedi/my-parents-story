import type { RuntimeHealth } from "@reyou/contracts";
import { humanRuntime } from "./index.js";

export function healthCheck(): RuntimeHealth {
  return humanRuntime.health();
}

