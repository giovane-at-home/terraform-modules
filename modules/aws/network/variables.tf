# Tags
variable "project_name" {
  description = "Project name"
  type        = string
  default     = null
}

variable "env" {
  description = "Environment"
  type        = string
  default     = null
}

variable "tags" {
  description = "General tags"
  type        = map(string)
  default     = {}
}

# VPC
variable "vpc_cidr" {
  description = "CIDR from VPC"
  type        = string
}

variable "instance_tenancy" {
  description = "Instance Tenancy of VPC: [dedicated] or [default]"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Enable VPC DNS support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable VPC DNS hostnames"
  type        = bool
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
  type        = bool
  default     = false
}

# Public Subnet
variable "public_subnets" {
  description = "Create public subnets"
  type = map(object({
    cidr_block                      = string
    availability_zone               = string
    assign_ipv6_address_on_creation = optional(bool)
    ipv6_cidr_block                 = optional(string)
  }))
}

# Private Subnet / Nat Gateway / Private Routes
variable "private_subnets" {
  description = "Create private subnets"
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
  description = "Create only 1 NAT and 1 EIP"
  type        = bool
  default     = false
}


