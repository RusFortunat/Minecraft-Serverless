output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "minecraft_security_group_id" {
  value = aws_security_group.minecraft.id
}

# output "server_address" {
#   value = "${var.server_subdomain}.${var.domain_name}"
# }
