# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/auto-scaling-group.tfstate"
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

data "terraform_remote_state" "lb" {
  backend = "s3"
  config = {
    bucket      = "g1soori-tf-bucket"
    key         = "tf/dev/load-balancer.tfstate"
    region      = var.region
    access_key  = var.access_key
    secret_key  = var.secret_key
  }
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

resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = data.aws_ami.amazon.id
  instance_type = "t2.micro"
  key_name = "ec2-2021"
  user_data = filebase64("./template/initiate.sh")

  network_interfaces {
    associate_public_ip_address = true
    subnet_id     = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]
    delete_on_termination       = true
    security_groups             = ["sg-0b595ec561f0fb9cf"]
  }
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-west-2a"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2

  # health_check_grace_period = 300
  # health_check_type         = "ELB"

  # target_group_arns  = [data.terraform_remote_state.lb.outputs.tg_arn]

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}