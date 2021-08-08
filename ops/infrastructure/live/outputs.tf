output "vpc_id" {
  value = data.terraform_remote_state.vpc_state.outputs.vpc_id
}

output "public_ip" {
  value = module.aws_ec2.public_ip
}

output "security_group_id" {
  value = module.aws_ec2.security_group_id
}
