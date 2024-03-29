# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/ec2.tfstate"
    region = "us-west-2"
    profile = "g1"
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}


resource "aws_instance" "web" {
  count = var.server_count

  ami           = data.aws_ami.amazon.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-0b595ec561f0fb9cf"]
  key_name = "ec2-2021"
  subnet_id = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]

  # network_interface {
  #   network_interface_id = aws_network_interface.web[count.index].id
  #   device_index         = 0
  # }

  iam_instance_profile = "ec2_profile"

  tags = {
    Name = "${var.environment}_${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  }
}

resource "aws_eip" "lb" {
  count = var.server_count
  instance = aws_instance.web[count.index].id
  vpc      = true
}

resource "aws_instance" "private" {

  ami           = data.aws_ami.amazon.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-0b595ec561f0fb9cf"]
  key_name = "ec2-2021"
  subnet_id = data.terraform_remote_state.subnet.outputs.subnet_id["prod_subnet"]

  iam_instance_profile = "ec2_profile"

  tags = {
    Name = "private_${var.resource_prefix}-vm"
  }
}