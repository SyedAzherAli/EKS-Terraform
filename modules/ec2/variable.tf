variable "ami" {
  description = "image provided by aws ex: ubuntu, amazon linux, windows etc "
  default = "ami-0dee22c13ea7a9a67" // ubuntu latest 
}
variable "instance_type" {
  description = "Type of Instance specs ex: t2.micro, t2.medium. t2.large"
  default = "t2.micro" 
}
variable "key_name" {
  description = "Name of key pair to access the instance"  // *
}
variable "subnet_id" {
  description = "add subenet id to create the instance in that specific subnet" // *
}
variable "security_group_id" {             
  description = "Enter security groud id"     // *
}
# variable "sg_vpc_id" {
#   description = "add vpc id to create security group in that vpc" // *
# } 
variable "user_data" {
  description = "Enter the file path of script to run"
  default = "default.sh"
}
variable "volume_size" {
  default = 8
}
