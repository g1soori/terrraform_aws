## Find the InterfaceIndex
 $intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex


## Set DNS IPs
Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ("10.0.2.206")


## Join Domain User data script

user_data = <<EOF
<powershell>
$intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ("10.0.2.206")

Add-Computer -DomainName 'example.com' -NewName 'abcmachinename' -Credential (New-Object -TypeName PSCredential -ArgumentList "Administrator",(ConvertTo-SecureString -String 'xxxxxxxxx' -AsPlainText -Force)[0]) -Restart
</powershell>
EOF


### If you want to bring up new AD server

Guide for AD creation - https://social.technet.microsoft.com/wiki/contents/articles/52765.windows-server-2019-step-by-step-setup-active-directory-environment-using-powershell.aspx


# Script for setting AD

## Find interface id
$intIndex=(Get-NetAdapter -Name "Ethernet*").InterfaceIndex

## Find IP 
$ipadd=(Get-NetIPAddress -InterfaceIndex $intIndex -AddressFamily IPv4).IPAddress

## Set DNS
Set-DnsClientServerAddress -InterfaceIndex $intIndex -ServerAddresses ($ipadd)

## Install AD Role
Install-WindowsFeature –Name AD-Domain-Services –IncludeManagementTools

## AD DS configuration
Install-ADDSForest -DomainName "example.com" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName "example" -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS"   -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString -String 'G7xY)#zZy=7urS~e' -AsPlainText -Force)

## Restart computer
Restart-Computer



-----------

read-S3Object -region "us-west-2" -BucketName "s3-access-test-painfully-epic-cow" -Key "file.txt" -file "c:\file.txt"
