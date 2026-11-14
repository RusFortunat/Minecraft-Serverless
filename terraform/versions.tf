terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Partial config: bucket, key and region come from backends/<env>.hcl
  #   terraform init -backend-config=backends/staging.hcl
  backend "s3" {
    encrypt      = true
    use_lockfile = true # S3-native locking, no DynamoDB needed
  }
}
