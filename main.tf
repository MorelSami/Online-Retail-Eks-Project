
# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create an EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.26"

  vpc_config {
    subnet_ids = [aws_subnet.eks_priv_sub_one.id,
      aws_subnet.eks_priv_sub_two.id,
      aws_subnet.eks_pub_sub_one.id,
    aws_subnet.eks_pub_sub_two.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment
  ]
}

# Create an IAM role for the worker nodes
resource "aws_iam_role" "eks_worker_node_role" {
  name = "eks_worker_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2CR_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_role.name
}


# Create the EKS node group
resource "aws_eks_node_group" "eks_node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node"
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn

  # Subnet configuration
  subnet_ids = [
    aws_subnet.eks_priv_sub_one.id,
    aws_subnet.eks_priv_sub_two.id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }


  # Use the latest EKS-optimized Amazon Linux 2 AMI
  ami_type = "AL2_x86_64"

  # Use the latest version of the EKS-optimized AMI
  # release_version = "latest"

  # Configure the node group instances
  instance_types = ["t3.small", "t3.medium", "t3.large"]


  # Use the managed node group capacity provider
  capacity_type = "ON_DEMAND"


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.

  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_ec2CR_policy_attachment,
  ]
}

# Specify the tags for the node group
#  tag = {
#    Terraform = "true"
#    Environment = "prod"
#      }
# }