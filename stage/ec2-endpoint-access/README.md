# Verify AWS VPC Endpoint

## Purpose
AWS VPC endpoints provide secure way to connect to the AWS services such as S3 without going through the internet or public networks. It allows the resources within VPC to connect to the S3 (or DynamoDB) from a endpoint within the VPC itself without going through internet.

## Setup
In this code, 2 ec2 instances are created with one in public subnet and other in private subnet. Once the instances are created, 
1. ssh into public instance and try to download file from S3 bucket. Access should be denied.
2. Then SSH to private instance from the public instance and try to downlaod the file from S3
3. You should be able to download the file
4. You can try to access other sites in internet and make sure private instance doesn't have access to internet

## Prerequisites
In order to access the S3 bucket, there should be proper bucket policy in place, specially to deny all the access except from vpc endpoint. You can find the code for the S3 bucket and its policy under the `instant-profile` folder.
