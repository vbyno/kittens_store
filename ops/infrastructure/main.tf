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

resource "aws_subnet" "dogs_subnet_01" {
  vpc_id     = aws_vpc.dogs_vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "dogs-subnet-01"
  }
}

resource "aws_subnet" "dogs_subnet_02" {
  vpc_id     = aws_vpc.dogs_vpc.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "dogs-subnet-02"
  }
}

resource "aws_route_table_association" "dogs_route_table_association_01" {
  subnet_id      = aws_subnet.dogs_subnet_01.id
  route_table_id = aws_route_table.dogs_route_table.id
}

resource "aws_route_table_association" "dogs_route_table_association_02" {
  subnet_id      = aws_subnet.dogs_subnet_02.id
  route_table_id = aws_route_table.dogs_route_table.id
}
# resource "aws_subnet" "az" {
#   # Create one subnet for each given availability zone.
#   count = length(var.availability_zones)

#   # For each subnet, use one of the specified availability zones.
#   availability_zone = var.availability_zones[count.index]

#   # By referencing the aws_vpc.main object, Terraform knows that the subnet
#   # must be created only after the VPC is created.
#   vpc_id = aws_vpc.main.id

#   # Built-in functions and operators can be used for simple transformations of
#   # values, such as computing a subnet address. Here we create a /20 prefix for
#   # each subnet, using consecutive addresses for each availability zone,
#   # such as 10.1.16.0/20 .
#   cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index+1)
# }
