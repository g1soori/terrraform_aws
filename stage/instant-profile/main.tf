terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/instant-profile.tfstate"
    region = "us-west-2"
    profile = "g1"
  }
}

data "terraform_remote_state" "endpoint" {
  backend = "s3"
  config = {
    bucket      = "g1soori-tf-bucket"
    key         = "tf/dev/endpoint-s3.tfstate"
    region      = var.region
    access_key  = var.access_key
    secret_key  = var.secret_key
  }
}

resource "random_pet" "pet_name" {
  length    = 3
  separator = "-"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "s3-access-test-${random_pet.pet_name.id}"
  acl    = "private"

  

  tags = {
    Name        = "s3-g1soori-terraform"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.bucket.id

  # This policy allows S3 get object access only for vpc endpoint. Denys all other
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Id": "Policy1415115909152",
   "Statement": [
     {
       "Sid": "Access-to-specific-VPCE-only",
       "Principal": "*",
       "Action": "s3:GetObject",
       "Effect": "Deny",
       "Resource": ["${aws_s3_bucket.bucket.arn}/*"],
       "Condition": {
         "StringNotLike": {
           "aws:SourceVpce": "${data.terraform_remote_state.endpoint.outputs.id}"
         }
       }
     }
   ]
}
EOF

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name                = "yak_role"
#  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json # (not shown)
  managed_policy_arns = [aws_iam_policy.policy.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy-${random_pet.pet_name.id}"
  description = "SOP S3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}/*"
    }
  ]
}
EOF
}


# {
#    "Version": "2012-10-17",
#    "Id": "Policy1415115909152",
#    "Statement": [
#      {
#        "Sid": "Access-to-specific-VPCE-only",
#        "Principal": "*",
#        "Action": "s3:GetObject",
#        "Effect": "Allow",
#        "Resource": ["${aws_s3_bucket.bucket.arn}/*"],
#        "Condition": {
#          "StringEquals": {
#            "aws:sourceVpce": "${data.terraform_remote_state.endpoint.outputs.id}"
#          }
#        }
#      }
#    ]
# }