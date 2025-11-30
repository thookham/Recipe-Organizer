param(
    [string]$SourcePath,
    [string]$DestinationPath,
    [string]$Mode,
    [switch]$NoRecurse,
    [switch]$AutoRun
)

# DEBUG LOGGING
$DebugLog = "C:\Users\thook\Documents\Antigravity\Recipe Finder\debug_log.txt"
"--- Run at $(Get-Date) ---" | Out-File $DebugLog -Append
"Source: '$SourcePath'" | Out-File $DebugLog -Append
"Dest: '$DestinationPath'" | Out-File $DebugLog -Append
"Mode: '$Mode'" | Out-File $DebugLog -Append
"AutoRun: $AutoRun" | Out-File $DebugLog -Append

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Emoji Helpers ---
function Get-Emoji {
    param ([int]$Code)
    return [char]::ConvertFromUtf32($Code)
}

$e_cooking = Get-Emoji 0x1F373
$e_salad = Get-Emoji 0x1F957
$e_folder = Get-Emoji 0x1F4C2
$e_target = Get-Emoji 0x1F3AF
$e_gear = [char]0x2699
$e_no = Get-Emoji 0x1F6AB
$e_rocket = Get-Emoji 0x1F680
$e_memo = Get-Emoji 0x1F4DD
$e_monkey = Get-Emoji 0x1F648
$e_party = Get-Emoji 0x1F389
$e_pan = Get-Emoji 0x1F958

# --- Colors ---
$c_header = [System.Drawing.Color]::FromArgb(255, 255, 140, 0) # Dark Orange
$c_bg = [System.Drawing.Color]::WhiteSmoke
$c_btn_action = [System.Drawing.Color]::FromArgb(255, 46, 204, 113) # Emerald Green
$c_btn_text = [System.Drawing.Color]::White
$c_text = [System.Drawing.Color]::FromArgb(255, 44, 62, 80) # Dark Blue/Grey

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "$e_cooking Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $c_bg
$form.ForeColor = $c_text

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI Emoji", 14, [System.Drawing.FontStyle]::Bold)
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontEmoji = New-Object System.Drawing.Font("Segoe UI Emoji", 10)
$fontEmojiBold = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9)

# --- Header Panel ---
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size = New-Object System.Drawing.Size(600, 60)
$pnlHeader.BackColor = $c_header
$form.Controls.Add($pnlHeader)

$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Organize your recipies $e_salad"
$lblHeader.Location = New-Object System.Drawing.Point(0, 0)
$lblHeader.Size = New-Object System.Drawing.Size(600, 60)
$lblHeader.Font = $fontTitle
$lblHeader.ForeColor = [System.Drawing.Color]::White
$lblHeader.TextAlign = "MiddleCenter"
$lblHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblHeader)

# --- Main Content Panel ---
$pnlMain = New-Object System.Windows.Forms.Panel
$pnlMain.Location = New-Object System.Drawing.Point(0, 60)
$pnlMain.Size = New-Object System.Drawing.Size(600, 340)
$form.Controls.Add($pnlMain)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "$e_folder Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 20)
$lblSource.AutoSize = $true
$lblSource.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 45)
$txtSource.Size = New-Object System.Drawing.Size(450, 25)
# Use param if provided, else default
$txtSource.Text = if ($SourcePath) { $SourcePath } else { [Environment]::GetFolderPath("MyDocuments") }
$txtSource.Font = $fontRegular
$pnlMain.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse"
$btnSource.Location = New-Object System.Drawing.Point(480, 44)
$btnSource.Size = New-Object System.Drawing.Size(80, 27)
$btnSource.Font = $fontRegular
$btnSource.FlatStyle = "Flat"
$btnSource.BackColor = [System.Drawing.Color]::White
$btnSource.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtSource.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtSource.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnSource)

