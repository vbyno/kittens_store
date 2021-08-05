provider "aws" {
  region = var.aws_region
}

module "aws_vpc" {
  source = "../global/modules/vpc"

  name = "dogs-vpc"
  cidr_block = "10.1.0.0/16"
  subnets_number = 3
}
