variable "dns_hostnames" {
  description = "set true to access the instance using dns instade of ip"
  default = true
}
variable "cidr_block" {
  description = "vpc cidr block"
  default = "172.31.0.0/16"
}
variable "cidr_block_sub01" {
  description = "first subnet cidr"
  default = "172.31.0.0/20"
}
variable "cidr_block_sub02" {
  description = "second subnet cidr"
  default = "172.31.16.0/20"
}
variable "cidr_block_sub03" {
  description = "three subnet cidr"
  default = "172.31.32.0/20"
}
variable "cidr_block_sub04" {
  description = "four subnet cidr"
  default = "172.31.48.0/20"
}
