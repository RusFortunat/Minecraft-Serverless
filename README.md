# Minecraft Serverless

On-demand Minecraft server on AWS. The server runs on ECS Fargate with `desired_count = 0`
and starts only when a player resolves the server hostname. See `docs/architecture.md`.

## Layout

| Path | Purpose |
|---|---|
| `terraform/` | All AWS infrastructure (network, EFS, ECS, Route 53, Lambda, IAM) |
| `terraform/bootstrap/` | One-time setup of the S3 bucket that holds Terraform state |
| `terraform/backends/` | Per-environment backend config (`staging`, `prod`) |
| `lambda/launcher/` | Lambda that starts the ECS service on a DNS query |
| `docker/minecraft/` | Server config + docker-compose for local testing |
| `docker/watchdog/` | Sidecar: updates DNS on start, shuts down when idle |
| `docs/` | Architecture notes |

## Prerequisites
- AWS account + CLI configured
- A domain with a Route 53 hosted zone
- Terraform >= 1.10, Docker

## Terraform state setup

Terraform state lives in an S3 bucket, with S3-native locking (no DynamoDB).
That bucket has to exist before Terraform can store state in it, so it is
created by a separate config, `terraform/bootstrap/`, which keeps its own
state locally. Run it once per AWS account:

```sh
cd terraform/bootstrap
terraform init && terraform apply   # prints state_bucket
```

Then point the main config at the bucket, one state file per environment:

```sh
cd terraform
cp backends/staging.hcl.example backends/staging.hcl   # set bucket = state_bucket
terraform init -backend-config=backends/staging.hcl
```

Keep `terraform/bootstrap/terraform.tfstate` safe. It is gitignored, and
if it is lost the bucket must be re-imported before Terraform can manage it.
