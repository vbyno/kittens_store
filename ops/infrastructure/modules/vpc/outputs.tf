output "id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.subnet : subnet.id]
}

output "availability_zones" {
  value = [for subnet in aws_subnet.subnet : subnet.availability_zone]
}

output "vpc" {
	value = aws_vpc.vpc
}
