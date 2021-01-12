 <#
.SYNOPSIS
Verify that authentication policies block basic auth

.OUTPUTS
BlockBasicAuthDefaultPolicy
BlockBasicAuthAllPolicies
#>
function Test-BasicAuthPolicies {
  param ()
  Begin {
    $AuthPolicies = @(Get-AuthenticationPolicy)
    $DefaultPolicy = (Get-OrganizationConfig).DefaultAuthenticationPolicy
    $BlockBasicAuthAllPolicies = $false
    $BlockBasicAuthDefaultPolicy = $false

    $BasicAuthMembers = @(
      "AllowBasicAuthActiveSync",
      "AllowBasicAuthAutodiscover",
      "AllowBasicAuthImap",
      "AllowBasicAuthMapi",
      "AllowBasicAuthOfflineAddressBook",
      "AllowBasicAuthOutlookService",
      "AllowBasicAuthPop",
      "AllowBasicAuthPowershell",
      "AllowBasicAuthReportingWebServices",
      "AllowBasicAuthRest",
      "AllowBasicAuthRpc",
      "AllowBasicAuthSmtp",
      "AllowBasicAuthWebServices"
    )
  }
  Process {
    if ($AuthPolicies.Count -ne 0) {
      $BlockBasicAuthAllPolicies = $true

      foreach ($Policy in $AuthPolicies) {
        # Let's check for basic auth being enabled in any category listed in the $BasicAuthMembers array
        $MemberValueArray = @()
        foreach ($Member in $BasicAuthMembers) {
          $MemberValueArray += $Policy.$Member
        }

        # if any form of basic auth is allowed, let's mark the policy as insecure
        $BlockAllBasicAuth = !([bool]($MemberValueArray -contains $true))

        # if this is the default policy, let's report that the default policy specifically is insecure
        if ($Policy.Name -eq $DefaultPolicy) {
          $BlockBasicAuthDefaultPolicy = $BlockAllBasicAuth
        }

        if ($BlockAllBasicAuth -eq $false) {
          $BlockBasicAuthAllPolicies = $false
        }
      }
    }

    # Export policy list
    # TODO

    $output = @{
      BlockBasicAuthDefaultPolicy = $BlockBasicAuthDefaultPolicy
      BlockBasicAuthAllPolicies = $BlockBasicAuthAllPolicies
    }

    return $output
  }
  End {

  }
}