terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
    key    = "kittens_store/global"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "aws_vpc" {
  source = "../modules/vpc"

  name = "dogs-vpc"
  cidr_block = "10.1.0.0/16"
  availability_zones = data.aws_availability_zones.available.names
}

resource "aws_security_group" "eks_connection_security_group" {
  name_prefix = "eks-connector-"
  description = "Security Group to connect EKS with RDS"
  vpc_id      = module.aws_vpc.id
}

module "aws_eks" {
  source = "../modules/eks"

  name = "kittens"
  vpc_config = module.aws_vpc
  assigned_security_groups = [aws_security_group.eks_connection_security_group.id]
}
