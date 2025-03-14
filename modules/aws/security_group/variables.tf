# Tags
variable "project_name" {
  type    = string
  default = null
}

variable "env" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Security Group
variable "security_groups" {
  type = map(object({
    description = string
    vpc_id      = string
    ingress_rules = optional(list(object({
      description = optional(string)
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      sg          = optional(list(string))
    })), [])
    egress_rules = optional(list(object({
      description = optional(string)
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      sg          = optional(list(string))
    })), [])
  }))
  default = {}
}
