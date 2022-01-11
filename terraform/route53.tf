resource "aws_route53_zone" "test-rails-app-terraform" {
  name    = "test-rails-app.site"
  comment = "test-rails-app.site host zone"
}

resource "aws_route53_record" "test-rails-app-terraform-record" {
  zone_id = aws_route53_zone.test-rails-app-terraform.zone_id
  name    = "www.test-rails-app.site"
  type    = "A"

  alias {
    name                   = aws_lb.test-rails-app-alb.dns_name
    zone_id                = aws_lb.test-rails-app-alb.zone_id
    evaluate_target_health = true
  }
}