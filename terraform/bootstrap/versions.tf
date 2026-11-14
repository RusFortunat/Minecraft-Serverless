terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Intentionally local state: this config creates the bucket that the
  # main config stores its state in. Run once per AWS account.
}
