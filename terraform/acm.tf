/* SSL証明書 */
resource "aws_acm_certificate" "test-rails-app-terraform" {
  domain_name               = "test-rails-app.site"
  subject_alternative_names = ["test-rails-app.site", "*.test-rails-app.site"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "test-rails-app-acm"
  }
}

/* SSL検証 */
resource "aws_route53_record" "test-rails-app-certificate" {
  name    = tolist(aws_acm_certificate.test-rails-app-terraform.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.test-rails-app-terraform.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.test-rails-app-terraform.domain_validation_options)[0].resource_record_value]
  zone_id = aws_route53_zone.test-rails-app-terraform.id
  ttl     = 60
}

/* 検証待機 */
resource "aws_acm_certificate_validation" "test-rails-app-acm" {
  certificate_arn         = aws_acm_certificate.test-rails-app-terraform.arn
  validation_record_fqdns = [aws_route53_record.test-rails-app-certificate.fqdn]
}
