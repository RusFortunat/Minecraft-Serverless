output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "minecraft_security_group_id" {
  value = aws_security_group.minecraft.id
}

output "efs_file_system_id" {
  value = aws_efs_file_system.minecraft.id
}

output "efs_access_point_id" {
  value = aws_efs_access_point.minecraft.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.minecraft.name
}

# output "server_address" {
#   value = "${var.server_subdomain}.${var.domain_name}"
# }
