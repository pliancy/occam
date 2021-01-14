function Build-MsolProxy {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [System.Guid]$TenantId
  )

  $commands = Get-Command -Module MSOnline

  $functionsToExport = @()

  foreach ($command in $commands) {
    $metadata = New-Object System.Management.Automation.CommandMetaData $command

    # remove TenantId from command metadata
    $hasTenantIdParam = $metadata.Parameters.ContainsKey("TenantId")
    if ($hasTenantIdParam) {
      $metadata.Parameters.Remove("TenantId") | Out-Null
    }

    # create a proxy function that wraps the initial MSOnline cmdlet
    $proxy = [System.Management.Automation.ProxyCommand]::Create($metadata)

    # string-replace the PSBoundParameters splat operation to insert the -TenantId parameter
    # into the underlying command being called/wrapped
    if ($hasTenantIdParam) {
      $proxy = $proxy -replace '@PSBoundParameters', ('@PSBoundParameters -TenantId {0}' -f $TenantId)
    }

    # Pack the internals as a function
    $proxyAsFunction = "function $($command.Name) { `n $proxy `n }"

    # Append the full proxy function as a string onto an array
    $functionsToExport += $proxyAsFunction
  }

  # Concatenate all functions into one large string with new lines separating each
  $ScriptString = ($functionsToExport -join("`n"))

  # Convert the string to a scriptblock
  $ScriptBlock = [Scriptblock]::Create($ScriptString)

  # Load the proxy functions as a dynamic module into memory, and pipe to
  # the Import-Module command so we can clean it up with Remove-Module later
  New-Module -Name "MSOL_$TenantId" -ScriptBlock $ScriptBlock | Import-Module

  return "MSOL_$TenantId"
}
