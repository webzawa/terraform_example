resource "aws_route_table" "test-rails-app_route" {
  vpc_id = aws_vpc.test-rails-app-vpc.id

  route {
    gateway_id = aws_internet_gateway.test-rails-app-igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "test-rails-app_route"
  }
}

resource "aws_route_table_association" "test-rails-app_route_1a" {
  subnet_id      = aws_subnet.test-rails-app_public_subnet1.id
  route_table_id = aws_route_table.test-rails-app_route.id
}

resource "aws_route_table_association" "test-rails-app_route_1c" {
  subnet_id      = aws_subnet.test-rails-app_public_subnet2.id
  route_table_id = aws_route_table.test-rails-app_route.id
}