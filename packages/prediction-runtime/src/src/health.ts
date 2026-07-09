import type { RuntimeHealth } from "@reyou/contracts";

export function health(): RuntimeHealth {
  return {
    status: "healthy",
    uptime: 0,
    services: {},
    checks: [],
  };
}
