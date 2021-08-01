provider "aws" {
  region = var.aws_region
}

module "aws-vpc" {
  source = "./modules/vpc"
}

resource "aws_key_pair" "aws_key" {
  key_name_prefix = "my_aws_key"
  public_key      = trimspace(file("~/.ssh/aws_key.pub"))
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_security_group" "ec2_security_group" {
  name_prefix = "dogs_ec2_sg"
  description = "Allow SSH from the current machine public IP and HTTP for everyone"
  vpc_id      = module.aws-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH from Local Machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${jsondecode(data.http.my_public_ip.body).ip}/32"]
    # ipv6_cidr_blocks = [aws_vpc.dogs_vpc.ipv6_cidr_block]
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
    Name = "ec2_security_group"
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

  owners = ["amazon"] # Canonical
}

data "template_file" "init" {
  template = file("${path.module}/templates/app_user_data.sh.tpl")
}

resource "aws_instance" "dogs_server" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  user_data                   = data.template_file.init.template
  associate_public_ip_address = true

  key_name  = aws_key_pair.aws_key.key_name
  subnet_id = element(module.aws-vpc.subnet_ids, 0)

  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]

  tags = {
    Name = "dogs-server"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ~/app"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = trimspace(file("~/.ssh/aws_key"))
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../docker-compose.prod.yml"
    destination = "~/app/docker-compose.prod.yml"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = trimspace(file("~/.ssh/aws_key"))
    }
  }
}
