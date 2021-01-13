function Remove-MsolProxy {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [System.Guid]$TenantId
  )
  $tmpModulePath = "$($env:TEMP)\occam\$($TenantId)"
  Remove-Item $tmpModulePath -Recurse -Force 
}