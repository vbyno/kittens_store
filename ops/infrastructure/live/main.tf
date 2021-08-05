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
#   source = "../global/modules/vpc"

#   name = "dogs-vpc"
#   cidr_block = "10.1.0.0/16"
#   subnets_number = 3
# }

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-987045484890"
    key    = "kittens_store/global"
    region = "eu-west-3"
  }
}
