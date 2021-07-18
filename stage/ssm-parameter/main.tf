terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/ssm-paramter.tfstate"
    region = "us-west-2"
    profile = "g1"
  }
}

# This approach is not recommended as the secret will be saved in tf backend as plain text 
resource "aws_ssm_parameter" "secret" {
  name        = "/uat/Administrator/password"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.admin_password

  tags = {
    environment = "uat"
  }
}