resource "aws_key_pair" "aws_key" {
  key_name_prefix = "my_aws_key"
  public_key      = trimspace(file("${var.ssh_local_key_path}.pub"))
}

resource "aws_security_group" "ec2_security_group" {
  name_prefix = "${var.name_prefix}_sg"
  description = "Allow SSH from the current machine public IP and HTTP for everyone"
  vpc_id      = var.vpc_id

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

  ingress {
    description = "HTTP from all over internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_instance" "dogs_server" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  # user_data                   = data.template_file.init.template
  user_data                   = <<-EOT
#!/bin/bash

yum update -y
# Docker
amazon-linux-extras install docker -y
usermod -a -G docker ec2-user
# Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

service docker start

cd /home/ec2-user/app
echo "DATABASE_URL = ${var.database_url}" > ./iplist.log
DATABASE_URL=${var.database_url} docker-compose -f docker-compose.prod.rds.yml up -d
EOT
  associate_public_ip_address = true

  key_name  = aws_key_pair.aws_key.key_name
  subnet_id = var.subnet_id

  vpc_security_group_ids = concat(
    [aws_security_group.ec2_security_group.id],
    var.assigned_security_groups
  )

  tags = {
    Name = "${var.name_prefix}-server"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ~/app"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = trimspace(file(var.ssh_local_key_path))
    }
  }

  provisioner "file" {
    source      = var.docker_compose_file_path
    destination = "~/app/docker-compose.prod.rds.yml"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = trimspace(file(var.ssh_local_key_path))
    }
  }
}
