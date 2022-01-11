resource "aws_security_group" "test-rails-app_ecs_security" {
  description = "ECS security group for test-rails-app"
  name        = "test-rails-app_ecs_security"
  vpc_id      = aws_vpc.test-rails-app-vpc.id
}

resource "aws_security_group" "test-rails-app_rds_security" {
  description = "RDS security group for test-rails-app"
  name        = "test-rails-app_rds_security"
  vpc_id      = aws_vpc.test-rails-app-vpc.id
}

/* ALB用 */
resource "aws_security_group" "test-rails-app-alb-sg" {
  description = "ALB security group for test-rails-app"
  name        = "test-rails-app_alb_security_group"
  vpc_id      = aws_vpc.test-rails-app-vpc.id
}