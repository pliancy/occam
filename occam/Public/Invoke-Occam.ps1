Function Invoke-Occam {
    [CmdletBinding()]
    param (
        [Alias("UPN")]
        [Parameter(Mandatory = $false)]
        [String]$UserPrincipalName = '',

        [Parameter()]
        [Switch]$NoDefaultRules = $false
    )
    Begin {
        # Load Rules
        $RuleSet = Build-RuleSet -NoDefaultRules:$NoDefaultRules

        # Create a folder to hold all results in, and add a timestamp for uniqueness
        $ReportPath = New-Item -Name ('Office365 Security Audit - {0}' -f (get-date -f yyyy-MM-dd_HH_mm_ss)) -ItemType "directory"
        $ReportPath = $ReportPath.Name
    }
    Process {
        if ([string]::IsNullOrEmpty($UserPrincipalName)) {
            $UserPrincipalName = Read-Host -Prompt "Please enter your CSP email"
        }

        try {
            Connect-MsolService
        }
        catch {
            Write-Error "Failure to connect to MSOnline Service"
            exit
        }

        # Get all tenants and domains
        $customers = Get-MsolPartnerContract -All
        $tenants = @()
        $i = 0
        foreach ($customer in $customers) {
            $i++
            Write-Progress -Activity "Getting Tenants" -PercentComplete ($i / $customers.count * 100) -CurrentOperation $domain
            $tenant = @{
                'id' = $customer.TenantId
                'Name' = $customer.Name
                'Domain' = $customer.DefaultDomainName
            }
            $tenants += $tenant
        }
        Write-Progress -Activity "Getting Tenants" -PercentComplete 100

        $selectedTenants = Invoke-TenantListGUI -Tenants $tenants

        $i = 0
        $formattedTenants = @()
        foreach ($selectedTenant in $selectedTenants) {
            $tenant = $tenants | Where-Object {$_.Name -eq $selectedTenant}
            Write-Progress -Activity "Auditing Tenants"  -Id 1 -PercentComplete ($i / $selectedTenants.count * 100)
            $formattedTenants += Invoke-TenantAudit -tenant $tenant -UPN $UserPrincipalName -RuleSet $RuleSet -ReportPath $ReportPath
            $i++
            
        }
        Write-Progress -Activity "Auditing Tenants" -Id 1 -PercentComplete 100
        
        # Strip empty values out of the array so that only valid keys are sent to the Select-Object cmdlet
        $RuleOutputKeys = $RuleSet.OutputKeys | Where-Object { $_ }
        # Prepend "Name" so that it shows up first
        $Properties = (,"Name" + $RuleOutputKeys)
        $formattedTenants = $formattedTenants | Select-Object -Property $Properties
        $formattedTenants | Write-PSObject -MatchMethod Exact -Column *, * -Value $false, $true -ValueForeColor Red, Green
        $formattedTenants | ConvertTo-Csv -NoTypeInformation | Out-File ('./{0}/results.csv' -f $ReportPath)
    }
    End {}
}
