output "private_ip" {
  
  value = {
    for instance in aws_instance.web:
    instance.id => instance.private_ip
  }
  description = "private ip"
}

output "public_ip" {

  value = {
    for instance in aws_instance.web:
    instance.id => instance.public
    if instance.associate_public_ip_address
  }
  description = "public ip"
}
