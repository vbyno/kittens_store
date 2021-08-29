output "vpc_id" {
  value = local.global_config.vpc_id
}

output "public_ip" {
  value = module.aws_ec2.public_ip
}

output "security_group_id" {
  value = module.aws_ec2.security_group_id
}

output "db_connection_uri" {
  sensitive = true
  value = module.aws_rds.connection_uri
}
