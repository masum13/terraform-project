resource "aws_iam_role" "ecs_execution_role" {
  name               = "${local.name_prefix}-ecs-task-execution-role"
  description        = "ECS task execution role"
  assume_role_policy = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "0",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.name_prefix}-ecs-task-role"
  description        = "ECS task role"
  assume_role_policy = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "0",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "secret_read_only_policy" {
  name   = "${local.name_prefix}-secret-readonly-policy"
  policy = data.aws_iam_policy_document.secret_read_only_access.json
}

resource "aws_iam_role_policy_attachment" "secret_read_only_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secret_read_only_policy.arn
}