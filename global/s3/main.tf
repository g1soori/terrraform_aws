resource "aws_s3_bucket" "b" {
  bucket = "g1soori-tf-bucket"
  acl    = "private"

  tags = {
    Name        = "s3-g1soori-terraform"
    Environment = "Dev"
  }
}