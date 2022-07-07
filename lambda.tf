resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_assume.json

  tags = { "Name" = "${local.name_prefix}-lambda-role" }
}

resource "aws_iam_policy" "lambda_s3_access" {
  name   = "${local.name_prefix}-lambda-s3-access"
  policy = data.aws_iam_policy_document.lambda_s3_access.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_attch" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "this" {
  filename         = "${path.module}/files/zips/lambda_function.zip"
  function_name    = local.name_prefix
  runtime          = "python3.8"
  timeout          = "300"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.main.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
