# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/endpoint-s3.tfstate"
    region = "us-west-2"
    profile = "g1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket      = "g1soori-tf-bucket"
    key         = "tf/dev/wsus_vpc.tfstate"
    region      = var.region
    access_key  = var.access_key
    secret_key  = var.secret_key
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  service_name = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.terraform_remote_state.vpc.outputs.main_rt_id]
}