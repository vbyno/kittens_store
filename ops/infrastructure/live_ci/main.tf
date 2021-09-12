terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
    key    = "kittens_store/live_ci"
    dynamodb_table = "kittens-store-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "vpc_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-987045484890"
    key    = "kittens_store/global_ci"
    region = "eu-west-3"
    dynamodb_table = "kittens-store-terraform-state-lock"
  }
}

locals {
  global_config = data.terraform_remote_state.vpc_state.outputs
}

module "aws_rds" {
  source = "../modules/rds"

  name          = "kittensdb"
  global_config = local.global_config
  assigned_security_groups = [aws_security_group.eks_connection_security_group.id]
}

module "aws_ecr" {
  source = "../modules/ecr"

  name = "kittens-store"
}

resource "aws_security_group" "eks_connection_security_group" {
  name_prefix = "eks-connector-"
  description = "Security Group to connect EKS with RDS"
  vpc_id      = local.global_config.vpc_id
}

module "aws_eks" {
  source = "../modules/eks"

  name = "kittens"
  vpc_config = local.global_config
  assigned_security_groups = [aws_security_group.eks_connection_security_group.id]
}
