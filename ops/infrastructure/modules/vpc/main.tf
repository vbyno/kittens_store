resource "aws_vpc" "vpc" {
  # Referencing the cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-ig"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.name}-route-table"
  }
}

locals {
  sorted_zones = sort(var.availability_zones)
}
resource "aws_subnet" "subnet" {
  for_each = toset(local.sorted_zones)

  availability_zone = each.key
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, index(local.sorted_zones, each.key) + 1)

  tags = {
    Name = "dogs-subnet-${index(local.sorted_zones, each.key) + 1}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  for_each = aws_subnet.subnet

  route_table_id = aws_route_table.route_table.id
  subnet_id      = each.value.id
}
