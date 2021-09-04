output "public_ips" {
  value = [for ec2 in aws_instance.dogs_server: ec2.public_ip]
}

output "security_group_id" {
  value = aws_security_group.ec2_security_group.id
}

output "ec2_instance_ids" {
  value = [for ec2 in aws_instance.dogs_server: ec2.id]
}
