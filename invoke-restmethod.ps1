<#
.SYNOPSIS
    PowerShell script to test connectivity to a site while changing default behavior of Invoke-RestMethod to leverage TLS 1.2 instead of 1.0 
    TLS 1.0 is/should be disabled on most sites
.DESCRIPTION
    This script can be used to test for connectivity to a site to validate that it is connecting as expected. PowerShell equivilent to curl
    Replacing Invoke-RestMethod with curl will function the same
.EXAMPLE
    invoke-restmethod.ps1 -url https://example.com
#>

#Create parameter to pass to Invoke-RestMethod
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true, HelpMessage= "Enter URL to connect to")]
    [string]$url
)

#Changes default security protocol from TLS 1.0 for duration of the script
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#PowerShell Invoke-RestMethod cmdlet
Invoke-RestMethod -uri $url
