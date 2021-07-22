# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/load-balancer.tfstate"
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

locals {
  subnet_ids = values(data.terraform_remote_state.subnet.outputs.subnet_id)
}

resource "random_pet" "pet_name" {
  length    = 3
  separator = "-"
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "s3-access-test-${random_pet.pet_name.id}"
  acl    = "public-read-write"

  tags = {
    Name        = "s3-g1soori-terraform"
    Environment = "Dev"
  }
}

# resource "aws_s3_bucket_policy" "b" {
#   bucket = aws_s3_bucket.lb_logs.id

#   # This policy allows S3 get object access only for vpc endpoint. Denys all other
#   policy = <<EOF
# {
#   "Id": "Policy1626861170593",
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Stmt1626861169611",
#       "Action": [
#         "s3:DeleteObject",
#         "s3:GetObject",
#         "s3:ListBucket",
#         "s3:PutObject",
#         "s3:PutObjectAcl"
#       ],
#       "Effect": "Allow",
#       "Resource": ["${aws_s3_bucket.lb_logs.arn}/*"],
#       "Principal": "*"
#     }
#   ]
# }
# EOF

# }



resource "aws_lb" "this" {
  name               = "g1soori-test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0b595ec561f0fb9cf"]
  subnets            = local.subnet_ids
  # subnets            = [data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"], "subnet-017827144cdcea3a6"]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "g1soori-lb"
    enabled = true
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "g1soori-test-lb-tf-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}