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
  instance_class       = "db.t2.micro"
  name                 = var.name
  identifier_prefix    = "${var.name}-"
  username             = "postgres_user"
  password             = "postgres_pass"
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.default.name
}
