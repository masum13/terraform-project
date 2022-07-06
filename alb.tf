resource "aws_lb" "this" {
  name                             = "${local.name_prefix}-alb"
  load_balancer_type               = "application"
  ip_address_type                  = "ipv4"
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
  security_groups                  = aws_security_group.alb_sg.id
  subnets = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id,aws_subnet.public_subnet_3.id]

  access_logs {
    bucket  = "${local.name_prefix}-lb-access-logs-bucket"
    prefix  = "${local.name_prefix}-alb"
    enabled = true
  }

  tags = merge(local.tags, { "Name" = "${local.name_prefix}-alb" })
}

resource "aws_lb_target_group" "this" {
  name                 = "${local.name_prefix}-tg"
  port                 = 8080
  target_type          = "ip"
  protocol             = "TCP"
  vpc_id               = aws_vpc.this.id
  deregistration_delay = "60"

  health_check {
    enabled = true
    path    = "/"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  redirect {
      status_code = "HTTP_301"
      port        = 443
      protocol    = "HTTPS"
      host        = "#{host}"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.private_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
