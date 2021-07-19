# AWS VPC Endpoint

## Purpose
AWS VPC endpoints provide secure way to connect to the AWS services such as S3 without going through the internet or public networks. It allows the resources within VPC to connect to the S3 (or DynamoDB) from a endpoint within the VPC itself without going through internet.

## Setup
In this code, VPC endpoint is created and attached to a VPC. There are couple of VMs created inside the `ec2-endpoint-access` folder to test and verify the access