# --- Destination Path ---
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "$e_target Destination Folder:"
$lblDest.Location = New-Object System.Drawing.Point(20, 80)
$lblDest.AutoSize = $true
$lblDest.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 105)
$txtDest.Size = New-Object System.Drawing.Size(450, 25)
$txtDest.Text = if ($DestinationPath) { $DestinationPath } else { "C:\Recipes" }
$txtDest.Font = $fontRegular
$pnlMain.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse"
$btnDest.Location = New-Object System.Drawing.Point(480, 104)
$btnDest.Size = New-Object System.Drawing.Size(80, 27)
$btnDest.Font = $fontRegular
$btnDest.FlatStyle = "Flat"
$btnDest.BackColor = [System.Drawing.Color]::White
$btnDest.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtDest.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtDest.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnDest)

# --- Options ---
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = "$e_gear Mode:"
$lblMode.Location = New-Object System.Drawing.Point(20, 150)
$lblMode.AutoSize = $true
$lblMode.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblMode)

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(90, 147)
$cmbMode.Size = New-Object System.Drawing.Size(100, 25)
$cmbMode.Items.AddRange(@("Test", "Copy", "Move"))
$cmbMode.SelectedIndex = if ($Mode -and $cmbMode.Items.Contains($Mode)) { $cmbMode.Items.IndexOf($Mode) } else { 0 }
$cmbMode.DropDownStyle = "DropDownList"
$cmbMode.Font = $fontRegular
$pnlMain.Controls.Add($cmbMode)

$chkNoRecurse = New-Object System.Windows.Forms.CheckBox
$chkNoRecurse.Text = "$e_no Top folder only (No Recursion)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(220, 148)
$chkNoRecurse.AutoSize = $true
if ($NoRecurse) { $chkNoRecurse.Checked = $true }
$chkNoRecurse.Font = $fontEmoji
$pnlMain.Controls.Add($chkNoRecurse)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 190)
$progressBar.Size = New-Object System.Drawing.Size(540, 10)
$progressBar.Style = "Marquee"
$progressBar.MarqueeAnimationSpeed = 0
$pnlMain.Controls.Add($progressBar)

# --- Status Label ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to organize! $e_cooking"
$lblStatus.Location = New-Object System.Drawing.Point(20, 210)
$lblStatus.Size = New-Object System.Drawing.Size(300, 25)
$lblStatus.Font = $fontEmoji
$pnlMain.Controls.Add($lblStatus)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "$e_rocket Start Organizing"
$btnRun.Location = New-Object System.Drawing.Point(340, 220)
$btnRun.Size = New-Object System.Drawing.Size(220, 50)
$btnRun.Font = $fontEmojiBold
$btnRun.BackColor = $c_btn_action
$btnRun.ForeColor = $c_btn_text
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$pnlMain.Controls.Add($btnRun)

# --- Toggle Log Button ---
$btnLog = New-Object System.Windows.Forms.Button
$btnLog.Text = "Show Log $e_memo"
$btnLog.Location = New-Object System.Drawing.Point(20, 245)
$btnLog.Size = New-Object System.Drawing.Size(120, 25)
$btnLog.Font = $fontEmoji
$btnLog.FlatStyle = "Flat"
$btnLog.BackColor = [System.Drawing.Color]::White
$pnlMain.Controls.Add($btnLog)

# --- Output Log ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 280)
$txtLog.Size = New-Object System.Drawing.Size(540, 180)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = $fontLog
$txtLog.BackColor = "White"
$pnlMain.Controls.Add($txtLog)

# --- Animation Timer ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$e_no = Get-Emoji 0x1F6AB
$e_rocket = Get-Emoji 0x1F680
$e_memo = Get-Emoji 0x1F4DD
$e_monkey = Get-Emoji 0x1F648
$e_party = Get-Emoji 0x1F389
$e_pan = Get-Emoji 0x1F958

# --- Colors ---
$c_header = [System.Drawing.Color]::FromArgb(255, 255, 140, 0) # Dark Orange
$c_bg = [System.Drawing.Color]::WhiteSmoke
$c_btn_action = [System.Drawing.Color]::FromArgb(255, 46, 204, 113) # Emerald Green
$c_btn_text = [System.Drawing.Color]::White
$c_text = [System.Drawing.Color]::FromArgb(255, 44, 62, 80) # Dark Blue/Grey

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "$e_cooking Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $c_bg
$form.ForeColor = $c_text

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI Emoji", 14, [System.Drawing.FontStyle]::Bold)
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontEmoji = New-Object System.Drawing.Font("Segoe UI Emoji", 10)
$fontEmojiBold = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9)

