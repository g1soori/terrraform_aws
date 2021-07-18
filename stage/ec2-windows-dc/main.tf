# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it "HelloWorld"

terraform {
  backend "s3" {
    bucket = "g1soori-tf-bucket"
    key    = "tf/dev/ec2-windows.tfstate"
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
#  vpc_security_group_ids = ["sg-0b595ec561f0fb9cf"]
  key_name = "ec2"
#  subnet_id = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}_subnet"]
  iam_instance_profile = "ec2_profile"

#   user_data = <<EOF
# <powershell>
# ## Find interface id
# $intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex

# ## Find IP 
# $ipadd=(Get-NetIPAddress -InterfaceIndex $intIndex -AddressFamily IPv4).IPAddress

# ## Set DNS
# Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ($ipadd)

# ## Install AD Role
# Install-WindowsFeature –Name AD-Domain-Services –IncludeManagementTools

# ## AD DS configuration
# Install-ADDSForest -DomainName "example.com" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName "example" -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS"   -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString -String 'G7xY)#zZy=7urS~e' -AsPlainText -Force)

# ## Restart computer
# Restart-Computer

# </powershell>
# EOF

  # network_interface {
  #   network_interface_id = aws_network_interface.web[count.index].id
  #   device_index         = 0
  # }

  tags = {
    Name = "${var.environment}_${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  }
}

resource "aws_eip" "lb" {
  count = var.server_count
  instance = aws_instance.web[count.index].id
  vpc      = true
}