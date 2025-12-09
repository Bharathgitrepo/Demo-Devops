############################
# VPC + Subnets + Routing  #
############################

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    { Name = "${var.name}-vpc" },
    var.tags
  )
}

############################
# Internet Gateway         #
############################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = "${var.name}-igw" },
    var.tags
  )
}

############################
# Public Subnets           #
############################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${var.azs[count.index]}"
      Type = "public"
    },
    var.tags
  )
}

############################
# Private Subnets          #
############################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.name}-private-${var.azs[count.index]}"
      Type = "private"
    },
    var.tags
  )
}

############################
# Public Route Table       #
############################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = "${var.name}-public-rt" },
    var.tags
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

############################
# NAT Gateways (3) + EIPs  #
############################

# One EIP per NAT / AZ
resource "aws_eip" "nat" {
  count  = length(var.public_subnets)
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-nat-eip-${var.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.name}-nat-${var.azs[count.index]}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

############################
# Private Route Tables (3) #
############################

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-private-rt-${var.azs[count.index]}"
    },
    var.tags
  )
}

# Route private traffic to NAT in same AZ
resource "aws_route" "private_nat" {
  count = length(var.private_subnets)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# Associate private subnets with their RT
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}