data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_filters
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  tags = merge(
    {
      "Name" = var.ec2_instance_name
    },
    var.tags
  )
}
