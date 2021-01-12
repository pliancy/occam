# OCCAM - O365 Configuration Compliance Audit Manager

![O365 Configuration Compliance Audit Manager](logo.png)

----

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/occam?color=%237f4bae) ![GitHub](https://img.shields.io/github/license/pliancy/occam)

OCCAM is an open-source toolkit for testing Office365 tenants against a set of security and compliance best practices. It is built for CSPs managing multiple tenants, though a future version will allow for use without CSP membership.

## Install

OCCAM can be installed via the PowerShell Gallery:

```ps1
Install-Module -Name occam
```

## Usage

:warning: Currently the O365 commands this module relies on are only supported on Windows

Import the module and run the `Invoke-Occam` command to begin an Occam audit.

```ps1
Import-Module occam
Invoke-Occam
```

You will be prompted to enter your CSP-level User Principal Name and go through a modern auth workflow to log in. At that point, you will be prompted to select what tenents you wish to audit. Progress bars will indicate status, and final output is similar to the following example:

![Example Output Screenshot](example.png)

The output will also be saved to a CSV with an execution timestamp.

## Default Rules

A set of pre-made best practices have been bundled with this module. They include:

1. `Test-BasicAuthPolicies` - Checks to ensure that authentication policies block basic authentication mechanisms
2. `Test-PopImap` - Checks for any users that have POP or IMAP enabled and exports a CSV list of them
3. `Test-UnifiedAuditLogging` - Checks that Unified Audit Logging is enabled on the tenant

Additional rules can be added by inserting a compliant rule file into the `Rules` directory in the module. Rulesets are dynamically evaluated at run-time.

## Writing Custom Rules

A Rule is an arbitrary PowerShell script enriched with metadata that returns a hashtable of boolean pass/fail values. Albeit simple, Rules are flexible and powerful - anything you can write in PowerShell can be packaged as a Rule and evaluated against every Office365 tenant you manage.

Rules are `.ps1` files expected to have the same name as the function contained within them. Any `.ps1` files in the `Rules` module directory are dynamically built into a RuleSet on runtime and evaluated.

### Rule Execution Environment

Rules are ran in an environment that has the [MSOnline](https://docs.microsoft.com/en-us/powershell/module/msonline/) and [ExchangeOnlineManagement](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2) modules pre-loaded and authenticated to the given tenant the Rule is being evaluated against. All cmdlets and functions in those modules are available for immediate use.

### Rule Output

Rules are expected to return a hashtable of key/value pairs corresponding to the test case(s) the Rule evaluates. Each value is expected to be a boolean, as Rules are meant to evaluate to a simple Pass/Fail criteria.

```ps1
@{
  ImapDisabled = $false
  PopDisabled = $true
}
```

 If more robust information is needed (e.g., a list of authentication policies with Basic Auth enabled), it is suggested to export that information as a CSV.

### Rule Metadata

OCCAM uses PowerShell's built-in Help syntax to dynamically gain metadata about each Rule. The `.SYNOPSIS` help value is presented to the user during runtime in a PowerShell progress bar. This helps provide the user with an indication of what action is being performed, which is important for longer-running Rules. Any string is supported, but it is best to keep the string short and descriptive.

The `.OUTPUTS` help value is expected to contain a list of keys matching exactly the keys present in the hashtable the Rule returns. Each output key is to be separated by a new line.

The following is an example of the `Test-PopImap` Rule that is pre-packaged with OCCAM. It contains a synopsis, two outputs, and makes use of an ExchangeOnlineManagement cmdlet:

```ps1
<#
.SYNOPSIS
Test that POP and IMAP are disabled on all mailbox plans

.OUTPUTS
ImapDisabled
PopDisabled
#>
function Test-PopImap {
  param ()
  Begin {
    $MailboxPlans = Get-CasMailboxPlan
  }
  Process {
    $output = @{
      ImapDisabled = !(@($MailboxPlans.ImapEnabled) -contains $true)
      PopDisabled = !(@($MailboxPlans.PopEnabled) -contains $true)
    }

    return $output
  }
  End {

  }
}
```
