terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/eks_helm.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"
  config = {
    bucket      = "g1soori-tf-bucket"
    key         = "tf/dev/wsus_subnet.tfstate"
    region      = var.region
    access_key  = var.access_key
    secret_key  = var.secret_key
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