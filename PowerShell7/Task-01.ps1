<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.3.3
#>

Import-Module .\dell.ddve.psm1 -Force

$system = "ddve-01.vcorp.local"
connect-restapi -Server $system

$query = get-system

# CONVERT BYTES TO GB
$object = [ordered]@{
    system = $query.name
    type = $query.type
    version = $query.version
    serialno = $query.serialno
    model = $query.model
    uptime = $query.uptime
    used_GB = [math]::Round($query.physical_capacity.used/1gb,2)
    available_GB = [math]::Round($query.physical_capacity.available/1gb,2)
    total_GB = [math]::Round($query.physical_capacity.total/1gb,2)
}

$object | format-table -AutoSize