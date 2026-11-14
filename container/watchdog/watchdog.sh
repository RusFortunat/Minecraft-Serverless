#!/usr/bin/env bash
# Sidecar that runs next to the Minecraft container in the same ECS task.
# To implement:
#   1. On start: point the Route 53 A record at this task's public IP.
#   2. Wait until Minecraft is listening on 25565.
#   3. Poll active connections; after SHUTDOWN_IDLE_MINUTES with 0 players,
#      set the ECS service desired count back to 0.
set -euo pipefail

echo "watchdog: not implemented yet"
sleep infinity
