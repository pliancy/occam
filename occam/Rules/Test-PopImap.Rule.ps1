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