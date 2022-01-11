resource "aws_ecr_repository" "rails-test-rails-app" {
  name = "rails-test-rails-app"
}

resource "aws_ecr_repository" "nginx-test-rails-app" {
  name = "nginx-test-rails-app"
}
