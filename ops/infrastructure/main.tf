provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "dogs_vpc" {
  # Referencing the cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.cidr_block

  tags = {
    Name = "dogs-shop-vpc"
  }
}

resource "aws_internet_gateway" "dogs_ig" {
  vpc_id = aws_vpc.dogs_vpc.id

  tags = {
    Name = "dogs-ig"
  }
}

resource "aws_route_table" "dogs_route_table" {
  vpc_id = aws_vpc.dogs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dogs_ig.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  # }

  tags = {
    Name = "dogs-route-table"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dogs_subnet" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id     = aws_vpc.dogs_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 1)

  tags = {
    Name = "dogs-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "dogs_route_table_association" {
  count = length(aws_subnet.dogs_subnet)

  route_table_id = aws_route_table.dogs_route_table.id
  subnet_id      = element(aws_subnet.dogs_subnet, count.index).id
}
