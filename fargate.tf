####################
# Cluster
####################
resource "aws_ecs_cluster" "cluster" {
  name = "cluster-fargate-efs"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

####################
# Task Definition
####################
resource "aws_ecs_task_definition" "task" {
  family                = "task-fargate-wordpress"
  container_definitions = file("tasks/container_definitions.json")
  cpu                   = "256"
  memory                = "512"
  network_mode          = "awsvpc"
  execution_role_arn    = aws_iam_role.fargate_task_execution.arn

  volume {
    name = "fargate-efs"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }

  requires_compatibilities = [
    "FARGATE"
  ]
}

####################
# Service
####################
resource "aws_ecs_service" "service" {
  name             = "service-fargate-efs"
  cluster          = aws_ecs_cluster.cluster.arn
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = "wordpress"
    container_port   = "80"
  }

  network_configuration {
    subnets = [
      aws_subnet.dmz_1a.id,
      aws_subnet.dmz_1c.id
    ]
    security_groups = [
      aws_security_group.fargate.id
    ]
    assign_public_ip = false
  }
}
