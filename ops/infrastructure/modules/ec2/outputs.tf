output "public_ips" {
  value = [for ec2 in aws_instance.dogs_server: ec2.public_ip]
}

output "ec2_instance_ids" {
  value = [for ec2 in aws_instance.dogs_server: ec2.id]
}
