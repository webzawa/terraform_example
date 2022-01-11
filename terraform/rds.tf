resource "aws_db_parameter_group" "test-rails-app-db-parameter" {
  name   = "test-rails-app-db-parameter"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "test-rails-app-db" {
  engine         = "MySQL"
  engine_version = "8.0.21"

  identifier = "test-rails-app-db"
  name       = "maxiceli_shift_production"

  username       = "root"
  password       = "foobar"
  instance_class = "db.t2.micro"

  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 1000

  db_subnet_group_name   = aws_db_subnet_group.test-rails-app_rds_subnet_group.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.test-rails-app_rds_security.id]

  backup_retention_period = 7
  skip_final_snapshot     = true

}
