resource "aws_cloudwatch_log_group" "rails" {
  name              = "/ecs/test-rails-app/rails"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/test-rails-app/nginx"
  retention_in_days = 30
}