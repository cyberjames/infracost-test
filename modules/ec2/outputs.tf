output "ec2_id" {
  value = aws_instance.this.id
}
output "ec2_private_ip" {
  value = aws_instance.this.private_ip
}
