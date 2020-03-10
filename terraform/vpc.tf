# first we create the all-private VPC
resource "aws_vpc" "private" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "All-private VPC - ${var.application_environment}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

# next, this VPC will have both private and public subnets
resource "aws_vpc" "combo" {
  cidr_block = "10.2.0.0/16"

  tags = map(
    "Name", "Combo private/public VPC - ${var.application_environment}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

# create some subnets in the all-private VPC
resource "aws_subnet" "private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.private.id

  tags = map(
    "Name", "All-private VPC subnet - ${var.application_environment}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

# create subnets in the combo VPC
resource "aws_subnet" "combo-private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.2.${count.index}.0/24"
  vpc_id            = aws_vpc.combo.id

  tags = {
    Name = "Combo-VPC private subnet - ${var.application_environment}"
  }
}

# create a subnet to use for public purposes
resource "aws_subnet" "combo-public" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.2.3.0/24"
  vpc_id            = aws_vpc.combo.id

  tags = {
    Name = "Combo-VPC public subnet - ${var.application_environment}"
  }
}

# create a peering connection between the two VPCs
resource "aws_vpc_peering_connection" "vpc-peering" {
  peer_vpc_id   = aws_vpc.private.id
  vpc_id        = aws_vpc.combo.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between private and combo VPCs - ${var.application_environment}"
  }
}

# in order to access hosts in the private VPC, create an internet gateway
resource "aws_internet_gateway" "private" {
  vpc_id = aws_vpc.private.id

  tags = {
    Name = "Internet gateway - ${var.application_environment}"
  }
}

# create a route table for the private VPC and associate it with the gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.private.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private.id
  }
}

# associate the route table with the private subnets
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}
