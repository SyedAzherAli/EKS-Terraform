output "public_ip" {
  value = aws_instance.EC2Instance.public_ip
}
output "private_ip" {
  value = aws_instance.EC2Instance.private_ip
}