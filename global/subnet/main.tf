terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/wsus_subnet.tfstate"
    region = "us-west-2"
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