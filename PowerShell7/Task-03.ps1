<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.3.3
#>

Import-Module .\dell.ddve.psm1 -Force

$system = "ddve-01.vcorp.local"
connect-restapi -Server $system

# QUERY FOR MTREES
# $query = get-mtrees

# FILTER EXAMPLE
$query = get-mtrees -Filters @("name=/data/col1/SysDR_ppdm-01")

$query | format-list