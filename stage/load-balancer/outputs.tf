output "lb_arn" {
  value = aws_lb.this.arn
}

output "tg_arn" {
  value = aws_lb_target_group.this.arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

# output "public_ip" {

#   value = {
#     for instance in aws_instance.web:
#     instance.id => instance.public_ip
#     if instance.associate_public_ip_address
#   }
#   description = "public ip"
# }
