output "vpc_id" {
  value = local.global_config.vpc_id
}

output "ec2_public_ips" {
  value = module.aws_ec2.public_ips
}

output "dns_name" {
  value = module.aws_load_balancer.dns_name
}

output "app_security_groups" {
  value = resource.aws_security_group.app_security_group
}

output "security_group_id" {
  value = module.aws_launch_template.security_group_id
}

output "db_connection_uri" {
  sensitive = true
  value     = module.aws_rds.connection_uri
}
