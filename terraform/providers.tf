provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

# Route 53 query logging only delivers to CloudWatch Logs in us-east-1,
# so the query log group and the launcher Lambda live there.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