# --- Header Panel ---
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size = New-Object System.Drawing.Size(600, 60)
$pnlHeader.BackColor = $c_header
$form.Controls.Add($pnlHeader)

$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Organize your recipies $e_salad"
$lblHeader.Location = New-Object System.Drawing.Point(0, 0)
$lblHeader.Size = New-Object System.Drawing.Size(600, 60)
$lblHeader.Font = $fontTitle
$lblHeader.ForeColor = [System.Drawing.Color]::White
$lblHeader.TextAlign = "MiddleCenter"
$lblHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblHeader)

# --- Main Content Panel ---
$pnlMain = New-Object System.Windows.Forms.Panel
$pnlMain.Location = New-Object System.Drawing.Point(0, 60)
$pnlMain.Size = New-Object System.Drawing.Size(600, 340)
$form.Controls.Add($pnlMain)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "$e_folder Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 20)
$lblSource.AutoSize = $true
$lblSource.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 45)
$txtSource.Size = New-Object System.Drawing.Size(450, 25)
# Use param if provided, else default
$txtSource.Text = if ($SourcePath) { $SourcePath } else { [Environment]::GetFolderPath("MyDocuments") }
$txtSource.Font = $fontRegular
$pnlMain.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse"
$btnSource.Location = New-Object System.Drawing.Point(480, 44)
$btnSource.Size = New-Object System.Drawing.Size(80, 27)
$btnSource.Font = $fontRegular
$btnSource.FlatStyle = "Flat"
$btnSource.BackColor = [System.Drawing.Color]::White
$btnSource.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtSource.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtSource.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnSource)

# --- Destination Path ---
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "$e_target Destination Folder:"
$lblDest.Location = New-Object System.Drawing.Point(20, 80)
$lblDest.AutoSize = $true
$lblDest.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 105)
$txtDest.Size = New-Object System.Drawing.Size(450, 25)
$txtDest.Text = if ($DestinationPath) { $DestinationPath } else { "C:\Recipes" }
$txtDest.Font = $fontRegular
$pnlMain.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse"
$btnDest.Location = New-Object System.Drawing.Point(480, 104)
$btnDest.Size = New-Object System.Drawing.Size(80, 27)
$btnDest.Font = $fontRegular
$btnDest.FlatStyle = "Flat"
$btnDest.BackColor = [System.Drawing.Color]::White
$btnDest.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtDest.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtDest.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnDest)

# --- Options ---
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = "$e_gear Mode:"
$lblMode.Location = New-Object System.Drawing.Point(20, 150)
$lblMode.AutoSize = $true
$lblMode.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblMode)

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(90, 147)
$cmbMode.Size = New-Object System.Drawing.Size(100, 25)
$cmbMode.Items.AddRange(@("Test", "Copy", "Move"))
$cmbMode.SelectedIndex = if ($Mode -and $cmbMode.Items.Contains($Mode)) { $cmbMode.Items.IndexOf($Mode) } else { 0 }
$cmbMode.DropDownStyle = "DropDownList"
$cmbMode.Font = $fontRegular
$pnlMain.Controls.Add($cmbMode)

$chkNoRecurse = New-Object System.Windows.Forms.CheckBox
$chkNoRecurse.Text = "$e_no Top folder only (No Recursion)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(220, 148)
$chkNoRecurse.AutoSize = $true
if ($NoRecurse) { $chkNoRecurse.Checked = $true }
$chkNoRecurse.Font = $fontEmoji
$pnlMain.Controls.Add($chkNoRecurse)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 190)
$progressBar.Size = New-Object System.Drawing.Size(540, 10)
$progressBar.Style = "Marquee"
$progressBar.MarqueeAnimationSpeed = 0
$pnlMain.Controls.Add($progressBar)

