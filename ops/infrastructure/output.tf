output "dogs_vpc_id" {
  value = aws_vpc.dogs_vpc.id
}

output "subnet_ids" {
	value = [
		aws_subnet.dogs_subnet_01.id,
		aws_subnet.dogs_subnet_02.id
	]
}

output "availability_zones" {
	value = [
		aws_subnet.dogs_subnet_01.availability_zone,
		aws_subnet.dogs_subnet_02.availability_zone
	]
}
