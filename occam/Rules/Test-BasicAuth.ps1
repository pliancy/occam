 <#
.SYNOPSIS
Verify that an authentication policy named "Block Basic Auth" exists

.OUTPUTS
AuthPolicyPresent
#>
function Test-BasicAuth {
  param ()
  Begin {
    $AuthPolicies = @(Get-AuthenticationPolicy)
  }
  Process {
    if ($AuthPolicies.Count -eq 0) {
      $AuthPolicyPresent = $false
    } else {
        $BasicAuth = $AuthPolicies | Where-Object ($_.Name -eq $BlockBasicAuth)
        if ($BasicAuth) {
            $AuthPolicyPresent = $true
        } else {
            $AuthPolicyPresent = $false
            Write-Warning ("Tenant {0} has 1 or more authentication policies, but none of them match the name 'Block Basic Auth'" -f $tenant.Name)
        }
    }

    $output = @{
      AuthPolicyPresent = $AuthPolicyPresent
    }

    return $output
  }
  End {

  }
}