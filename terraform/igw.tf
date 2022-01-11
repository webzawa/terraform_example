resource "aws_internet_gateway" "test-rails-app-igw" {
  vpc_id = aws_vpc.test-rails-app-vpc.id

  tags = {
    Name = "test-rails-app-igw"
  }
}