# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  #required_version = "0.12.28"

  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/nomad.tfstate"
    region = "us-west-2"
  }

}

# data "terraform_remote_state" "subnet" {
#   backend = "s3"
#   config = {
#     bucket      = "g1soori-tf-bucket"
#     key         = "tf/dev/wsus_subnet.tfstate"
#     region      = var.region
#     access_key  = var.access_key
#     secret_key  = var.secret_key
#   }
# }

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] 
}

# resource "aws_network_interface" "nomad" {
#   count = var.server_count
  
#   subnet_id    = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]
  
#   tags = {
#     Name = "${var.environment}_${var.resource_prefix}-nic${format("%02d",count.index + 1)}"
#   }
# }

resource "aws_instance" "nomad" {
  count = var.server_count

  ami           = data.aws_ami.centos.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-011522e198af22431"]
  key_name = "nomad"

  # network_interface {
  #   network_interface_id = aws_network_interface.nomad[count.index].id
  #   device_index         = 0
  # }

  tags = {
    Name = "${var.environment}_${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
      "sudo yum -y install consul",
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("../../../nomad.pem")
      host    = self.public_ip
    }
  }
}