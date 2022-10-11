# outputs produced at the end of a terraform apply
output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = aws_subnet.this.*.id
}

output "cidr_blocks" {
  value = aws_subnet.this.*.cidr_block
}
