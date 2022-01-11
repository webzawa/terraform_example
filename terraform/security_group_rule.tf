/* ECSのセキュリティグループのルール */
/* インバウンド */
resource "aws_security_group_rule" "test-rails-app_ecs_security-rule1" {
  description       = "test-rails-app_ecs_security-rule1"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.test-rails-app_ecs_security.id
}

resource "aws_security_group_rule" "test-rails-app_ecs_security-rule3" {
  description              = "test-rails-app_ecs_security-rule3"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.test-rails-app_ecs_security.id
  security_group_id        = aws_security_group.test-rails-app_ecs_security.id
}

resource "aws_security_group_rule" "test-rails-app_ecs_security-rule4" {
  description              = "test-rails-app_ecs_security-rule4"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.test-rails-app-alb-sg.id
  security_group_id        = aws_security_group.test-rails-app_ecs_security.id
}

# SSH用設定 自分のパブリックIPを自動で設定
provider "http" {
  version = "~> 1.1"
}
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}
# 自IP以外に設定したい場合用の変数
variable "allowed-cidr" {
  default = null
}
locals {
  current-ip   = chomp(data.http.ifconfig.body)
  allowed-cidr = (var.allowed-cidr == null) ? "${local.current-ip}/32" : var.allowed-cidr
}
resource "aws_security_group_rule" "test-rails-app_ecs_security-rule5" {
  description       = "test-rails-app_ecs_security-rule5"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.allowed-cidr]
  security_group_id = aws_security_group.test-rails-app_ecs_security.id
}

/* アウトバウンド */
resource "aws_security_group_rule" "test-rails-app_ecs_security-rule2" {
  description       = "test-rails-app_ecs_security-rule2"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test-rails-app_ecs_security.id
}


/* RDSのセキュリティグループのルール */
/* インバウンド */
resource "aws_security_group_rule" "test-rails-app_rds_security-rule1" {
  description              = "test-rails-app_rds_security-rule1"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.test-rails-app_ecs_security.id
  security_group_id        = aws_security_group.test-rails-app_rds_security.id
}
/* アウトバウンド */
resource "aws_security_group_rule" "test-rails-app_rds_security-rule2" {
  description       = "test-rails-app_rds_security-rule2"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test-rails-app_rds_security.id
}


/* ALBのセキュリティグループのルール */
/* インバウンド */
resource "aws_security_group_rule" "test-rails-app-alb-sg-rule2" {
  description       = "test-rails-app-alb-sg-rule2"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.test-rails-app-alb-sg.id
}

resource "aws_security_group_rule" "test-rails-app-alb-sg-rule4" {
  description       = "test-rails-app-alb-sg-rule4"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.test-rails-app-alb-sg.id
}

resource "aws_security_group_rule" "test-rails-app-alb-sg-rule7" {
  description              = "test-rails-app-alb-sg-rule7"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.test-rails-app-alb-sg.id
  security_group_id        = aws_security_group.test-rails-app-alb-sg.id
}

resource "aws_security_group_rule" "test-rails-app-alb-sg-rule8" {
  description              = "test-rails-app-alb-sg-rule8"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.test-rails-app_ecs_security.id
  security_group_id        = aws_security_group.test-rails-app-alb-sg.id
}

/* アウトバウンド */
resource "aws_security_group_rule" "test-rails-app-alb-sg-rule3" {
  description       = "test-rails-app-alb-sg-rule3"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test-rails-app-alb-sg.id
}
