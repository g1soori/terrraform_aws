output "kubeconfig_path" {
  value = abspath(module.cluster.kubeconfig_filename)
}

output "cluster_name" {
  value = module.cluster.cluster_name
}