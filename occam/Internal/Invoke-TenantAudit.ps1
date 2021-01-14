function Invoke-TenantAudit {
    param (
        [Object]$tenant,
        [String]$UPN,
        [Object]$RuleSet,
        [String]$ReportPath
    )
    $totalSteps = $RuleSet.length + 5
    $i = 0
    
    $FormattedTenant = @{
        Name = $tenant.Name
    }
    
    Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Connecting to Exchange Online"
    # Connect to client's Exchange Online using EXO V2
    try {
        Connect-ExchangeOnline -UserPrincipalName $UPN -DelegatedOrganization $tenant.Domain -ShowBanner:$false -ShowProgress:$false
        # Connect-IPPSSession -UserPrincipalName $UPN -DelegatedOrganization $tenant.Domain -ShowBanner:$false -ShowProgress:$false
    }
    catch {
        Write-Warning ("Failed to connect to Tenant {0}, skipping audit" -f $tenant.Name)
        Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete 100
        return New-Object PSObject -Property $FormattedTenant
    }

    # Clean up MSOnline proxy module
    $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Dynamically Generating MSOnline Proxy Module"
    $MsolProxyModulePath = Build-MsolProxy -TenantId $tenant.id
    Import-Module $MsolProxyModulePath

    # Generate PS Drive
    $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Creating Runtime Environment Variables"
    New-PSDrive -Name "OCCAM" -PSProvider Environment -Root . | Out-Null
    $OCCAM:TenantName = $tenant.Name
    $OCCAM:TenantId = $tenant.id
    $OCCAM:TenantDomain = $tenant.Domain
    $OCCAM:AuthenticatedUser = $UPN

    Write-Host "Report Path: $ReportPath"
    
    foreach ($Rule in $RuleSet) {
        # Set Rule-specific environment variables
        $OCCAM:OutputDir = "$ReportPath/$($tenant.Name)/$($Rule.Name)"
        $OCCAM:RuleName = $Rule.Name
        $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation $Rule.Synopsis
        try {
            Import-Module $Rule.Path -Force
            $output = Invoke-Expression $Rule.Name
            $FormattedTenant += $output
        }
        catch {
            Write-Warning ("Unable to run Rule {0} on Tenant {1}" -f $Rule.Name, $tenant.name)
        }
    }

    # Clean up PS Drive
    $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Cleaning up Runtime Environment Variables"
    Remove-PSDrive -Name "OCCAM" -Force

    # Clean up MSOnline proxy module
    $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Removing MSOnline Proxy Module"
    Remove-Module -Name "MSOL_$($tenant.id)" -Force
    Remove-MsolProxy -TenantId $tenant.id 

    # Disconnect from Exchange Online
    $i++; Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete ($i / $totalSteps * 100) -CurrentOperation "Disconnecting from Exchange Online"
    Disconnect-ExchangeOnline -Confirm:$false *> $null  
  
    Write-Progress -Activity ("Auditing {0}" -f $tenant.Name) -ParentId 1 -PercentComplete 100
    return New-Object PSObject -Property $FormattedTenant
}