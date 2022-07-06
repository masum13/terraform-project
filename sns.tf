resource "aws_sns_topic" "this" {
  name = "${local.name_prefix}-sns-topic"
}