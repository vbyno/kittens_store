output "dogs_vpc_id" {
  value = aws_vpc.dogs_vpc.id
}

output "subnet_ids" {
	value = ["${aws_subnet.dogs_subnet.*.id}"]
}

output "availability_zones" {
	value = ["${aws_subnet.dogs_subnet.*.availability_zone}"]
}

output "public_ip" {
  value = aws_instance.dogs_server.public_ip
}

output "security_group_id" {
	value = aws_security_group.ec2_security_group.id
}
