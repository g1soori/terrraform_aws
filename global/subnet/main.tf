terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/wsus_subnet.tfstate"
    region = "us-west-2"
    profile = "g1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/wsus_vpc.tfstate"
    region = "us-west-2"
    access_key = var.access_key
    secret_key = var.secret_key
  }
}

resource "aws_subnet" "main" {
  for_each    = var.subnets

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block = each.value

  tags = {
    Name  = each.key
    env   = "${element(split("_", each.key),0)}"

  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.terraform_remote_state.vpc.outputs.gw_id
  }
}

## Internet GW is attached to the dev_subnet
resource "aws_route_table_association" "public-rta" {
  subnet_id      = aws_subnet.main["dev_subnet"].id
  route_table_id = aws_route_table.public-rt.id
}

# resource "aws_eip" "gw" {
#   vpc      = true
# }


## Enable this 2 sets of block of code only if private subnet requires internet access
# resource "aws_nat_gateway" "main" {
#   connectivity_type = "public"
#   subnet_id         = aws_subnet.main["dev_subnet"].id
#   allocation_id     = aws_eip.gw.id
# }

# resource "aws_route" "r" {
#   route_table_id              = data.terraform_remote_state.vpc.outputs.main_rt_id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_nat_gateway.main.id
# }