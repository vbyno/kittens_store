terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = var.aws_region
}

# module "aws_vpc" {
#   source = "../modules/vpc"

#   name = "dogs-vpc"
#   cidr_block = "10.1.0.0/16"
#   subnets_number = 3
# }

module "aws_ecr" {
  source = "../modules/ecr"

  name = "kittens_ecr"
}
