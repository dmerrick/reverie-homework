# create a new IAM role for the nodes
resource "aws_iam_role" "node-role" {
  name = "reverie-hw-${var.application_environment}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}

resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.application_environment}_cluster_node_group"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-role-AmazonEC2ContainerRegistryReadOnly,
  ]
}
