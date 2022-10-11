variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "contino"

  validation {
    condition     = length(var.vpc_name) >= 3 && length(var.vpc_name) <= 30
    error_message = "Error: VPC must have a name between 3-30 characters in length."
  }
}

variable "tags" {
  description = "Required Tags to be added to all resources"
  type        = map(any)
  default     = {}
}

variable "vpc_cidr_block" {
  description = "VPC CIDR blocks"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 32))
    error_message = "Error: Invalid VPC CIDR block provided."
  }
}

variable "vpc_enable_dns_support" {
  description = "VPC Enable DNS support"
  type        = bool
  default     = true

  validation {
    condition     = can(regex("^true|^false", var.vpc_enable_dns_support))
    error_message = "Error: Invalid input, options: \"true\", \"false\"."
  }
}

variable "vpc_enable_dns_hostnames" {
  description = "VPC Enable DNS hostnames"
  type        = bool
  default     = true

  validation {
    condition     = can(regex("^true|^false", var.vpc_enable_dns_hostnames))
    error_message = "Error: Invalid input, options: \"true\", \"false\"."
  }
}

variable "subnets" {
  description = "List of subnets to create"
  type        = list(string)
}

variable "azs" {
  description = "availablity zone to attach subnet"
  type        = list(string)

  validation {
    condition = alltrue([
      for azs in var.azs : can(regex("[a-z][a-z]-[a-z]+-[1-9]", azs))
    ])
    error_message = "Error: Invalid AWS region provided."
  }
}
