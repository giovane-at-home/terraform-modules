# VPC
output "vpc_id" {
  value = try(aws_vpc.this[0].id, "")
}

# Public Subnet
output "public_subnet_id" {
  value = { for k, subnet in aws_subnet.public : k => subnet.id }
}

output "public_subnet_arn" {
  value = { for k, subnet in aws_subnet.public : k => subnet.arn }
}

# Private Subnet
output "private_subnet_id" {
  value = { for k, subnet in aws_subnet.private : k => subnet.id }
}

output "private_subnet_arn" {
  value = { for k, subnet in aws_subnet.private : k => subnet.arn }
}

# IGW
output "igw_id" {
  value = try(aws_internet_gateway.this[0].id, "")
}

# EIGW
output "eigw_id" {
  value = try(aws_egress_only_internet_gateway.this[0].id, "")
}

# EIP
output "eip_public_ip" {
  value = { for k, eip in aws_eip.this : k => eip.public_ip }
}

# NATGW
output "natgw_id" {
  value = { for k, natgw in aws_nat_gateway.this : k => natgw.id }
}

output "natgw_public_ip" {
  value = { for k, natgw in aws_nat_gateway.this : k => natgw.public_ip }
}

# Route Table (Private)
output "route_table_id" {
  value = { for k, rt in aws_route_table.this : k => r.route_table_id}
}

# Peering VPC
output "vpc_peering_id" {
  value = { for k, peering in aws_vpc_peering_connection.this : k => peering.id }
}