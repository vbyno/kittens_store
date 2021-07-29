output "dogs_vpc_id" {
  value = aws_vpc.dogs_vpc.id
}

output "subnet_ids" {
	value = ["${aws_subnet.dogs_subnet.*.id}"]
}

output "availability_zones" {
	value = ["${aws_subnet.dogs_subnet.*.availability_zone}"]
}
