Import-Module .\dell.ddmc.psm1 -Force
<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.3.3
#>

# VARS
$ddmc = "ddmc-01.vcorp.local"
$datacenter = "DC-01"
$systempool = "Pool-01"
$mobilestorageunit = "NW-02_Pool-01_MSU"
$deletesourcemsu = $true

# CONNECT TO THE DDMC REST API
connect-restapi -Server $ddmc
<#
    MIGRATE A SMART SCALE MOBILE STORAGE UNIT
#>
# CREATE A FILTER AND QUERY FOR THE DATA CENTER
$filter = @(
    "name=$($datacenter)"
)
$dc = get-datacenter -Filters $filter
Write-Host "[ddmc]: GET /data-centers" -ForegroundColor Yellow

# CREATE A FILTER AND QUERY FOR THE SMART SCALE SYSTEM POOL
$filter = @(
    "dataCenterUuid=$($dc.uuid)",
    "and name=$($systempool)"
)
$pool = get-systempools -Filters $filter
Write-Host "`n[ddmc]: GET //system-pools" -ForegroundColor Yellow

# CHECK THE CAPACITY UTILIZATION OF EACH POOL MEMBER
$capacity = @()
$pool.members | foreach-object {
    $object = [ordered]@{
        system_id = $_.id
        system_name = $_.systemName
        bytes_used = $_.capacityUsedBytes
        bytes_available = $_.capacityAvailableBytes
        bytes_capacity = $_.capacityUsedBytes + $_.capacityAvailableBytes
        gb_used = [math]::Round($_.capacityUsedBytes /1gb,2)
        gb_available = [math]::Round($_.capacityAvailableBytes /1gb,2)
        gb_capacity = [math]::Round(($_.capacityUsedBytes + $_.capacityAvailableBytes) /1gb,2)
        percent_utilized = ([math]::Round($_.capacityUsedBytes / `
        ($_.capacityUsedBytes + $_.capacityAvailableBytes),4) * 100).ToString() + '%'
    }

    $capacity += (New-Object -TypeName pscustomobject -Property $object)
}
Write-Host "`n[ddmc]: Convert capacity of pool members from bytes to gb" -ForegroundColor Yellow
$capacity | convertto-json

# CREATE A FILTER AND QUERY FOR THE SMART SCALE MOBILE STORAGE UNITS
$filter = @(
    "systemPoolUuid=$($pool.uuid)"
    "and name=$($mobilestorageunit)"
)
$msu = get-storageunits -Filters $filter
Write-Host "`n[ddmc]: GET /storage-units" -ForegroundColor Yellow
$msu | select-object id,name,dataAccessNetworkGroups | convertto-json -Depth 10

# GET SMART SCALE RECOMMENDATION FOR THE MIGRATION
$recommended = get-recommendations `
-TargetSystemPoolUuid $pool.uuid `
-StorageUnitId $msu.id
# JUST GRABBING THE FIRST RECOMMENDED SYSTEM
$system = $recommended.availableSystems[0]
Write-Host "`n[ddmc]: POST /storage-units/recommendations/migrations" -ForegroundColor Yellow
$recommended | convertto-json

### BEGIN THE MIGRATION ###
# START THE MSU MIGRATION BASED ON THE RECOMMENDATION
$migration = new-migration `
    -StorageUnitId $msu.id `
    -TargetSystemUuid $system.systemUuid `
    -NetworkGroupId $msu.dataAccessNetworkGroups[0].networkGroupId `
    -TransferPriority FAST

# MONITOR UNTIL THE API RETURNS THE STATUS BELOW
$monitor = new-monitor `
    -MigrationId $migration.id `
    -Status MIGRATION_CUTOVER_READY
    Write-Host "`n[ddmc]: GET /storage-units/migrations/$($migration.id)" -ForegroundColor Yellow
    $monitor.msuMigrationDetails | convertto-json

# COMMIT THE MIGRATION JOB
$commit = set-migrationcommit `
    -MigrationId $migration.id `
    -DeleteSourceMsu $deletesourcemsu
    Write-Host "`n[ddmc]: POST /storage-units/migrations/$($migration.id)/commit" -ForegroundColor Yellow
    $commit | convertto-json

# MONITOR UNTIL THE API RETURNS THE STATUS BELOW
$monitor = new-monitor `
    -MigrationId $migration.id `
    -Status MIGRATION_CUTOVER_COMPLETE
    Write-Host "`n[ddmc]: GET /storage-units/migrations/$($migration.id)" -ForegroundColor Yellow
    $monitor.msuMigrationDetails | convertto-json

# DELETE THE MIGRATION JOB (ISSUE CANCELING COMPLETED JOB)
$delete = set-migrationcancel `
    -MigrationId $migration.id
    Write-Host "`n[ddmc]: POST /storage-units/migrations/$($migration.id)/cancel" -ForegroundColor Yellow
    $delete | convertto-json

# MONITOR UNTIL THE API RETURNS THE STATUS BELOW
$monitor = new-monitor `
    -MigrationId $migration.id `
    -Status MIGRATION_COMPLETE
    Write-Host "`n[ddmc]: GET /storage-units/migrations/$($migration.id)" -ForegroundColor Yellow
    $monitor.msuMigrationDetails | convertto-json
