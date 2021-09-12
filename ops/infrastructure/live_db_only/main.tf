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

locals {
  global_config = data.terraform_remote_state.vpc_state.outputs
}

module "aws_rds" {
  source = "../modules/rds"

  name          = "kittensdb"
  global_config = local.global_config
  assigned_security_groups = [local.global_config.eks_connection_security_group_id]
}
