# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/ec2-windows-dc-client.tfstate"
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
    profile     = var.profile
  }
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-v1.11-windows-2019-Full-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["602401143452"] # Canonical
}

# resource "aws_network_interface" "web" {
#   count = var.server_count
  
#   subnet_id    = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]
  
#   tags = {
#     Name = "${var.environment}_${var.resource_prefix}-nic${format("%02d",count.index + 1)}"
#   }
# }


resource "aws_instance" "web" {
  count = var.server_count

  ami           = data.aws_ami.windows.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-0b595ec561f0fb9cf"]
  key_name = "ec2"
  subnet_id = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]

  user_data     = <<EOF
<powershell> 



param (
    [string]$domain = "example.com",
    [string]$username = "${var.ad_uname}",
    [string]$password = "${var.ad_pwd}"
 )

$nodisplay = Rename-Computer -NewName "${var.hostnames[count.index]}" 
sleep -s 30

$intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ("10.0.2.55")

#Set-TimeZone -Name "Malay Peninsula Standard Time"

Add-Computer -DomainName $domain -Credential (New-Object -TypeName PSCredential -ArgumentList $username,(ConvertTo-SecureString -String $password -AsPlainText -Force)[0]) -Options JoinWithNewName,AccountCreate -Restart

</powershell>
EOF

  # network_interface {
  #   network_interface_id = aws_network_interface.web[count.index].id
  #   device_index         = 0
  # }

#   user_data = <<EOF
# <powershell>
# $intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex
# Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ("10.0.2.166")

# Add-Computer -DomainName 'example.com' -NewName 'abcmachinename' -Credential (New-Object -TypeName PSCredential -ArgumentList "Administrator",(ConvertTo-SecureString -String 'c2vPgvJ5yIS%d3)VZrn*(mk!!-chXeHI' -AsPlainText -Force)[0]) -Restart
# </powershell>
# EOF



  tags = {
    Name = "${var.environment}_${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  }
}

resource "aws_eip" "lb" {
  count = var.server_count
  instance = aws_instance.web[count.index].id
  vpc      = true
}