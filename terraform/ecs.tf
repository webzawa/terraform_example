
resource "time_sleep" "wait_n_seconds_for_ecs" {
  depends_on      = [aws_acm_certificate_validation.test-rails-app-acm, aws_lb_target_group.test-rails-app-alb-tg]
  create_duration = "300s"
}

# instance profile
resource "aws_iam_instance_profile" "ec2_container_service" {
  name = "es2_container_service"
  role = "ecsInstanceRole"
}

# ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_role_attach" {
  role       = "ecsInstanceRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS用に最適化されたAMIのデータ
data "aws_ami" "ecs" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20211209-x86_64-ebs"]
  }
  owners = ["amazon"]
}

# launch configuration
resource "aws_launch_configuration" "ecs" {
  name_prefix   = "ecs-launch-tf-"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t2.micro"

  security_groups      = [aws_security_group.test-rails_ecs_security.id]
  enable_monitoring    = true
  iam_instance_profile = aws_iam_instance_profile.ec2_container_service.name

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=test-rails-app-cluster >> /etc/ecs/ecs.config;
    EOF

  associate_public_ip_address = false

  key_name = "maxiceli-shift"

  lifecycle {
    create_before_destroy = true
  }
}

# auto scalingグループの設定
# この設定でEC2が立ち上がる。
resource "aws_autoscaling_group" "ecs" {
  name             = "ecs-tf-asg"
  min_size         = 1
  max_size         = 2
  desired_capacity = 2

  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = [aws_subnet.test-rails-app_public_subnet1.id, aws_subnet.test-rails-app_public_subnet2.id]

  protect_from_scale_in = true

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  # 自動的に付与されるタグだがTerraformの場合明記する必要がある。
  tags = [
    {
      key                 = "AmazonECSManaged"
      propagate_at_launch = true
    }
  ]
}

resource "aws_ecs_capacity_provider" "main" {
  name = "main"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

# クラスターの定義
resource "aws_ecs_cluster" "main" {
  depends_on = [time_sleep.wait_n_seconds_for_ecs]

  # name               = "${local.app_name}-cluster"
  name               = "test-rails-app-cluster"
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
    base              = 1
  }
}

resource "aws_ecs_service" "main" {
  name = "test-rails-app-service"

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
    base              = 1
  }

  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.test-rails-app.arn
  health_check_grace_period_seconds = 60

  desired_count                      = 2
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = aws_lb_target_group.test-rails-app-alb-tg.arn
    container_name   = "nginx"
    container_port   = "80"
  }

}

/* タスク定義 */
resource "aws_ecs_task_definition" "test-rails-app" {
  family                   = "test-rails-app"
  cpu                      = "512"
  memory                   = "512"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = templatefile("./test-rails-app_definitions.json", {
    rails_master_key           = "0123456789",
    stripe_pro_publishable_key = "foobar",
    stripe_pro_secret_key      = "foobar",
    db_name                    = "foobar",
    db_password                = "foobar",
    db_hostname                = "foobar",
    db_username                = "foobar",
    rails_env                  = "production",
    rails_serve_static_files   = "true",
  })


  volume {
    name = "sockets"
    docker_volume_configuration {
      scope         = "task"
      autoprovision = null
      driver        = "local"
      driver_opts   = null
    }
  }
}

/* タスク実行ロール*/
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}