# --- Status Label ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to organize! $e_cooking"
$lblStatus.Location = New-Object System.Drawing.Point(20, 210)
$lblStatus.Size = New-Object System.Drawing.Size(300, 25)
$lblStatus.Font = $fontEmoji
$pnlMain.Controls.Add($lblStatus)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "$e_rocket Start Organizing"
$btnRun.Location = New-Object System.Drawing.Point(340, 220)
$btnRun.Size = New-Object System.Drawing.Size(220, 50)
$btnRun.Font = $fontEmojiBold
$btnRun.BackColor = $c_btn_action
$btnRun.ForeColor = $c_btn_text
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$pnlMain.Controls.Add($btnRun)

# --- Toggle Log Button ---
$btnLog = New-Object System.Windows.Forms.Button
$btnLog.Text = "Show Log $e_memo"
$btnLog.Location = New-Object System.Drawing.Point(20, 245)
$btnLog.Size = New-Object System.Drawing.Size(120, 25)
$btnLog.Font = $fontEmoji
$btnLog.FlatStyle = "Flat"
$btnLog.BackColor = [System.Drawing.Color]::White
$pnlMain.Controls.Add($btnLog)

# --- Output Log ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 280)
$txtLog.Size = New-Object System.Drawing.Size(540, 180)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = $fontLog
$txtLog.BackColor = "White"
$pnlMain.Controls.Add($txtLog)

# --- Animation Timer ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$e_no = Get-Emoji 0x1F6AB
$e_rocket = Get-Emoji 0x1F680
$e_memo = Get-Emoji 0x1F4DD
$e_monkey = Get-Emoji 0x1F648
$e_party = Get-Emoji 0x1F389
$e_pan = Get-Emoji 0x1F958

# --- Colors ---
$c_header = [System.Drawing.Color]::FromArgb(255, 255, 140, 0) # Dark Orange
$c_bg = [System.Drawing.Color]::WhiteSmoke
$c_btn_action = [System.Drawing.Color]::FromArgb(255, 46, 204, 113) # Emerald Green
$c_btn_text = [System.Drawing.Color]::White
$c_text = [System.Drawing.Color]::FromArgb(255, 44, 62, 80) # Dark Blue/Grey

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "$e_cooking Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $c_bg
$form.ForeColor = $c_text

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI Emoji", 14, [System.Drawing.FontStyle]::Bold)
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 10)
$fontEmoji = New-Object System.Drawing.Font("Segoe UI Emoji", 10)
$fontEmojiBold = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9)

# --- Header Panel ---
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size = New-Object System.Drawing.Size(600, 60)
$pnlHeader.BackColor = $c_header
$form.Controls.Add($pnlHeader)

$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Organize your recipies $e_salad"
$lblHeader.Location = New-Object System.Drawing.Point(0, 0)
$lblHeader.Size = New-Object System.Drawing.Size(600, 60)
$lblHeader.Font = $fontTitle
$lblHeader.ForeColor = [System.Drawing.Color]::White
$lblHeader.TextAlign = "MiddleCenter"
$lblHeader.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($lblHeader)

# --- Main Content Panel ---
$pnlMain = New-Object System.Windows.Forms.Panel
$pnlMain.Location = New-Object System.Drawing.Point(0, 60)
$pnlMain.Size = New-Object System.Drawing.Size(600, 340)
$form.Controls.Add($pnlMain)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "$e_folder Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 20)
$lblSource.AutoSize = $true
$lblSource.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 45)
$txtSource.Size = New-Object System.Drawing.Size(450, 25)
# Use param if provided, else default
$txtSource.Text = if ($SourcePath) { $SourcePath } else { [Environment]::GetFolderPath("MyDocuments") }
$txtSource.Font = $fontRegular
$pnlMain.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse"
$btnSource.Location = New-Object System.Drawing.Point(480, 44)
$btnSource.Size = New-Object System.Drawing.Size(80, 27)
$btnSource.Font = $fontRegular
$btnSource.FlatStyle = "Flat"
$btnSource.BackColor = [System.Drawing.Color]::White
$btnSource.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtSource.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtSource.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnSource)

