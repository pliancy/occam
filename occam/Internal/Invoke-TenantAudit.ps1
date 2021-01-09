function Invoke-TenantAudit {
    param (
        [Object]$tenant,
        [String]$UPN,
        [Object]$RuleSet
    )
    $totalSteps = $RuleSet.length + 1
    $i = 0
    
    $FormattedTenant = @{
        Name = $tenant.Name
    }
    
    Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Connecting to Exchange Online"
    # Connect to client's Exchange Online and Security & Compliance Center using EXO V2
    try {
        Connect-ExchangeOnline -UserPrincipalName $UPN -DelegatedOrganization $tenant.Domain -ShowBanner:$false -ShowProgress:$false
        # Connect-IPPSSession -UserPrincipalName $UPN -DelegatedOrganization $tenant.Domain -ShowBanner:$false -ShowProgress:$false
    }
    catch {
        Write-Warning ("Failed to connect to Tenant {0}, skipping audit" -f $tenant.Name)
        Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete 100
        return New-Object PSObject -Property $FormattedTenant
    }

    $i = 0
    foreach ($Rule in $RuleSet) {
        $i++
        Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation $Rule.Synopsis
        try {
            Import-Module $Rule.Path -Force
            $output = Invoke-Expression $Rule.Name
            $FormattedTenant += $output
        }
        catch {
            Write-Warning ("Unable to run Rule {0} on Tenant {1}" -f $Rule.Name, $tenant.name)
        }
    }

    $i++
    Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Disconnecting from Exchange Online"

    Disconnect-ExchangeOnline -Confirm:$false *> $null  
  
    Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete 100
  
    return New-Object PSObject -Property $FormattedTenant
}