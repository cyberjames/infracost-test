module "vpc" {
  source                   = "./modules/vpc"
  vpc_cidr_block           = "10.12.0.0/16"
  vpc_enable_dns_support   = "true"
  vpc_enable_dns_hostnames = "true"
  vpc_name                 = "terraform_standards_vpc"
  azs                      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  subnets                  = ["10.12.1.0/24", "10.12.2.0/24", "10.12.3.0/24"]
  tags                     = var.tags
}

module "ec2_instance" {
  source            = "./modules/ec2"
  instance_type     = "t2.small"
  subnet_id         = module.vpc.subnet_ids[0]
  ec2_instance_name = "terraform-standards-ec2"
  tags              = var.tags
}
