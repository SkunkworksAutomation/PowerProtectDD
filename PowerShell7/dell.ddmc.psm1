<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.3.3
#>

$global:AuthObject = $null

function connect-restapi {
    [CmdletBinding()]
     param (
        [Parameter( Mandatory=$true)]
        [string]$Server
    )
    begin {
        # CHECK TO SEE IF CREDS FILE EXISTS IF NOT CREATE ONE
        $Exists = Test-Path -Path ".\$($Server).xml" -PathType Leaf
        if($Exists) {
            $Credential = Import-CliXml ".\$($Server).xml"
        } else {
            $Credential = Get-Credential
            $Credential | Export-CliXml ".\$($Server).xml"
        } 
    }
    process {
        #LOGIN TO DD REST API
        $auth = @{
            username="$($Credential.UserName)"
            password="$(ConvertFrom-SecureString $Credential.Password -AsPlainText)"
         } 

        Invoke-RestMethod -Uri "https://$($Server):3009/rest/v1.0/auth" `
            -Method POST `
            -ContentType 'application/json' `
            -Body (ConvertTo-Json $auth) `
            -SkipCertificateCheck `
            -ResponseHeadersVariable Headers
        
            $Auth = @{
                server = "https://$($Server):3009"
                token = $Headers['X-DD-AUTH-TOKEN'][0]
            } #END AUTH

            $global:AuthObject = $Auth
            $global:AuthObject | Format-List
    }
}

function get-datacenter {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$false)]
        [array]$Filters
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/data-centers"

        if($Filters.Length -gt 0) {
            $Join = ($Filters -join ' ') -replace '\s','%20' -replace '"','%22' -replace '=','%3D'
            $Endpoint = "api/v1/data-centers?filter=$($Join)"
        }
                
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.dataCenters[0]
    }
}

function get-systempools {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$false)]
        [array]$Filters
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/system-pools"

        if($Filters.Length -gt 0) {
            $Join = ($Filters -join ' ') -replace '\s','%20' -replace '"','%22' -replace '=','%3D'
            $Endpoint = "api/v1/system-pools?filter=$($Join)"
        }
                
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.pools[0]
    }
}

function get-storageunits {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$false)]
        [array]$Filters
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units"

        if($Filters.Length -gt 0) {
            $Join = ($Filters -join ' ') -replace '\s','%20' -replace '"','%22' -replace '=','%3D'
            $Endpoint = "api/v1/storage-units?filter=$($Join)"
        }
                
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.storageUnits[0]
    }
}

function get-recommendations {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true)]
        [string]$TargetSystemPoolUuid,
        [Parameter( Mandatory=$true)]
        [string]$StorageUnitId
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units/recommendations/migrations"
        $Body = [ordered]@{
            msu_migration_recommend = @{
                targetSystemPoolUuid = "$($TargetSystemPoolUuid)"
                storageUnitIds = @("$($StorageUnitId)")
            }
        }
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method POST `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -Body ($Body | convertto-json) `
            -SkipCertificateCheck
        
      
        return $query.MsuMigrationRecommendations
    }
}

function new-migration {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true)]
        [string]$StorageUnitId,
        [Parameter( Mandatory=$true)]
        [string]$TargetSystemUuid,
        [Parameter( Mandatory=$true)]
        [int]$NetworkGroupId,
        [Parameter( Mandatory=$true)]
        [ValidateSet("MINIMUM","FAST","BALANCED")]
        [string]$TransferPriority
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units/migrations/start"
        $Body = [ordered]@{
            msu_migration_start = @{
                storageUnitId = "$($StorageUnitId)"
                targetSystemUuid = "$($TargetSystemUuid)"
                networkGroupId = $NetworkGroupId
                transferPriority = "$($TransferPriority)"
            }
        }
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method POST `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -Body ($Body | convertto-json) `
            -SkipCertificateCheck
        
      
        return $query.MsuMigrationInfo.msuMigrationDetails
    }
}

function new-monitor {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true)]
        [int]$MigrationId,
        [Parameter(Mandatory=$true)]
        [ValidateSet("MIGRATION_CUTOVER_READY","MIGRATION_CUTOVER_COMPLETE","MIGRATION_COMPLETE")]
        [string]$Status
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units/migrations/$($MigrationId)"
        do {
            # BEGIN MONITORING     
            $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
            
            if($query.msuMigrationDetails.status -ne $Status) {
                Write-Host "[ddmc]: Monitor status = $($query.msuMigrationDetails.status), sleeping 60 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 60
            }
            
        }
        until($query.msuMigrationDetails.status -eq $Status)

        return $query
    }
}

function set-migrationcommit {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true)]
        [int]$MigrationId,
        [Parameter( Mandatory=$true)]
        [bool]$DeleteSourceMsu
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units/migrations/$($MigrationId)/commit"
        $Body = [ordered]@{
            msu_migration_commit = @{
                deleteSourceMsu = $DeleteSourceMsu
            }
        }
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method POST `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -Body ($Body | convertto-json) `
            -SkipCertificateCheck
        
      
        return $query.MsuMigrationInfo.msuMigrationDetails
    }
}

function set-migrationcancel {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true)]
        [int]$MigrationId
    )
    begin {
    }
    process {
        $Endpoint = "api/v1/storage-units/migrations/$($MigrationId)/cancel"
        # WAIT FIVE MINUTES TO DELETE THE JOB 
        # IS THIS A BUG? IT FAILS IF YOU DO IT AS SOON AS THE MONITOR RETRUNS MIGRATION_CUTOVER_COMPLETE
        Start-Sleep -Seconds 300
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method POST `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.msuMigrationDetails
    }
}