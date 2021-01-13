function Build-MsolProxy {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [System.Guid]$TenantId
  )
  $commands = Get-Command -Module MSOnline

  $tmpModulePath = "$($env:TEMP)\occam\$($TenantId)"
  New-Item -ItemType Directory -Force -Path $tmpModulePath | Out-Null

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

    $proxyAsFunction = "function $($command.Name) { `n $proxy `n }"

    # temporarily export as a .ps1
    # this is needed because PowerShell does not have a mechanism for dot sourcing
    # data in a script. Because the proxy command uses begin/process/end blocks,
    # Invoke-Expression and New-Module cannot handle it as a scriptblock
    $tmpFilePath = "$($tmpModulePath)\$($command.Name).ps1"
    $proxyAsFunction | Out-File $tmpFilePath -Force

    $functionsToExport += $tmpFilePath
  }

  New-ModuleManifest -Path "$tmpModulePath\MSOL_$tenantId.psd1" -NestedModules $functionsToExport -Author OCCAM

  return "$tmpModulePath\MSOL_$tenantId.psd1"
}
