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
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  global_config = data.terraform_remote_state.vpc_state.outputs
}

module "aws_ec2" {
  source = "../modules/ec2"

  name_prefix              = "dogs"
  vpc_id                   = local.global_config.vpc_id
  my_public_ip             = jsondecode(data.http.my_public_ip.body).ip
  subnet_id                = element(local.global_config.subnet_ids, 0)
  ssh_local_key_path       = "~/.ssh/aws_key"
  docker_compose_file_path = "${path.module}/../../../docker-compose.prod.rds.yml"
  assigned_security_groups = [module.aws_rds.connection_security_group_id]
  database_url             = module.aws_rds.connection_uri
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
