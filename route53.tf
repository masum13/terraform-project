// ACM certificate

# resource "aws_acm_certificate" "this" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#   tags = { Name = "${local.name_prefix}-acm-cert",
#   Domain_name = var.domain_name }
# }

resource "aws_route53_zone" "this" {
  name          = var.domain_name
  force_destroy = false
  tags          = { Name = "${local.name_prefix}-hosted-zone" }
}

resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.route53_record_name
  type    = "A"

  dynamic "alias" {
    for_each = [true]
    content {
      name                   = aws_lb.this.dns_name
      zone_id                = aws_lb.this.zone_id
      evaluate_target_health = true
    }
  }
  depends_on = [aws_route53_zone.this, aws_lb.this]
}

# resource "aws_route53_record" "acm" {
#   for_each = {
#     for d in aws_acm_certificate.this.domain_validation_options : d.domain_name => {
#       name   = d.resource_record_name
#       record = d.resource_record_value
#       type   = d.resource_record_type
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.this.zone_id
#   depends_on      = [aws_route53_zone.this, aws_acm_certificate.this]
# }