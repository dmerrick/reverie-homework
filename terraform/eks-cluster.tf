# create an IAM role to allow EKS to manage other AWS services
resource "aws_iam_role" "cluster-role" {
  name = "reverie-hw-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role.name
}

resource "aws_iam_role_policy_attachment" "cluster-role-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster-role.name
}

# create a new security group for the cluster
resource "aws_security_group" "private-cluster" {
  name        = "reverie-hw-cluster"
  description = "Allow cluster communication with worker nodes"
  vpc_id      = aws_vpc.private.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "reverie-hw cluster SG - ${var.application_environment}"
  }
}

# add the IP _of the person running terraform_ to the security group
resource "aws_security_group_rule" "cluster-role-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.private-cluster.id
  to_port           = 443
  type              = "ingress"
}

# create the new EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.cluster-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.private-cluster.id]
    subnet_ids         = aws_subnet.private[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-role-AmazonEKSServicePolicy,
  ]
}
