
terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/eks.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"
  config = {
    bucket      = "g1soori-tf-bucket"
    key         = "tf/dev/wsus_subnet.tfstate"
    region      = var.region
    access_key  = var.access_key
    secret_key  = var.secret_key
  }
}

resource "aws_iam_role" "K8s" {
  name = "eks-cluster-K8s"

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
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "K8s-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.K8s.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "K8s-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.K8s.name
}


resource "aws_eks_cluster" "K8s" {
  name     = "K8s"
  role_arn = aws_iam_role.K8s.arn

  vpc_config {
    #subnet_ids = [data.terraform_remote_state.subnet.subnet_id["dev_subnet"]]
    subnet_ids = values(data.terraform_remote_state.subnet.outputs.subnet_id)
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.K8s-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.K8s-AmazonEKSVPCResourceController,
  ]
}

