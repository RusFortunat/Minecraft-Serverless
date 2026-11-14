variable "project_name" {
  description = "Prefix used for naming resources"
  type        = string
  default     = "minecraft-serverless"
}

variable "aws_region" {
  description = "Region where the ECS cluster and EFS run"
  type        = string
  default     = "eu-central-1"
}

variable "domain_name" {
  description = "Hosted zone domain, e.g. example.com"
  type        = string
}

variable "server_subdomain" {
  description = "Subdomain players connect to, e.g. mc -> mc.example.com"
  type        = string
  default     = "mc"
}

variable "minecraft_image" {
  description = "Container image for the Minecraft server"
  type        = string
  default     = "itzg/minecraft-server:latest"
}

variable "task_cpu" {
  type    = number
  default = 1024
}

variable "task_memory" {
  type    = number
  default = 4096
}

variable "shutdown_idle_minutes" {
  description = "Minutes with zero players before the watchdog stops the server"
  type        = number
  default     = 10
}
