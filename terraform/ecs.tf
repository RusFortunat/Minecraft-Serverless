# ECS cluster, task definition and service for the Minecraft server.
# The service sits at desired_count = 0; the launcher Lambda (#9) scales it
# to 1 and the watchdog sidecar (#7) scales it back to 0 when idle.

locals {
  # Reuse the same settings as local docker-compose (docker/minecraft/server.env).
  server_env = {
    for kv in regexall("(?m)^([A-Z_]+)=(.*)$", file("${path.module}/../docker/minecraft/server.env")) :
    kv[0] => trimspace(kv[1])
  }

  whitelist_env = length(var.minecraft_whitelist) == 0 ? {} : {
    ENABLE_WHITELIST  = "true"
    ENFORCE_WHITELIST = "true"
    WHITELIST         = join(",", var.minecraft_whitelist)
  }

  minecraft_env = merge(local.server_env, local.whitelist_env, {
    EULA = "TRUE"
    TYPE = "VANILLA"
    # JVM heap: ~75% of the task memory, leaving room for the JVM and OS.
    MEMORY = "${floor(var.task_memory * 0.75)}M"
    # The EFS access point already enforces uid/gid 1000.
    SKIP_CHOWN_DATA = "true"
  })
}

resource "aws_ecs_cluster" "main" {
  name = var.project_name
}

resource "aws_cloudwatch_log_group" "minecraft" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  volume {
    name = "data"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.minecraft.id
      transit_encryption = "ENABLED" # required by the EFS policy
      authorization_config {
        access_point_id = aws_efs_access_point.minecraft.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "minecraft"
      image     = var.minecraft_image
      essential = true

      portMappings = [{
        containerPort = 25565
        protocol      = "tcp"
      }]

      environment = [
        for k, v in local.minecraft_env : { name = k, value = v }
      ]

      mountPoints = [{
        sourceVolume  = "data"
        containerPath = "/data"
      }]

      # Fargate's maximum: gives the server time to save the world on stop.
      stopTimeout = 120

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.minecraft.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "minecraft"
        }
      }
    },
  ])
}

resource "aws_ecs_service" "minecraft" {
  name             = "minecraft"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.minecraft.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST" # EFS needs 1.4.0+
  desired_count    = 0

  # Never run two tasks at once: both would write the same world on EFS.
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.minecraft.id]
    assign_public_ip = true
  }

  # desired_count is changed at runtime by the Lambda and the watchdog.
  lifecycle {
    ignore_changes = [desired_count]
  }
}
