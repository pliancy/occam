 <#
.SYNOPSIS
Verify that Unified Audit Logging is enabled

.OUTPUTS
UnifiedAuditLogging
#>
function Test-UnifiedAuditLogging {
  param ()
  Begin {
    $AuditConfig = Get-AdminAuditLogConfig
  }
  Process {
    $output = @{
      UnifiedAuditLogging = [bool]$AuditConfig.UnifiedAuditLogIngestionEnabled
    }

    return $output
  }
  End {

  }
}