# Creating VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags = merge(
    {
      "Name" = var.vpc_name
    },
    var.tags
  )
}

# Creating Subnets - looping through the list of subnets and availablity zones

resource "aws_subnet" "this" {
  count = length(var.subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, { "Name" = "${var.vpc_name}-${element(var.azs, count.index)}" })
}
