<powershell>
<#
.SYNOPSIS
    Example of requring a parameter to be passed at run time
.EXAMPLE
    PS C:\> foo.ps1 -env DEV
    When running the command will set $env to DEV
.INPUTS
    -env
.NOTES
    via 
    https://certification.comptia.org/it-career-news/post/view/2018/03/09/talk-tech-to-me-powershell-parameters-and-parameter-validation
    https://social.technet.microsoft.com/Forums/en-US/35d95d50-4ebf-4d9d-93c1-2034e3566f5b/using-helpmessage-in-parameter-attributes?forum=winserverpowershell
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true, HelpMessage= "Enter DEV or QA")]
    [ValidateSet("DEV","QA")]
    [string]$env
)
