# Persistent storage for the Minecraft world. The Fargate task is ephemeral,
# so everything under /data lives here and survives task restarts.

resource "aws_efs_file_system" "minecraft" {
  creation_token = "${var.project_name}-data"
  encrypted      = true

  # Bursting is the cheapest mode and fits a small, mostly idle world.
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "${var.project_name}-data"
  }

  # The world lives here; don't let a destroy delete it by accident.
  lifecycle {
    prevent_destroy = true
  }
}

# Policy document is defined in iam.tf.
resource "aws_efs_file_system_policy" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id
  policy         = data.aws_iam_policy_document.efs.json
}

# Daily backups through AWS Backup's default plan (35-day retention).
resource "aws_efs_backup_policy" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id

  backup_policy {
    status = "ENABLED"
  }
}

# One mount target per subnet, so the task can mount EFS in either AZ.
resource "aws_efs_mount_target" "minecraft" {
  count = length(aws_subnet.public)

  file_system_id  = aws_efs_file_system.minecraft.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# The task only ever sees /minecraft on the file system, mounted as /data,
# and every file operation runs as uid/gid 1000 (the image's server user).
resource "aws_efs_access_point" "minecraft" {
  file_system_id = aws_efs_file_system.minecraft.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/minecraft"

    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0755"
    }
  }

  tags = {
    Name = "${var.project_name}-data"
  }
}

# NFS is reachable only from the Minecraft task's security group.
resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs"
  description = "EFS mount targets for the Minecraft world"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_from_minecraft" {
  security_group_id            = aws_security_group.efs.id
  description                  = "NFS from the Minecraft task"
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  referenced_security_group_id = aws_security_group.minecraft.id
}
