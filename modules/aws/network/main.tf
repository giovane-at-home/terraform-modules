locals {
  sorted_public_subnet_keys  = sort(keys(var.public_subnets))
  sorted_private_subnet_keys = sort(keys(var.private_subnets))

  only_one_resource = var.only_one_nat ? (
    length(local.sorted_private_subnet_keys) > 0 ?
    { (local.sorted_private_subnet_keys[0]) = var.private_subnets[local.sorted_private_subnet_keys[0]] } : {}
  ) : var.private_subnets
}

# Create VPC
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags = merge(
    {
      "Name" = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-vpc"
    },
    var.tags,
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.availability_zone
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  map_public_ip_on_launch         = true

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-${each.key}"
    },
    var.tags,
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.availability_zone
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  map_public_ip_on_launch         = false

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-${each.key}"
    },
    var.tags,
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-igw"
    },
    var.tags,
  )
}

# Default Route Table (Public)
resource "aws_default_route_table" "this" {
  count = var.create_vpc ? 1 : 0

  default_route_table_id = aws_vpc.this[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  dynamic "route" {
    for_each = length(aws_egress_only_internet_gateway.this) > 0 ? [aws_egress_only_internet_gateway.this[0].id] : []
    content {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = route.value
    }
  }

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-pub-rt"
    },
    var.tags,
  )
}

# Default Route Table Association (Public)
resource "aws_main_route_table_association" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id         = aws_vpc.this[0].id
  route_table_id = aws_default_route_table.this[0].id
}

# Elastic IP
resource "aws_eip" "this" {
  for_each = local.only_one_resource

  domain = "vpc"

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-eip-${each.key}"
    },
    var.tags,
  )
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  for_each = local.only_one_resource

  allocation_id     = aws_eip.this[each.key].id
  connectivity_type = each.value.connectivity_type
  subnet_id         = aws_subnet.public[local.sorted_public_subnet_keys[0]].id

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-natgw-${each.key}"
    },
    var.tags,
  )
}

# Egress Only Internet Gateway
resource "aws_egress_only_internet_gateway" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-eigw"
    },
    var.tags,
  )
}

# Route Table (Private)
resource "aws_route_table" "this" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.this[0].id

  dynamic "route" {
    for_each = coalesce(try(each.value.routes, []), [])
    content {
      cidr_block                = route.value.cidr_block
      ipv6_cidr_block           = route.value.ipv6_cidr_block
      egress_only_gateway_id    = route.value.egress_only_gateway ? aws_egress_only_internet_gateway.this[0].id : ""
      nat_gateway_id            = try((aws_nat_gateway.this[route.value.nat_gateway_id].id), "")
      vpc_peering_connection_id = try((aws_vpc_peering_connection.this[route.value.vpc_peering_connection_id].id), route.value.vpc_peering_connection_id)
    }
  }

  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-priv-rt-${each.key}"
    },
    var.tags,
  )
}

# Route Table Association (Private)
resource "aws_route_table_association" "this" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

# Peering VPC
resource "aws_vpc_peering_connection" "this" {
  for_each = var.vpc_peerings

  vpc_id      = each.value.requester_vpc_id
  peer_vpc_id = each.value.target_vpc_id
  auto_accept = each.value.auto_accept

  tags = merge(
    {
      Name = "${var.env}-${each.key}"
    },
    var.tags,
  )
}

resource "aws_route" "peering_routes" {
  for_each = var.vpc_peerings_routes

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[each.value.peering_key].id

}