output "subnet_id" {
    #value = aws_subnet.main.id
    value = {
        for subnet in aws_subnet.main :
        subnet.tags.Name => subnet.id
    }
}

output "environment" {
    #value = aws_subnet.main.id
    value = {
        for subnet in aws_subnet.main :
        subnet.tags.Name => subnet.tags.env
    }
}

output "vpc_id" {
    value = data.terraform_remote_state.vpc.outputs.vpc_id
}