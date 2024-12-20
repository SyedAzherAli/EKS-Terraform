output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}
output "pub_subnet01_id" {
  value = aws_subnet.custom_subnet01.id      // public
}
output "pub_subnet02_id" {
  value = aws_subnet.custom_subnet02.id     // public
}
output "pvt_subnet01_id" {
  value = aws_subnet.custom_subnet03.id
}
output "pvt_subnet02_id" {
  value = aws_subnet.custom_subnet04.id
}
