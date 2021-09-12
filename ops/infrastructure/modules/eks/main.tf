resource "aws_security_group" "eks_security_group" {
  name_prefix = "eks-connector-"
  description = "A security group to connect via kubectl"
  vpc_id      = var.vpc_config.id

  ingress {
    description      = "HTTPs from outside world"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "eks-connector-sg"
  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
      # identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  description = "Basic EKS role"
  # path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = {
    tag-key = "eks-cluster-role-tag"
  }
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

data "aws_iam_policy_document" "role_policy_node" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  description = "Basic EKS node role"
  assume_role_policy = data.aws_iam_policy_document.role_policy_node.json

  tags = {
    tag-key = "eks-node-role-tag"
  }
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_cluster" "main" {
  name     = "main_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.vpc_config.subnet_ids
    security_group_ids = [aws_security_group.eks_security_group.id]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}

resource "aws_security_group" "worker_group" {
  name_prefix = "${var.name}_worker"
  description = "For EKS worker ${var.name}"
  vpc_id      = var.vpc_config.id

  ingress {
    description      = "all for cluster"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [resource.aws_security_group.eks_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
   "kubernetes.io/cluster/${var.name}" = "shared"
  }

  lifecycle {
    ignore_changes = [ ingress ]
  }
}

resource "aws_launch_template" "eks_node_template" {
  name_prefix   = var.name
  instance_type = "t3.medium"

  network_interfaces {
    security_groups = concat(
      [resource.aws_security_group.worker_group.id],
      var.assigned_security_groups
    )
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.vpc_config.subnet_ids
  capacity_type = "ON_DEMAND"

  launch_template {
    id = resource.aws_launch_template.eks_node_template.id
    version = resource.aws_launch_template.eks_node_template.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly
  ]
}
