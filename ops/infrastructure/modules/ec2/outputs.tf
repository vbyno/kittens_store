output "public_ip" {
  value = aws_instance.dogs_server.public_ip
}

output "security_group_id" {
  value = aws_security_group.ec2_security_group.id
}
