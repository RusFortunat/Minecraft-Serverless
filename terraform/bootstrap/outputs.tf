output "state_bucket" {
  description = "Put this in terraform/backends/<env>.hcl as `bucket`"
  value       = aws_s3_bucket.tfstate.bucket
}
