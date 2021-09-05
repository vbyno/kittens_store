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

module "aws_launch_template" {
  source = "../modules/launch_template"

  name_prefix              = "kittens"
  ssh_local_key_path       = "~/.ssh/aws_key"
  vpc_config               = local.global_config
  docker_compose_file_path = "${path.module}/../../../docker-compose.prod.rds.yml"
  my_public_ip             = chomp(data.http.my_public_ip.body)
  assigned_security_groups = [module.aws_rds.connection_security_group_id, module.aws_load_balancer.security_groups[0]]
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
}
