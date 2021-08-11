output "id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
	value = aws_subnet.subnet.*.id
}

output "availability_zones" {
	value = aws_subnet.subnet.*.availability_zone
}

output "vpc" {
	value = aws_vpc.vpc
}
