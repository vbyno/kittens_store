resource "aws_key_pair" "aws_key" {
  key_name_prefix = "my_aws_key"
  public_key      = trimspace(file("${var.ssh_local_key_path}.pub"))
}

resource "aws_security_group" "ec2_security_group" {
  name_prefix = "${var.name_prefix}_sg"
  description = "Allow SSH from the current machine public IP and HTTP for everyone"
  vpc_id      = var.vpc_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH from Local Machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name_prefix}_security_group"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "init" {
  template = "${file("${path.module}/templates/app_user_data.sh.tpl")}"
  vars = {
    database_url = "${var.database_url}"
  }
}

locals {
  user_data = <<-EOT
#!/bin/bash

yum update -y

# Docker
amazon-linux-extras install docker -y
usermod -a -G docker ec2-user

# Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

service docker start

docker run -d --rm \
  -e DATABASE_URL=${var.database_url} \
  -e RACK_ENV=production \
  -e PORT=3000 \
  -e HOST=0.0.0.0 \
  -p 80:3000 \
  vbyno/kittens-store:1.0.0 sh scripts/serve.sh
EOT
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.aws_key.key_name
  default_version = var.app_version
  user_data = base64encode(local.user_data)
  # user_data = base64encode(data.template_file.init.rendered)

  # vpc_security_group_ids = concat(
  #   [aws_security_group.ec2_security_group.id],
  #   var.assigned_security_groups
  # )
  network_interfaces {
    associate_public_ip_address = true
    security_groups = concat(
      [aws_security_group.ec2_security_group.id],
      var.assigned_security_groups
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-instance"
    }
  }
}
