# Minecraft Serverless

On-demand Minecraft server on AWS. The server runs on ECS Fargate with `desired_count = 0`
and starts only when a player resolves the server hostname. See `docs/architecture.md`.

## Layout

| Path | Purpose |
|---|---|
| `terraform/` | All AWS infrastructure (network, EFS, ECS, Route 53, Lambda, IAM) |
| `lambda/launcher/` | Lambda that starts the ECS service on a DNS query |
| `docker/minecraft/` | Server config + docker-compose for local testing |
| `docker/watchdog/` | Sidecar: updates DNS on start, shuts down when idle |
| `docs/` | Architecture notes |

## Prerequisites
- AWS account + CLI configured
- A domain with a Route 53 hosted zone
- Terraform >= 1.6, Docker
