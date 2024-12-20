provider "aws" {
  region = "ap-south-1"
}
//crating security group 
resource "aws_security_group" "EKS_SG" {
  name        = "EKS-SG"
  vpc_id      = var.sg_vpc_id

  tags = {
    Name = "EKS_SG"
  }
}
//inbound rules 
resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.EKS_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}
//outbound rules 
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.EKS_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
//outbond rules for ipv6
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.EKS_SG.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}
# Attach Required Policies to Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
# IAM Role for Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Required Policies to Node Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
// Attach this policy when working with statefulset application for data persistency and use to create PVs (EBS) in aws
resource "aws_iam_role_policy_attachment" "CSI_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role = aws_iam_role.eks_node_role.name
}

# Creating eks cluster 
resource "aws_eks_cluster" "my_first_cluster" { 
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.controller_subnet_ids
    security_group_ids = [aws_security_group.EKS_SG.id]
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
  }
  
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# AddOns for EKS Cluster
resource "aws_eks_addon" "eks-addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.my_first_cluster.name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.ondemand-node,
    aws_eks_node_group.spot-node
  ]
}
 
# Creating nodegroup ON_DEMAND
resource "aws_eks_node_group" "ondemand-node" { 
  cluster_name    = aws_eks_cluster.my_first_cluster.name
  node_group_name = "${var.cluster_name}-on-demand-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.worker_subnet_ids
  ami_type = "AL2_x86_64"
  instance_types = var.instance_types_on_demand
  disk_size = var.disk_size_on_demand

  remote_access {
    ec2_ssh_key = var.key_name
    source_security_group_ids = [ aws_security_group.EKS_SG.id ]
  }
  capacity_type = "ON_DEMAND"
  scaling_config {
    desired_size = var.on_demand_scaling.desired_size
    max_size     = var.on_demand_scaling.max_size
    min_size     = var.on_demand_scaling.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
    aws_iam_role_policy_attachment.CSI_driver_policy,
  ]

   tags = {
    "Name" = "${var.cluster_name}-on-demand-nodes"
  }
}

# Creating Node-group SPOT 
resource "aws_eks_node_group" "spot-node" { 
  cluster_name    = aws_eks_cluster.my_first_cluster.name
  node_group_name = "${var.cluster_name}-spot-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.worker_subnet_ids
  ami_type = "AL2_x86_64"
  instance_types = var.instance_types_spot
  disk_size = var.disk_size_spot

  remote_access {
    ec2_ssh_key = var.key_name
    source_security_group_ids = [ aws_security_group.EKS_SG.id ]
  }
  capacity_type = "SPOT"
  scaling_config {
    desired_size = var.spot_scaling.desired_size
    max_size     = var.spot_scaling.max_size
    min_size     = var.spot_scaling.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
    aws_iam_role_policy_attachment.CSI_driver_policy,
  ]
   tags = {
    "Name" = "${var.cluster_name}-spot-nodes"
  }
}


