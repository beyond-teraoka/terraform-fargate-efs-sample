####################
# VPC
####################
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-fargate-efs"
  }
}

####################
# Subnet
####################
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}c"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-public-1c"
  }
}

resource "aws_subnet" "dmz_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-dmz-1a"
  }
}

resource "aws_subnet" "dmz_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}c"
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-dmz-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.30.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-private-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}c"
  cidr_block              = "10.0.31.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-fargate-efs-private-1c"
  }
}

####################
# Route Table
####################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-fargate-efs-public"
  }
}

resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-fargate-efs-dmz"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-fargate-efs-private"
  }
}

####################
# IGW
####################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-fargate-efs"
  }
}

####################
# NATGW
####################
resource "aws_eip" "natgw" {
  vpc = true

  tags = {
    Name = "natgw-fargate-efs"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "natgw-fargate-efs"
  }

  depends_on = [aws_internet_gateway.igw]
}

####################
# Route
####################
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route" "dmz" {
  route_table_id         = aws_route_table.dmz.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
  depends_on             = [aws_route_table.dmz]
}

####################
# Route Association
####################
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "dmz_1a" {
  subnet_id      = aws_subnet.dmz_1a.id
  route_table_id = aws_route_table.dmz.id
}

resource "aws_route_table_association" "dmz_1c" {
  subnet_id      = aws_subnet.dmz_1c.id
  route_table_id = aws_route_table.dmz.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}
