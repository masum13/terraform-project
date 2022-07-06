## Cloudwatch log group
resource "aws_cloudwatch_log_group" "main" {
  name = "${local.name_prefix}-logs"
}

## ECS cluster

resource "aws_ecs_cluster" "this" {
  name = local.name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# container definition 
data "template_file" "container_definition" {
  template = file("${path.module}/container-definition/container-definition.json.tpl")

  vars = {
    container_name   = ""
    container_image  = var.container_image
    container_memory = var.container_memory
    container_cpu    = var.container_cpu
    command          = ""

    database_username_secretsmanager_secret_arn = var.database_username_secretsmanager_secret_arn
    database_password_secretsmanager_secret_arn = var.database_password_secretsmanager_secret_arn
    database_name                               = var.database_name

    web_ui_port          = "8080"
    awslogs_group        = "${local.name_prefix}-logs"
    awslog_stream_prefix = "${local.name_prefix}"
    region               = var.region
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${local.name_prefix}-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = data.template_file.container_definition.rendered
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
}

## ECS service 
resource "aws_ecs_service" "this" {
  name             = local.name_prefix
  cluster          = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = "1"
  network_configuration {
    subnets = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
    security_groups = [
      aws_security_group.ecs_sg.id
    ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = ""
    container_name   = var.container_name
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${local.name_prefix}/${var.container_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  name               = "${local.name_prefix}-asg-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 500
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}