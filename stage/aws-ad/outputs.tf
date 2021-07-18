output "dns_ip" {
  
  value = aws_directory_service_directory.bar.dns_ip_addresses
  description = "dns"
}

output "access_url" {

  value = aws_directory_service_directory.bar.access_url
  description = "url"
}
