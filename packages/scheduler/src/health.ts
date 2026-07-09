import type { RuntimeHealth } from "@reyou/contracts";

export function healthCheck(): RuntimeHealth {
  return {
    status: "healthy",
    uptime: process.uptime(),
    services: {},
    checks: [],
  };
}
