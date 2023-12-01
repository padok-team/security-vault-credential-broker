resource "aws_iam_role" "eks_cluster" {
  name        = "eksClusterRole"
  description = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLocalOutpostClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
}

resource "aws_iam_role" "eks_node_group" {
  name        = "eksNodeGroupRole"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLocalOutpostClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
}

resource "aws_iam_role_policy" "kms" {
  role = aws_iam_role.eks_node_group.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : "kms:*",
      "Resource" : "*"
    }]
  })
}

resource "aws_eks_cluster" "this" {
  name     = "boundary-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  enabled_cluster_log_types = ["api"]

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    subnet_ids              = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  addon_version = "v1.25.0-eksbuild.1"
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "boundary-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn

  instance_types = ["t3a.small"]
  subnet_ids     = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  scaling_config {
    min_size     = 2
    max_size     = 2
    desired_size = 2
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}