# --- Destination Path ---
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "$e_target Destination Folder:"
$lblDest.Location = New-Object System.Drawing.Point(20, 80)
$lblDest.AutoSize = $true
$lblDest.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 105)
$txtDest.Size = New-Object System.Drawing.Size(450, 25)
$txtDest.Text = if ($DestinationPath) { $DestinationPath } else { "C:\Recipes" }
$txtDest.Font = $fontRegular
$pnlMain.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse"
$btnDest.Location = New-Object System.Drawing.Point(480, 104)
$btnDest.Size = New-Object System.Drawing.Size(80, 27)
$btnDest.Font = $fontRegular
$btnDest.FlatStyle = "Flat"
$btnDest.BackColor = [System.Drawing.Color]::White
$btnDest.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtDest.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtDest.Text = $dlg.SelectedPath
        }
    })
$pnlMain.Controls.Add($btnDest)

# --- Options ---
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = "$e_gear Mode:"
$lblMode.Location = New-Object System.Drawing.Point(20, 150)
$lblMode.AutoSize = $true
$lblMode.Font = $fontEmojiBold
$pnlMain.Controls.Add($lblMode)

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(90, 147)
$cmbMode.Size = New-Object System.Drawing.Size(100, 25)
$cmbMode.Items.AddRange(@("Test", "Copy", "Move"))
$cmbMode.SelectedIndex = if ($Mode -and $cmbMode.Items.Contains($Mode)) { $cmbMode.Items.IndexOf($Mode) } else { 0 }
$cmbMode.DropDownStyle = "DropDownList"
$cmbMode.Font = $fontRegular
$pnlMain.Controls.Add($cmbMode)

$chkNoRecurse = New-Object System.Windows.Forms.CheckBox
$chkNoRecurse.Text = "$e_no Top folder only (No Recursion)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(220, 148)
$chkNoRecurse.AutoSize = $true
if ($NoRecurse) { $chkNoRecurse.Checked = $true }
$chkNoRecurse.Font = $fontEmoji
$pnlMain.Controls.Add($chkNoRecurse)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 190)
$progressBar.Size = New-Object System.Drawing.Size(540, 10)
$progressBar.Style = "Marquee"
$progressBar.MarqueeAnimationSpeed = 0
$pnlMain.Controls.Add($progressBar)

# --- Status Label ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to organize! $e_cooking"
$lblStatus.Location = New-Object System.Drawing.Point(20, 210)
$lblStatus.Size = New-Object System.Drawing.Size(300, 25)
$lblStatus.Font = $fontEmoji
$pnlMain.Controls.Add($lblStatus)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
# Initial text based on selection
switch ($cmbMode.SelectedItem) {
    "Test" { $btnRun.Text = "$e_rocket Test Organization" }
    "Copy" { $btnRun.Text = "$e_rocket Copy Files" }
    "Move" { $btnRun.Text = "$e_rocket Move Files" }
    Default { $btnRun.Text = "$e_rocket Start Organizing" }
}
$btnRun.Location = New-Object System.Drawing.Point(340, 220)
$btnRun.Size = New-Object System.Drawing.Size(220, 50)
$btnRun.Font = $fontEmojiBold
$btnRun.BackColor = $c_btn_action
$btnRun.ForeColor = $c_btn_text
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$pnlMain.Controls.Add($btnRun)

# --- Toggle Log Button ---
$btnLog = New-Object System.Windows.Forms.Button
$btnLog.Text = "Show Log $e_memo"
$btnLog.Location = New-Object System.Drawing.Point(20, 245)
$btnLog.Size = New-Object System.Drawing.Size(120, 25)
$btnLog.Font = $fontEmoji
$btnLog.FlatStyle = "Flat"
$btnLog.BackColor = [System.Drawing.Color]::White
$pnlMain.Controls.Add($btnLog)

