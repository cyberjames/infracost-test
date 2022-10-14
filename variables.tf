variable "aws_account_credentials" {
  description = "AWS Account Credentials"
  type = object({
    region     = string
    access_key = string
    secret_key = string
    token      = string
  })
}

variable "tags" {
  description = "Required Tags to be added to all resources"
  type        = map(any)
  default = {
    Environment = "Development"
    Owner       = "Contino"
  }
}
