<#
.SYNOPSIS
Check for Users with Basic Authentication enabled

.OUTPUTS
UserPoliciesSet
#>
function Test-UserBasicAuth {
  param ()
  Begin {
    $Users = Get-User
  }
  Process {
    $BasicAuthUsers = @($Users) | Where-Object {$_.AuthentionPolicy -ne $BlockBasicAuth}
    if ($BasicAuthUsers.Count) {
      $BasicAuthUsers | Select-Object -Property UserPrincipalName, FirstName, LastName, DisplayName, AuthenticationPolicy | ConvertTo-Csv -NoTypeInformation | Out-File ('./{0}/{1} - users_with_basic_auth.csv' -f $dirname, $tenant.Name)
    }

    $output = @{
      UserPoliciesSet = [bool]$BasicAuthUsers.Count
    }

    return $output
  }
  End {

  }
}

