# VPC
output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "default_vpc_sg" {
  value = aws_vpc.this.default_security_group_id
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
  value = aws_internet_gateway.this.id
}

output "igw_arn" {
  value = aws_internet_gateway.this.arn
}

# EIGW
output "eigw_id" {
  value = aws_egress_only_internet_gateway.this
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

# 