# --- Output Log ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 280)
$txtLog.Size = New-Object System.Drawing.Size(540, 180)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = $fontLog
$txtLog.BackColor = "White"
$pnlMain.Controls.Add($txtLog)

# --- Animation Timer ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$dotCount = 0
$timer.Add_Tick({
        $dotCount = ($dotCount + 1) % 4
        $dots = "." * $dotCount
        $lblStatus.Text = "Working$dots $e_pan"
    })

# --- Event Handlers ---
$isLogVisible = $false

# Update Run Button Text on Mode Change
$cmbMode.Add_SelectedIndexChanged({
        switch ($cmbMode.SelectedItem) {
            "Test" { $btnRun.Text = "$e_rocket Test Organization" }
            "Copy" { $btnRun.Text = "$e_rocket Copy Files" }
            "Move" { $btnRun.Text = "$e_rocket Move Files" }
        }
    })

$btnLog.Add_Click({
        Add-Content -Path "simulation_log.txt" -Value "DEBUG: Log Button Clicked. Current Visibility: $($txtLog.Visible)" -Force
        if ($txtLog.Visible) {
            $form.Height = 380
            $pnlMain.Size = New-Object System.Drawing.Size(600, 280)
            $txtLog.Visible = $false
            $btnLog.Text = "Show Log $e_memo"
        }
        else {
            $form.Height = 600
            $pnlMain.Size = New-Object System.Drawing.Size(600, 540)
            $txtLog.Visible = $true
            $btnLog.Text = "Hide Log $e_monkey"
        }
    })

