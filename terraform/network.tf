# Public-only network: the Fargate task gets a public IP so players can reach
# it directly, and it pulls images / calls AWS APIs through the internet
# gateway. No NAT gateway, which keeps the idle cost at zero.

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # required for EFS mount targets by DNS name

  tags = {
    Name = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${local.azs[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group for the Minecraft task: only the game port is open inbound.
resource "aws_security_group" "minecraft" {
  name        = "${var.project_name}-minecraft"
  description = "Minecraft server task"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-minecraft"
  }
}

resource "aws_vpc_security_group_ingress_rule" "minecraft" {
  security_group_id = aws_security_group.minecraft.id
  description       = "Minecraft Java Edition"
  ip_protocol       = "tcp"
  from_port         = 25565
  to_port           = 25565
  cidr_ipv4         = "0.0.0.0/0"
}

# Outbound is needed for image pulls, Mojang downloads and AWS API calls.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.minecraft.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
