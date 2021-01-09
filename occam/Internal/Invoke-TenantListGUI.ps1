function Invoke-TenantListGui {
  [CmdletBinding()]
  Param
  (
      [Parameter(Mandatory=$True,  Position= 0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)][Array]$tenants
  )

  <# This form was created using POSHGUI.com  a free online gui designer for PowerShell
  .NAME
      o365auditutil
  #>
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.Application]::EnableVisualStyles()
  $Form                            = New-Object system.Windows.Forms.Form
  $Form.ClientSize                 = '498,325'
  $Form.text                       = "OCCAM"
  $Form.BackColor                  = "#171837"
  $Form.TopMost                    = $false
  $Form.BackgroundImage = $FormImage
  $Label1                          = New-Object system.Windows.Forms.Label
  $Label1.text                     = "Select Tenant(s):"
  $Label1.AutoSize                 = $true
  $Label1.width                    = 25
  $Label1.height                   = 10
  $Label1.location                 = New-Object System.Drawing.Point(68,27)
  $Label1.Font                     = 'Microsoft Sans Serif,10,style=Bold'
  $Label1.ForeColor                = "#ffffff"
  $listbox                         = New-Object system.Windows.Forms.ListBox
  $listbox.BackColor               = "#171837"
  $listbox.ForeColor               = "#ffffff"
  $listbox.text                    = "listBox"
  $listbox.BorderStyle               = 1
  $listbox.width                   = 354
  $listbox.height                  = 171
  $listbox.location                = New-Object System.Drawing.Point(68,65)
  $listbox.SelectionMode           = 'MultiExtended'
  foreach ($tenant in ($tenants.Name | Sort-Object)) {
      [void] $listbox.Items.Add($tenant)
  }
  $OK                              = New-Object system.Windows.Forms.Button
  $OK.BackColor                    = "#7f4bae"
  $OK.text                         = "Next"
  $OK.width                        = 96
  $OK.height                       = 30
  $OK.location                     = New-Object System.Drawing.Point(327,263)
  $OK.Font                         = 'Microsoft Sans Serif,10,style=Bold'
  $OK.ForeColor                    = "#ffffff"
  $OK.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $OK
  $form.Controls.Add($OK)
  $logobox                         = New-Object system.Windows.Forms.PictureBox
  $logobox.width                   = 148
  $logobox.height                  = 31
  $logobox.location                = New-Object System.Drawing.Point(68,261)
  $logobox.Load('https://s3-us-west-2.amazonaws.com/pliancy-public-test/lockup.png')
  $logobox.SizeMode                = [System.Windows.Forms.PictureBoxSizeMode]::zoom
  $Form.controls.AddRange(@($Label1,$listbox,$OK,$logobox))
  $form.Controls.Add($listBox)
  $form.Topmost = $true
  $result = $form.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK)
  {
      return $listBox.SelectedItems
  }
}