#This script can be used as a base/example for configuring a new EC2 instance via user-data/cloud-init
#PowerShell needs to be enclosed in the appropriate tag. Don't for get to close the tag at the end
<powershell> 
#Allow scripts to run for duration of the script
Set-ExecutionPolicy Bypass -Scope Process -Force

#Install required Windows roles and features for portal
#You can add additional features for your need
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-HTTP-Redirect, Web-Http-Logging, Web-Net-Ext45, Web-AppInit, Web-Asp-Net45, Web-ISAPI-ext, Web-ISAPI-Filter, Web-Includes

#Install Chocolatey to install 3rd party tools
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Update current session for chocolatey. I've had mixed results not adding this.
$Env:path = $env:path + ";C:\ProgramData\chocolatey\bin"

#Install 3rd party tools rewrite
choco install urlrewrite -y --force
choco install 7zip -y --force
choco install awscli -y --force
choco install openssl.light -y --force

#Update current session for new apps
$Env:path = $env:path + ";C:\Program Files\Amazon\AWSCLI\"
$Env:path = $env:path + ";C:\Program Files\OpenSSL\bin"

#Create Folders
New-Item -Path "C:\" -Name WebApp -ItemType "directory"
New-Item -Path "C:\" -Name Deploy -ItemType "directory"
New-Item -Path "C:\WebApp" -Name site1 -ItemType "directory"
New-Item -Path "C:\WebApp" -Name site2 -ItemType "directory"

#Create environment variable. This example assumes you need some environment variable for your web app. This will read it from AWS Secrets Manager

#AWS CLI for Secrets Manager requires region to be set, not just permission to read secret. This will add a config file for the AWS CLI
New-Item -Path "C:\Users\Administrator" -Name .aws -ItemType "directory"
Set-Content -Path "C:\Users\Administrator\.aws\config" -Value "[default]`r`nregion=us-east-1"

#Get secrets out of Secrets Manager
$PoshSQLResponse = aws secretsmanager get-secret-value --secret-id dev/iis-env-vars | ConvertFrom-Json
$SQLCon = $PoshSQLResponse.SecretString | ConvertFrom-Json

[Environment]::SetEnvironmentVariable("$($iisenvvars.varname)", "server=$($iisenvvars.varvalue))

#Set working directory for getting files
Set-Location -Path c:\deploy

#Import Certificate
$cert = Import-PfxCertificate -FilePath certificate.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $pfxpw

#Get Latest IIS files zip from S3
aws s3 cp s3://bucket/site1.zip C:\Deploy
aws s3 cp s3://bucket/site2.zip C:\Deploy

#Extract web contents to WebApp folders
7z x .\site1.zip -pPASSWORD -oC:\WebApp\site1 -spe -y #yes password should be in Secrets Manager
7z x .\site2.zip -pPASSWORD -oC:\WebApp\site2 -spe -y #yes password should be in Secrets Manager

#Remove Default Website
Remove-Website -Name "Default Web Site"

#Create IIS website
New-WebAppPool -Name "site1"
New-WebSite -Name "site1" -Port 8080 -PhysicalPath C:\WebApp\site1 -ApplicationPool site1

#Chnage default document for health check site
Add-WebConfiguration //defaultDocument/files "IIS:\sites\site1" -atIndex 0 -Value @{value="foo.html"}

#Add Windows firewall rule for healthcheck
New-NetFirewallRule -DisplayName "Allow in on 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow

#Create IIS website
New-WebAppPool -Name "site2"
New-WebSite -Name "site2" -Port 80 -HostHeader "example.com" -PhysicalPath C:\WebApp\site2 -ApplicationPool site2

#Add HTTPS binding to site2 site
New-WebBinding -Name "site2" -IPAddress "*" -Port 443 -HostHeader "example.com" -Protocol https

#Add SSL Certificate to binding
$binding = Get-WebBinding -Name site2 -Protocol "https"
$binding.AddSslCertificate($cert.GetCertHashString(), "my")

#Set Timezone
Set-TimeZone -Name "Eastern Standard Time"

#Restart IIS
iisreset

#I had a need to associate one of two specific EIPs to an instance, this loop should do it but not tested yet
#Get instance-id so EIP can be associate
#The EIPs are pre-allocated so that they can be added to the trusted authentication configuration of Tableau
$local = curl http://169.254.169.254/latest/meta-data/instance-id

#Loop through pre-allocated EIPs for availability. If the first IP is available (e.g. returns null) it will be used, else the 2nd IP will be used
$pubip = (aws ec2 describe-addresses --public-ip x.x.x.x | ConvertFrom-Json)

If (!$pubip.Addresses.AssociationID) 
{ 
    aws ec2 associate-address --instance-id $local.Content --public-ip x.x.x.x
} 
Else 
{ 
    aws ec2 associate-address --instance-id $local.Content --public-ip y.y.y.y
}

</powershell>
