resource "aws_eks_node_group" "k8s" {
  cluster_name    = aws_eks_cluster.K8s.name
  node_group_name = "k8s"
  node_role_arn   = aws_iam_role.K8s.arn
  subnet_ids      = values(data.terraform_remote_state.subnet.outputs.subnet_id)

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.k8s-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.k8s-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_iam_role" "k8s-node" {
#   name = "eks-node-group-k8s"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.K8s.name
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.K8s.name
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.K8s.name
}