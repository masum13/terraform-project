data "aws_iam_policy_document" "secret_read_only_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.database_username_secretsmanager_secret_arn,
      var.database_password_secretsmanager_secret_arn
    ]
  }
}

