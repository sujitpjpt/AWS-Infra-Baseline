data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # AZ count is derived from the number of public subnet CIDRs supplied,
  # so public/private subnet lists must stay the same length (1 subnet per AZ each).
  az_count = length(var.public_subnet_cidrs)
  # sort() before slice() so the chosen AZs are deterministic across plans —
  # aws_availability_zones is not guaranteed to return names in a stable order.
  azs = slice(sort(data.aws_availability_zones.available.names), 0, local.az_count)

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "sujit"
  }

  # Maps each AZ to its own NAT gateway ID, so private route tables can route
  # egress through the NAT gateway in the same AZ (avoids cross-AZ data transfer cost).
  az_gw_mapping = { for key, value in aws_subnet.public_subnet : value.availability_zone => aws_nat_gateway.nat_gw[key].id }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# for_each (not count) so subnets are keyed by CIDR — reordering the CIDR list
# won't force unrelated subnets to be destroyed/recreated.
resource "aws_subnet" "public_subnet" {
  for_each          = zipmap(var.public_subnet_cidrs, local.azs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-${each.value}"
  })
}

resource "aws_subnet" "private_subnet" {
  for_each          = zipmap(var.private_subnet_cidrs, local.azs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-${each.value}"
  })
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-gw"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-route-table"
  })
}

resource "aws_route_table_association" "public_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# One EIP + NAT gateway per public subnet (per AZ), not one shared NAT gateway.
# Costs more (each NAT gateway is billed hourly) but avoids a cross-AZ single
# point of failure and cross-AZ data transfer charges.
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnet
  domain   = "vpc"
  tags     = merge(local.common_tags, { Name = "${var.project}-${var.environment}-nat-${each.value.availability_zone}" })
}

resource "aws_nat_gateway" "nat_gw" {
  for_each      = aws_subnet.public_subnet
  subnet_id     = each.value.id
  allocation_id = aws_eip.nat_eip[each.key].id
  tags          = merge(local.common_tags, { Name = "${var.project}-${var.environment}-nat-${each.value.availability_zone}" })
}

# One route table per private subnet (not shared) so each can route to the
# NAT gateway in its own AZ via az_gw_mapping.
resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.private_subnet
  vpc_id   = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.az_gw_mapping[each.value.availability_zone]
  }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-route-table-${each.value.availability_zone}"
  })
}

resource "aws_route_table_association" "private_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}
