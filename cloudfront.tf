resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = aws_lb.this.dns_name
  }
  enabled = true

  default_cache_behavior {
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_lb.this.dns_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cloud_front_min_ttl
    default_ttl            = var.cloud_front_default_ttl
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
  }

  tags = { "Name" = "${local.name_prefix}-cdn" }

}