output "endpoint" {
  value = aws_eks_cluster.K8s.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.K8s.certificate_authority[0].data
}