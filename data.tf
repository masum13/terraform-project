data "aws_iam_policy_document" "secret_read_only_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    # resources = ["*"]
    resources = [
      # var.database_username_secretsmanager_secret_arn,
      aws_secretsmanager_secret.rds_password.arn
    ]
  }
}

// Lambda

data "template_file" "lambda" {
  template = file("${path.module}/templates/lambda_function.py.tpl")

  vars = {
  }
}

data "archive_file" "main" {
  type        = "zip"
  output_path = "${path.module}/files/zips/lambda_function.zip"

  source {
    content  = data.template_file.lambda.rendered
    filename = "lambda_function.py"
  }
}

data "aws_iam_policy_document" "lambda_role_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "lambda_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl",
      "s3:GetBucketLocation",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.name_prefix}-assets-bucket",
      "arn:aws:s3:::${local.name_prefix}-assets-bucket/*"
    ]
  }
}

