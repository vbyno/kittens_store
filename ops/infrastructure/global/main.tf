provider "aws" {
  region = var.aws_region
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

# module "aws_vpc" {
#   source = "./modules/vpc"

#   name = "dogs-vpc"
#   cidr_block = "10.1.0.0/16"
#   subnets_number = 3
# }

# module "aws_ec2" {
#   source = "./modules/app_instance"

#   name_prefix = "dogs"
#   vpc_id = module.aws_vpc.id
#   my_public_ip = jsondecode(data.http.my_public_ip.body).ip
#   subnet_id = element(module.aws_vpc.subnet_ids, 0)
#   ssh_local_key_path = "~/.ssh/aws_key"
#   docker_compose_file_path = "${path.module}/../../docker-compose.prod.yml"
# }
