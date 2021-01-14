 <#
.SYNOPSIS
Report users with a non-default authentication policy

.OUTPUTS
#>
function Find-NonDefaultAuthPolicyUsers {
  param ()
  Begin {
    $DefaultPolicy = (Get-OrganizationConfig).DefaultAuthenticationPolicy
    $Users = @(Get-User -ResultSize Unlimited)

    $Properties = @(
      "UserPrincipalName",
      "DisplayName",
      "AuthenticationPolicy",
      "AccountDisabled",
      "Guid",
      "SID"
    )
  }
  Process {

    # Find users without the default authentication policy
    $NonDefaultAuthPolicyUsers = $Users | Where-Object {$_.AuthenticationPolicy -ne $DefaultPolicy}

    # Filter out only select properties
    $NonDefaultAuthPolicyUsers = $NonDefaultAuthPolicyUsers | Select-Object -Property $Properties

    if ($NonDefaultAuthPolicyUsers.Count) {
      # Create an output directory and export as CSV
      New-Item -ItemType Directory -Force -Path $OCCAM:OutputDir | Out-Null
      $NonDefaultAuthPolicyUsers | ConvertTo-Csv -NoTypeInformation | Out-File ('{0}/users.csv' -f $OCCAM:OutputDir) -Force
    }


    $output = @{}

    return $output
  }
  End {

  }
}