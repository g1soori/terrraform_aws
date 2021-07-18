output "vpc_id" {
    value = aws_vpc.main.id
}

output "gw_id" {
    value = aws_internet_gateway.main.id
}

output "main_rt_id" {
    value = aws_vpc.main.main_route_table_id 
}