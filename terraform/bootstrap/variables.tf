variable "project_name" {
  description = "Prefix used for naming resources"
  type        = string
  default     = "minecraft-serverless"
}

variable "aws_region" {
  description = "Region for the state bucket"
  type        = string
  default     = "eu-central-1"
}
