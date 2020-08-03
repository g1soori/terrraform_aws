# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/ec2.tfstate"
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

resource "aws_network_interface" "web" {
  count = var.server_count
  
  subnet_id    = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]
  
  tags = {
    Name = "${var.environment}_${var.resource_prefix}-nic${format("%02d",count.index + 1)}"
  }
}

resource "aws_instance" "web" {
  count = var.server_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.web[count.index].id
    device_index         = 0
  }

  tags = {
    Name = "${var.environment}_${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  }
}