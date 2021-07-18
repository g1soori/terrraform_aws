terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/wsus_vpc.tfstate"
    region = "us-west-2"
    profile = "g1"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "wsus_vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

