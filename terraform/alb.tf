
/* alb */
resource "aws_lb" "test-rails-app-alb" {
  name                       = "test-rails-app-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.test-rails-app_public_subnet1.id,
    aws_subnet.test-rails-app_public_subnet2.id
  ]

  security_groups = [
    aws_security_group.test-rails-app-alb-sg.id
  ]

  tags = {
    Name = "test-rails-app-alb"
  }
}

resource "time_sleep" "wait_n_seconds_for_alb" {
  depends_on      = [aws_acm_certificate_validation.test-rails-app-acm]
  create_duration = "120s"
}

/* listener */
resource "aws_lb_listener" "test-rails-app-http-listener" {
  depends_on = [time_sleep.wait_n_seconds_for_alb]

  load_balancer_arn = aws_lb.test-rails-app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "test-rails-app-https-listener" {
  depends_on = [aws_lb_listener.test-rails-app-http-listener]

  load_balancer_arn = aws_lb.test-rails-app-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.test-rails-app-terraform.arn

  default_action {
    target_group_arn = aws_lb_target_group.test-rails-app-alb-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "test-rails-app-alb-tg" {
  depends_on = [aws_lb.test-rails-app-alb]

  name = "test-rails-app-alb-tg"
  # target_type = "ip"
  target_type = "instance"
  vpc_id      = aws_vpc.test-rails-app-vpc.id
  port        = 80
  protocol    = "HTTP"

}
