# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/aws-ad.tfstate"
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


resource "aws_directory_service_directory" "bar" {
  name     = "corp.notexample.com"
  password = "SuperSecretPassw0rd"
  # edition  = "Standard"
  # type     = "MicrosoftAD"
  type    = "SimpleAD"

  vpc_settings {
    vpc_id     = data.terraform_remote_state.subnet.outputs.vpc_id
    subnet_ids = values(data.terraform_remote_state.subnet.outputs.subnet_id)
  }

  tags = {
    Project = "foo"
  }
}