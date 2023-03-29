<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.3.3
#>

Import-Module .\dell.ddve.psm1 -Force

$system = "ddve-01.vcorp.local"
connect-restapi -Server $system

<#
    GET POWERPROTECT DD SYSTEM ALERTS
#>
$query = get-alerts

# FILTER EXAMPLE
# $query = get-alerts  -Filters @("severity=CRITICAL")

$query | where-object {$_.status -ne 'cleared'} | format-list