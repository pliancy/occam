 <#
.SYNOPSIS
Return the default authentication policy for the tenant

.OUTPUTS
DefaultAuthPolicy
#>
function Test-DefaultAuthPolicy {
  param ()
  Begin {
    $OrganizationConfig = Get-OrganizationConfig
  }
  Process {
    $output = @{
      DefaultAuthPolicy = ($OrganizationConfig.DefaultAuthenticationPolicy -eq $BlockBasicAuth)
    }

    return $output
  }
  End {

  }
}