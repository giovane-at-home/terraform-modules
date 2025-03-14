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

# Security Group
variable "security_groups" {
  description = "Security Groups config"
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
