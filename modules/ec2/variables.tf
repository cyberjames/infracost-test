variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t2.*|^t1.*", var.instance_type))
    error_message = "Error: Instance type must belong to either 't1' or 't2' family."
  }
}

variable "ec2_instance_name" {
  description = "EC2 Instance Name"
  type        = string
  default     = "terraform-standards-ec2"

  validation {
    condition     = length(var.ec2_instance_name) >= 3 && length(var.ec2_instance_name) <= 30
    error_message = "Error: Instance must have a name between 3-30 characters in length."
  }
}

variable "tags" {
  description = "Required Tags to be added to all resources"
  type        = map(any)
  default     = {}
}

variable "subnet_id" {
  description = "EC2 Instance Subnet"
  type        = string
}

variable "ami_owners" {
  description = "List of AMI owners to limit search (e.g., amazon, aws-marketplace, microsoft)"
  type        = list(string)
  default     = ["amazon"]
}

variable "ami_filters" {
  description = "One or more name/value pairs to filter off AMIs"
  type        = list(string)
  default     = ["amzn2-ami-hvm*"]

  validation {
    condition = anytrue([
      for ami_filters in var.ami_filters : can(regex("^amzn2-ami-hvm", ami_filters))
    ])
    error_message = "Error: AMI must be Amazon Linux 2."
  }
}
