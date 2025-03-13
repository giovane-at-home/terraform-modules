# Tags
variable "project_name" {
  description = "..."
  type        = string
  default     = null
}

variable "env" {
  description = "...."
  type        = string
  default     = null
}

variable "tags" {
  description = "..."
  type        = map(string)
  default     = {}
}

# VPC
variable "vpc_cidr" {
  description = "..."
  type        = string
}

variable "instance_tenancy" {
  description = "..."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "..."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "..."
  type        = bool
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "..."
  type        = bool
  default     = false
}

# Public Subnet
variable "public_subnets" {
  description = "..."
  type = map(object({
    cidr_block                      = string
    availability_zone               = string
    assign_ipv6_address_on_creation = optional(bool)
    ipv6_cidr_block                 = optional(string)
  }))
}

# Private Subnet / Nat Gateway / Private Routes
variable "private_subnets" {
  description = "..."
  type = map(object({
    cidr_block                      = string
    availability_zone               = string
    assign_ipv6_address_on_creation = optional(bool)
    ipv6_cidr_block                 = optional(string)
    connectivity_type               = optional(string) # NAT
    # pub_subnet_key                  = optional(string) # NAT
    routes = optional(list(object({ # RT Routes
      cidr_block                = optional(string)
      ipv6_cidr_block           = optional(string)
      egress_only_gateway       = optional(bool, false)
      nat_gateway_id            = optional(string)
      vpc_peering_connection_id = optional(string)
    })), [])
  }))
  default = {}
}

variable "only_one_nat" {
  description = "..."
  type        = bool
  default     = false
}

# Peering Connection