$btnRun.Add_Click({
        $btnRun.Enabled = $false
        $btnRun.BackColor = [System.Drawing.Color]::Gray
        $txtLog.Clear()
        $txtLog.AppendText("Starting...`r`n")

        $progressBar.MarqueeAnimationSpeed = 30
        $timer.Start()
        $form.Refresh()

        # Check for in-memory function (Hosted Mode)
        if (Get-Command "Invoke-OrganizeRecipes" -ErrorAction SilentlyContinue) {
            $txtLog.AppendText("Running in Hosted Mode (Fast & Secure)...`r`n")
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Starting Hosted Mode" -Force

            # Get function definition to pass to the new runspace
            $funcDef = (Get-Command "Invoke-OrganizeRecipes").Definition
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Function Definition Length: $($funcDef.Length)" -Force

            # Create a new PowerShell instance for async execution
            $ps = [PowerShell]::Create()
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Runspace Created" -Force
    
            # Define the function in the new runspace
            [void]$ps.AddScript("function Invoke-OrganizeRecipes { $funcDef }")
            $ps.Invoke() # Execute definition
        
            if ($ps.HadErrors) {
                Add-Content -Path "simulation_log.txt" -Value "DEBUG: Errors defining function:" -Force
                foreach ($err in $ps.Streams.Error) {
                    Add-Content -Path "simulation_log.txt" -Value "DEBUG ERROR: $err" -Force
                }
            }
        
            $ps.Commands.Clear()
            $ps.Streams.ClearStreams()
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Function Injected" -Force

            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Source: $($txtSource.Text)" -Force
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Dest: $($txtDest.Text)" -Force

            [void]$ps.AddCommand("Invoke-OrganizeRecipes")
            [void]$ps.AddParameter("SourcePath", $txtSource.Text)
            [void]$ps.AddParameter("DestinationPath", $txtDest.Text)
            [void]$ps.AddParameter("Mode", $cmbMode.SelectedItem)
            if ($chkNoRecurse.Checked) { [void]$ps.AddParameter("NoRecurse", $true) }
            
            # Force Verbose to ensure we see output
            [void]$ps.AddParameter("Verbose", $true)
    
            Add-Content -Path "simulation_log.txt" -Value "DEBUG: Parameters Added" -Force
    
            # Redirect streams to capture output
            $outputCollection = New-Object System.Management.Automation.PSDataCollection[PSObject]
            $outputCollection.Add_DataAdded({
                    param($s, $e)
                    $items = $s.ReadAll()
                    foreach ($item in $items) {
                        $form.Invoke([Action] { $txtLog.AppendText("$item`r`n"); $txtLog.ScrollToCaret() })
                        Add-Content -Path "simulation_log.txt" -Value "$item" -ErrorAction SilentlyContinue
                    }
                })

            # Capture Errors
            $ps.Streams.Error.add_DataAdded({
                    param($s, $e)
                    $items = $s.ReadAll()
                    foreach ($item in $items) {
                        $form.Invoke([Action] { $txtLog.AppendText("ERROR: $item`r`n"); $txtLog.ScrollToCaret() })
                        Add-Content -Path "simulation_log.txt" -Value "ERROR: $item" -ErrorAction SilentlyContinue
                    }
                })

            # Capture Information (Write-Host)
            $ps.Streams.Information.add_DataAdded({
                    param($s, $e)
                    $items = $s.ReadAll()
                    foreach ($item in $items) {
                        $msg = $item.ToString()
                        $form.Invoke([Action] { $txtLog.AppendText("$msg`r`n"); $txtLog.ScrollToCaret() })
                        Add-Content -Path "simulation_log.txt" -Value "INFO: $msg" -ErrorAction SilentlyContinue
                    }
                })

            # Capture Verbose
            $ps.Streams.Verbose.add_DataAdded({
                    param($s, $e)
                    $items = $s.ReadAll()
                    foreach ($item in $items) {
                        $msg = $item.ToString()
                        $form.Invoke([Action] { $txtLog.AppendText("VERBOSE: $msg`r`n"); $txtLog.ScrollToCaret() })
                        Add-Content -Path "simulation_log.txt" -Value "VERBOSE: $msg" -ErrorAction SilentlyContinue
                    }
                })
        
            # Async Invoke
            $inputCollection = New-Object System.Management.Automation.PSDataCollection[PSObject]
            try {
                $asyncResult = $ps.BeginInvoke($inputCollection, $outputCollection)
                Add-Content -Path "simulation_log.txt" -Value "DEBUG: Async Invoke Started" -Force
            }
            catch {
                Add-Content -Path "simulation_log.txt" -Value "CRITICAL ERROR: BeginInvoke failed: $_" -Force
                $form.Invoke([Action] { $txtLog.AppendText("CRITICAL ERROR: BeginInvoke failed: $_`r`n") })
                $btnRun.Enabled = $true
                $btnRun.BackColor = $c_btn_action
                return
            }
        
            # Timer to check completion
            $checkTimer = New-Object System.Windows.Forms.Timer
            $checkTimer.Interval = 500
            $checkTimer.Add_Tick({
                    if ($asyncResult.IsCompleted) {
                        $checkTimer.Stop()
                        try {
                            $ps.EndInvoke($asyncResult)
                        }
                        catch {
                            $form.Invoke([Action] { $txtLog.AppendText("Execution Error: $_`r`n") })
                            Add-Content -Path "simulation_log.txt" -Value "Execution Error: $_" -ErrorAction SilentlyContinue
                        }
                        $ps.Dispose()
                
                        $timer.Stop()
                        $progressBar.MarqueeAnimationSpeed = 0
                        $progressBar.Value = 100
                        $progressBar.Style = "Blocks"
                
                        $lblStatus.Text = "Done! $e_party Bon Appétit!"
                        $txtLog.AppendText("Done.`r`n")
                        $btnRun.Enabled = $true
                        $btnRun.BackColor = $c_btn_action
                
                        # Auto-Close if AutoRun
                        if ($AutoRun) {
                            Start-Sleep -Seconds 1
                            $form.Close()
                        }
                    }
                })
            $checkTimer.Start()
            return
        }
    })

# --- AutoRun Logic ---
if ($AutoRun) {
    $form.Add_Shown({
            $btnRun.PerformClick()
        })
}

# --- Show Form ---
# Initial State: Log Hidden
$form.Height = 380
$pnlMain.Size = New-Object System.Drawing.Size(600, 280)
$txtLog.Visible = $false
$form.ShowDialog() | Out-Null
