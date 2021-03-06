resource "aws_lb" "this" {
  name                             = "${local.name_prefix}-alb"
  load_balancer_type               = "application"
  ip_address_type                  = "ipv4"
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

  tags = { "Name" = "${local.name_prefix}-alb" }
}

resource "aws_lb_target_group" "this" {
  name                 = "${local.name_prefix}-tg"
  port                 = 8080
  target_type          = "ip"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.this.id
  deregistration_delay = "60"

  health_check {
    enabled = true
    path    = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  # default_action {
  #   type = "redirect"
  #   redirect {
  #     status_code = "HTTP_301"
  #     port        = 443
  #     protocol    = "HTTPS"
  #     host        = "#{host}"
  #   }
  # }
  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.private_certificate_arn

#   default_action {
#     target_group_arn = aws_lb_target_group.this.arn
#     type             = "forward"
#   }
# }
