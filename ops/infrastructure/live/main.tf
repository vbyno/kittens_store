terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "vpc_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-987045484890"
    key    = "kittens_store/global"
    region = "eu-west-3"
  }
}

data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
  # url = "https://ifconfig.co/json"
  # request_headers = {
  #   Accept = "application/json"
  # }
}

locals {
  global_config = data.terraform_remote_state.vpc_state.outputs
}

resource "aws_security_group" "app_security_group" {
  name_prefix = "kittens-connector-"
  description = "A security group to connect all the instances"
  vpc_id      = local.global_config.vpc_id

  ingress {
    description      = "HTTP from outside world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "kittens-connector-sg"
  }
}

module "aws_launch_template" {
  source = "../modules/launch_template"

  name_prefix              = "kittens"
  ssh_local_key_path       = "~/.ssh/aws_key"
  vpc_config               = local.global_config
  docker_compose_file_path = "${path.module}/../../../docker-compose.prod.rds.yml"
  my_public_ip             = chomp(data.http.my_public_ip.body)
  assigned_security_groups = [module.aws_rds.connection_security_group_id,
                              resource.aws_security_group.app_security_group.id]
  database_url             = module.aws_rds.connection_uri
}

module "aws_ec2" {
  source = "../modules/ec2"

  name_prefix              = "kittens"
  instances_number         = 1
  vpc_config               = local.global_config
  launch_template_id = module.aws_launch_template.launch_template_id
}

module "aws_autoscaler" {
  source = "../modules/auto_scaler"

  vpc_config         = local.global_config
  launch_template_id = module.aws_launch_template.launch_template_id
  desired_capacity   = 0
  min_size           = 0
}

module "aws_rds" {
  source = "../modules/rds"

  name = "kittensdb"
  global_config = local.global_config
}
module "aws_ecr" {
  source = "../modules/ecr"

  name = "kittens-store"
}

module "aws_load_balancer" {
  source = "../modules/load_balancer"

  name = "kittens-store"
  vpc_config = local.global_config
  ec2_instance_ids = module.aws_ec2.ec2_instance_ids
  autoscaling_group_ids = [module.aws_autoscaler.autoscaling_group_id]
  assigned_security_groups = [aws_security_group.app_security_group.id]
}
