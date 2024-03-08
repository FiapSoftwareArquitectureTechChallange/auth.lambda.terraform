# VPC creation

resource "aws_vpc" "burgerroyale_auth_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "burgerroyale_auth_vpc"
  }
}

# Public subnets creation

resource "aws_subnet" "burgerroyale_auth_public_subnet_1" {
  vpc_id            = aws_vpc.burgerroyale_auth_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "burgerroyale_auth_public_subnet_1"
  }
}

resource "aws_subnet" "burgerroyale_auth_public_subnet_2" {
  vpc_id            = aws_vpc.burgerroyale_auth_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "burgerroyale_auth_public_subnet_2"
  }
}

# Private subnets creation

resource "aws_subnet" "burgerroyale_auth_private_subnet_1" {
  vpc_id            = aws_vpc.burgerroyale_auth_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "burgerroyale_auth_private_subnet_1"
  }
}

resource "aws_subnet" "burgerroyale_auth_private_subnet_2" {
  vpc_id            = aws_vpc.burgerroyale_auth_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "burgerroyale_auth_private_subnet_2"
  }
}

# Internet Gateway creation

resource "aws_internet_gateway" "burgerroyale_auth_internet_gateway" {
  vpc_id = aws_vpc.burgerroyale_auth_vpc.id
  tags = {
    Name = "burgerroyale_auth_internet_gateway"
  }
}

# NAT Gateway creation

resource "aws_eip" "burgerroyale_auth_elastic_ip" {
  tags = {
    Name = "burgerroyale_auth_elastic_ip"
  }
}

resource "aws_nat_gateway" "burgerroyale_auth_nat_gateway" {
  subnet_id     = aws_subnet.burgerroyale_auth_public_subnet_1.id
  allocation_id = aws_eip.burgerroyale_auth_elastic_ip.id
  tags = {
    Name = "burgerroyale_auth_nat_gateway"
  }
}

# Main route table edit

resource "aws_default_route_table" "burgerroyale_auth_main_route_table" {
  default_route_table_id = aws_vpc.burgerroyale_auth_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.burgerroyale_auth_nat_gateway.id
  }

  tags = {
    Name = "burgerroyale_auth_main_route_table"
  }
}

# Public route table creation

resource "aws_route_table" "burgerroyale_auth_public_route_table" {
  vpc_id = aws_vpc.burgerroyale_auth_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.burgerroyale_auth_internet_gateway.id
  }

  tags = {
    Name = "burgerroyale_auth_public_route_table"
  }
}

resource "aws_route_table_association" "burgerroyale_auth_public_route_table_association_1" {
  route_table_id = aws_route_table.burgerroyale_auth_public_route_table.id
  subnet_id      = aws_subnet.burgerroyale_auth_public_subnet_1.id
}

resource "aws_route_table_association" "burgerroyale_auth_public_route_table_association_2" {
  route_table_id = aws_route_table.burgerroyale_auth_public_route_table.id
  subnet_id      = aws_subnet.burgerroyale_auth_public_subnet_2.id
}

# Default security group edit

resource "aws_default_security_group" "burgerroyale_auth_default_security_group" {

  vpc_id = aws_vpc.burgerroyale_auth_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "burgerroyale_auth_default_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "burgerroyale_auth_default_security_group" {
  security_group_id = aws_vpc.burgerroyale_auth_vpc.default_security_group_id

  cidr_ipv4   = var.myIP
  ip_protocol = "-1"
}