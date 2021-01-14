function Build-RuleSet {
  [CmdletBinding()]
  param (
      [Parameter()]
      [Switch]$NoDefaultRules = $false
  )
  $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
  # $ModuleBase = ".\occam"
  $DefaultRulePath = "$ModuleBase\Rules"

  # Populate rule name list by grabbing any files in the Rules directory
  $Rules = @()

  # Discover additional rules in execution path
  $Rules += Get-ChildItem -Filter *.Rule.ps1 -Recurse
  
  # Get default (prepackaged) rules
  if (!$NoDefaultRules) {
    $Rules += Get-ChildItem -Path "$DefaultRulePath" -Filter *.Rule.ps1
  }

  $Rules = $Rules | Sort-Object -Property Name -Unique | ForEach-Object {@{ Name = ($_.Name.split(".") | Select-Object -First 1); Path = $_.VersionInfo.FileName  }}

  $FormattedRuleSet = @()
  
  $i = 0
  foreach($Rule in $Rules) {
    Write-Progress -Activity "Building Rule Set" -PercentComplete ($i / $Rules.count * 100) -CurrentOperation "Importing Rule $($Rule.Name)"
    # Load the rule as a module
    Import-Module $Rule.Path -Force

    $RuleHelp = Get-Help $Rule.Name
    $FormattedRuleSet += @{
      Name = $Rule.Name;
      OutputKeys = $RuleHelp.returnvalues.returnValue.type.name.Split([Environment]::NewLine);
      Synopsis = $RuleHelp.SYNOPSIS;
      Path = $Rule.Path
    }
    $i++
  }

  Write-Progress -Activity "Building Rule Set" -PercentComplete 100 -CurrentOperation ("Successfully Imported {0} Rules" -f $Rules.count)
  
  return $FormattedRuleSet
}
