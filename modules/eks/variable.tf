variable "key_name" {
  description = "Enter ssh key name to access the worker nodes"   // *
}
variable "sg_vpc_id" {
  description = "vpc id for security group"                       // * 
} 
variable "controller_subnet_ids" {
  description = "subnets where controller created"
  type = list(string)                                            // *
}
variable "worker_subnet_ids" {
  description = "subnets where worker nodes get created"
  type = list(string)                                           // *
}
variable "addons" {
  type = list(object({                                          // * 
    name    = string
    version = string
  }))
}

variable "cluster_name" {
  description = "Name of cluster"
  default = "dev-eks-cluster"
}
variable "on_demand_scaling" {
  description = "Scaling configuration for the auto-scaling group"
  default = {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }
}
variable "instance_types_on_demand" {
  description = "Type of Instance specs ex: t2.micro, t2.medium. t2.large in list format"
  type = list(string)
  default = ["t2.medium"]
}
variable "disk_size_on_demand" {
  default = 20
}
variable "endpoint_public_access" {
  description = "all public access for cluster"
  default = true
}

variable "instance_types_spot" {
  type = list(string)
  default = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]
}
variable "disk_size_spot" {
  default = 25
}
variable "spot_scaling" {
  description = "Scaling configuration for the auto-scaling group"
  default = {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }
}

