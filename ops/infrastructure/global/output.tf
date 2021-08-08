output "vpc_id" {
  value = module.aws_vpc.id
}

output "subnet_ids" {
  value = module.aws_vpc.subnet_ids
}
