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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet" {
  count = var.subnets_number

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 1)

  tags = {
    Name = "dogs-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count = length(aws_subnet.subnet)

  route_table_id = aws_route_table.route_table.id
  subnet_id      = element(aws_subnet.subnet, count.index).id
}
