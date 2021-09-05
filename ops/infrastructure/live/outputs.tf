output "vpc_id" {
  value = local.global_config.vpc_id
}

output "public_ip" {
  value = element(module.aws_ec2.public_ips, 0)
}

output "dns_name" {
  value = module.aws_load_balancer.dns_name
}

output "lb_security_groups" {
  value = module.aws_load_balancer.security_groups
}

output "security_group_id" {
  value = module.aws_ec2.security_group_id
}

output "db_connection_uri" {
  sensitive = true
  value = module.aws_rds.connection_uri
}
