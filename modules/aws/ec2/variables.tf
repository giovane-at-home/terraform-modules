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

# EC2
variable "ec2_instances" {
  type = map(object({
    ami_instance                = string
    instance_type               = string
    associate_public_ip_address = option(bool, false)
    sg_id                       = list(string)
    availability_zone           = optional(string)
    subnet_id                   = optional(string)
    key_name                    = optional(string)
    iam_instance_profile        = optional(string)
    hibernation                 = optional(bool, false)
  }))
  default = {}
}