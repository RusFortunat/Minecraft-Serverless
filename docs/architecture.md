# Architecture

```
Player ──DNS lookup mc.example.com──▶ Route 53
                                         │ query log (us-east-1)
                                         ▼
                                  CloudWatch Logs
                                         │ subscription filter
                                         ▼
                                  Launcher Lambda ──▶ ECS service desired=1
                                                              │
                                   ┌──────────────────────────┴───────┐
                                   │ Fargate task                     │
                                   │  ├─ minecraft (itzg image) ◀─ EFS│
                                   │  └─ watchdog: sets DNS A record, │
                                   │     scales to 0 when idle        │
                                   └──────────────────────────────────┘
```

Cold start: the first connection attempt fails or times out while the task boots
(about 1–2 min). The player then reconnects, and by then DNS points at the new task's IP.
