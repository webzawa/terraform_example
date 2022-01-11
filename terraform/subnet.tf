resource "aws_subnet" "test-rails-app_public_subnet1" {
  vpc_id                  = aws_vpc.test-rails-app-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-rails-app_public_subnet1"
  }
}

resource "aws_subnet" "test-rails-app_public_subnet2" {
  vpc_id                  = aws_vpc.test-rails-app-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-rails-app_public_subnet2"
  }
}

resource "aws_subnet" "test-rails-app_private_subnet1" {
  vpc_id                  = aws_vpc.test-rails-app-vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-rails-app_private_subnet1"
  }
}

resource "aws_subnet" "test-rails-app_private_subnet2" {
  vpc_id                  = aws_vpc.test-rails-app-vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-rails-app_private_subnet2"
  }
}

resource "aws_db_subnet_group" "test-rails-app_rds_subnet_group" {
  name        = "test-rails-app_rds_subnet_group"
  description = "rds subnet for test-rails-app"
  subnet_ids  = [aws_subnet.test-rails-app_private_subnet1.id, aws_subnet.test-rails-app_private_subnet2.id]
}