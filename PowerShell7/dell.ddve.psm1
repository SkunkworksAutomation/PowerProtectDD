<#
    THIS CODE REQUIRES POWWERSHELL 7.x.(latest)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.2.6
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
                server = "https://$($Server):3009/api"
                token = $Headers['X-DD-AUTH-TOKEN'][0]
            } #END AUTH

            $global:AuthObject = $Auth
            $global:AuthObject | Format-List
    }
}

function get-alerts {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$false)]
        [array]$Filters
    )
    begin {
    }
    process {
        $Endpoint = "v1.0/dd-systems/0/alerts"

        if($Filters.Length -gt 0) {
            $Join = ($Filters -join ' ') -replace '\s','%20' -replace '"','%22' -replace '=','%3D'
            $Endpoint = "v1.0/dd-systems/0/alerts?filter=$($Join)"
        }
        $Endpoint
        
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.alert_list;
    }
}

function get-mtrees {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$false)]
        [array]$Filters
    )
    begin {
    }
    process {
        $Endpoint = "v1.0/dd-systems/0/mtrees"

        if($Filters.Length -gt 0) {
            $Join = ($Filters -join ' ') -replace '\s','%20' -replace '"','%22' -replace '=','%3D'
            $Endpoint = "v1.0/dd-systems/0/mtrees?filter=$($Join)"
        }

        $Endpoint
        
        #EXECUTE FILTERED QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server)/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query.mtree;
    }
}

function get-system {
    [CmdletBinding()]
    param(
    )
    begin {
    }
    process {
        $Endpoint = "v1.0/system"

        $Endpoint

        #EXECUTE QUERY     
        $query = Invoke-RestMethod -Uri "$($AuthObject.server -replace 'api','rest')/$($Endpoint)" `
            -Method GET `
            -ContentType 'application/json' `
            -Headers @{'X-DD-AUTH-TOKEN'= $AuthObject.token} `
            -SkipCertificateCheck
        
      
        return $query;
    }
}