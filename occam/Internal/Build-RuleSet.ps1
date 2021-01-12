function Build-RuleSet {
  $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
  $RulePath = "$ModuleBase\Rules"

  # Populate rule name list by grabbing any files in the Rules directory
  $Rules = Get-ChildItem -Path "$RulePath" -Filter *.ps1 -Recurse | ForEach-Object { $_.BaseName }

  $FormattedRuleSet = @()
  
  $i = 0
  foreach($Rule in $Rules) {
    Write-Progress -Activity "Building Rule Set" -PercentComplete ($i / $Rules.count * 100) -CurrentOperation "Importing Rule $Rule"
    # Load the rule as a module
    Import-Module "$RulePath\$Rule.ps1" -Force

    $RuleHelp = Get-Help $Rule
    $FormattedRuleSet += @{
      Name = $Rule;
      OutputKeys = $RuleHelp.returnvalues.returnValue.type.name.Split([Environment]::NewLine);
      Synopsis = $RuleHelp.SYNOPSIS;
      Path = "$RulePath\$Rule.ps1"
    }
    $i++
  }

  Write-Progress -Activity "Building Rule Set" -PercentComplete 100 -CurrentOperation ("Successfully Imported {0} Rules" -f $Rules.count)
  
  return $FormattedRuleSet
}
