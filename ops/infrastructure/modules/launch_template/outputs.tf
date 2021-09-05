output "launch_template_id" {
  value = aws_launch_template.app_template.id
}

output "security_group_id" {
  value = aws_security_group.ec2_security_group.id
}
