provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "security_group" {  // allowed all traffic from testing purpose
  source = "./modules/security_group"
  
  sg_vpc_id = module.vpc.vpc_id
}

module "jump_server" {
  source = "./modules/ec2"

  ami               = "ami-053b12d3152c0cc71"
  key_name          = var.key_name
  subnet_id         = module.vpc.pub_subnet01_id
  security_group_id = module.security_group.security_group_id
  instance_type     = "t2.medium"
  volume_size       = 20
  user_data         = "./tools.sh"
}
// Uncomment EKS block when required
module "eks" {
  source = "./modules/eks"

  cluster_name           = "dev-eks-cluster"
  key_name               = var.key_name
  sg_vpc_id              = module.vpc.vpc_id
  controller_subnet_ids  = [module.vpc.pvt_subnet01_id, module.vpc.pvt_subnet02_id]
  worker_subnet_ids      = [module.vpc.pvt_subnet01_id, module.vpc.pvt_subnet02_id]
  endpoint_public_access = false

  on_demand_scaling = {
    desired_size = 1
    max_size     = 5
    min_size     = 1
    
  }
  spot_scaling = {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  addons = [
    {
    name    = "vpc-cni",
    version = "v1.19.0-eksbuild.1"
  },
  {
    name    = "kube-proxy"
    version = "v1.31.3-eksbuild.2"
  },
  {
    name = "eks-pod-identity-agent"
    version = "v1.3.4-eksbuild.1"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.37.0-eksbuild.1"
  }
  ]
}
