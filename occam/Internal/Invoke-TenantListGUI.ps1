function Invoke-TenantListGui {
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )][Array]$tenants
    )

    $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase

    $colors = @{
        white  = "#ffffff";
        purple = "#7f4bae";
        navy   = "#171837"
    }

    <# This form was created using POSHGUI.com  a free online gui designer for PowerShell
    .NAME
        o365auditutil
    #>
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Form = New-Object system.Windows.Forms.Form
    $Form.Icon = [System.Drawing.Icon]::new("$ModuleBase/Assets/favicon.ico")
    $Form.ClientSize = '500,315'
    $Form.text = "Office365 Configuration Compliance Audit Manager"
    $Form.BackColor = $colors.navy
    $Form.TopMost = $false

    $Label = New-Object system.Windows.Forms.Label
    $Label.text = "Select Tenant(s):"
    $Label.AutoSize = $true
    $Label.width = 25
    $Label.height = 10
    $Label.location = New-Object System.Drawing.Point(68, 27)
    $Label.Font = 'Microsoft Sans Serif,10,style=Bold'
    $Label.ForeColor = $colors.white

    $ListBox = New-Object system.Windows.Forms.ListBox
    $ListBox.BackColor = $colors.navy
    $ListBox.ForeColor = $colors.white
    $ListBox.text = "listBox"
    $ListBox.BorderStyle = 1
    $ListBox.width = 354
    $ListBox.height = 171
    $ListBox.location = New-Object System.Drawing.Point(68, 55)
    $ListBox.SelectionMode = 'MultiExtended'
    foreach ($tenant in ($tenants.Name | Sort-Object)) {
        [void] $ListBox.Items.Add($tenant)
    }
    $OK = New-Object system.Windows.Forms.Button
    $OK.BackColor = $colors.purple
    $OK.text = "Next"
    $OK.width = 96
    $OK.height = 30
    $OK.location = New-Object System.Drawing.Point(325, 255)
    $OK.Font = 'Microsoft Sans Serif,10,style=Bold'
    $OK.ForeColor = $colors.white
    $OK.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OK
    $form.Controls.Add($OK)
    $logobox = New-Object system.Windows.Forms.PictureBox
    $logobox.width = 200
    $logobox.height = 30
    $logobox.location = New-Object System.Drawing.Point(68, 255)
    $logobox.Load("$ModuleBase/Assets/logo.png")
    $logobox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    $Form.Controls.AddRange(@($Label, $ListBox, $OK, $logobox))
    $form.Controls.Add($ListBox)
    $form.Topmost = $true
    $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ListBox.SelectedItems
    }
}