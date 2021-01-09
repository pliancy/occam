# Courtesy of https://github.com/cisagov/Sparrow, with CC0-1.0 License
Function Import-PSModules{
  $ModuleArray = @("ExchangeOnlineManagement","MSOnline")

  ForEach ($ReqModule in $ModuleArray){
      If ($null -eq (Get-Module $ReqModule -ListAvailable -ErrorAction SilentlyContinue)){
          Write-Verbose "Required module, $ReqModule, is not installed on the system."
          Write-Verbose "Installing $ReqModule from default repository"
          Install-Module -Name $ReqModule -Force
          Write-Verbose "Importing $ReqModule"
          Import-Module -Name $ReqModule
      } ElseIf ($null -eq (Get-Module $ReqModule -ErrorAction SilentlyContinue)){
          Write-Verbose "Importing $ReqModule"
          Import-Module -Name $ReqModule
      }
  }
}