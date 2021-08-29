locals {
  db_port = 5432
}
resource "random_password" "password" {
  length  = 16
  special = false
  upper = true
}
resource "aws_db_subnet_group" "default" {
  name_prefix = "${var.name}-subnetgroup-"
  subnet_ids = var.global_config.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t3.micro"
  name                 = var.name
  port                 = local.db_port
  identifier_prefix    = "${var.name}-"
  username             = "postgres_user"
  password             = random_password.password.result
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
}


resource "aws_security_group" "connection_security_group" {
  name_prefix = "${var.name}-db-connector-"
  description = "Connection Security Group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}_connection_security_group"
  }
}
resource "aws_security_group" "security_group_db" {
  name_prefix = "${var.name}-sg-db-"
  description = "Allows DB connection to security group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "DB Connection"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    security_groups = [aws_security_group.connection_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.name}_db_security_group"
  }
}
