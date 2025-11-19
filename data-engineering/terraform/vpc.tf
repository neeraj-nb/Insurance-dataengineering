# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "redshift-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "redshift-igw" })
}

# Public subnets (one per AZ)
resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)  # /24 if vpc is /16
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "redshift-${var.public_subnet_suffix}-${local.azs[count.index]}"
  })
}

# Private subnets (one per AZ)
resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.azs)) # next /24s
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "redshift-${var.private_subnet_suffix}-${local.azs[count.index]}"
  })
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "redshift-public-rt" })
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways (one per AZ)
resource "aws_eip" "nat" {
  count = length(local.azs)
  domain = "vpc"
  tags = merge(var.tags, { Name = "redshift-nat-eip-${local.azs[count.index]}" })
}

# NAT Gateways in each public subnet
resource "aws_nat_gateway" "nat" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, { Name = "redshift-nat-${local.azs[count.index]}" })
}

# Private route tables (one per AZ) that route internet via NAT gateway in same AZ
resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(var.tags, { Name = "redshift-private-rt-${local.azs[count.index]}" })
}

# Associate private subnets to their route tables
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
