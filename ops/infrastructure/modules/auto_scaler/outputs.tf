output "autoscaling_group_id" {
  value = aws_autoscaling_group.app_autoscaling_group.id
  # value = [for ec2 in aws_instance.dogs_server: ec2.public_ip]
}
