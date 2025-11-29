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

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "$e_cooking Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 350)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# --- Fonts ---
# Segoe UI Emoji is good for emojis, but standard Segoe UI usually falls back correctly on Win10+
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 9)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9)

# --- Header ---
$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Organize Your Kitchen! $e_salad"
$lblHeader.Location = New-Object System.Drawing.Point(20, 10)
$lblHeader.Size = New-Object System.Drawing.Size(560, 30)
$lblHeader.Font = $fontTitle
$lblHeader.TextAlign = "MiddleCenter"
$form.Controls.Add($lblHeader)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "$e_folder Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 50)
$lblSource.AutoSize = $true
$lblSource.Font = $fontBold
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 75)
$txtSource.Size = New-Object System.Drawing.Size(450, 25)
$txtSource.Text = [Environment]::GetFolderPath("MyDocuments")
$txtSource.Font = $fontRegular
$form.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse"
$btnSource.Location = New-Object System.Drawing.Point(480, 74)
$btnSource.Size = New-Object System.Drawing.Size(80, 27)
$btnSource.Font = $fontRegular
$btnSource.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtSource.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtSource.Text = $dlg.SelectedPath
        }
    })
$form.Controls.Add($btnSource)

# --- Destination Path ---
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = "$e_target Destination Folder:"
$lblDest.Location = New-Object System.Drawing.Point(20, 110)
$lblDest.AutoSize = $true
$lblDest.Font = $fontBold
$form.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 135)
$txtDest.Size = New-Object System.Drawing.Size(450, 25)
$txtDest.Text = "C:\Recipes"
$txtDest.Font = $fontRegular
$form.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse"
$btnDest.Location = New-Object System.Drawing.Point(480, 134)
$btnDest.Size = New-Object System.Drawing.Size(80, 27)
$btnDest.Font = $fontRegular
$btnDest.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.SelectedPath = $txtDest.Text
        if ($dlg.ShowDialog() -eq "OK") {
            $txtDest.Text = $dlg.SelectedPath
        }
    })
$form.Controls.Add($btnDest)

# --- Options ---
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = "$e_gear Mode:"
$lblMode.Location = New-Object System.Drawing.Point(20, 180)
$lblMode.AutoSize = $true
$lblMode.Font = $fontBold
$form.Controls.Add($lblMode)

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(90, 177)
$cmbMode.Size = New-Object System.Drawing.Size(100, 25)
$cmbMode.Items.AddRange(@("Test", "Copy", "Move"))
$cmbMode.SelectedIndex = 0
$cmbMode.DropDownStyle = "DropDownList"
$cmbMode.Font = $fontRegular
$form.Controls.Add($cmbMode)

$chkNoRecurse = New-Object System.Windows.Forms.CheckBox
$chkNoRecurse.Text = "$e_no Top folder only (No Recursion)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(220, 178)
$chkNoRecurse.AutoSize = $true
$chkNoRecurse.Font = $fontRegular
$form.Controls.Add($chkNoRecurse)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 220)
$progressBar.Size = New-Object System.Drawing.Size(540, 20)
$progressBar.Style = "Marquee"
$progressBar.MarqueeAnimationSpeed = 0
$form.Controls.Add($progressBar)

# --- Status Label ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to organize! $e_cooking"
$lblStatus.Location = New-Object System.Drawing.Point(20, 245)
$lblStatus.Size = New-Object System.Drawing.Size(300, 20)
$lblStatus.Font = $fontRegular
$form.Controls.Add($lblStatus)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "$e_rocket Start Organizing"
$btnRun.Location = New-Object System.Drawing.Point(360, 250)
$btnRun.Size = New-Object System.Drawing.Size(200, 40)
$btnRun.Font = $fontBold
$btnRun.BackColor = "LightGreen"
$btnRun.FlatStyle = "Flat"
$form.Controls.Add($btnRun)

# --- Toggle Log Button ---
$btnLog = New-Object System.Windows.Forms.Button
$btnLog.Text = "Show Log $e_memo"
$btnLog.Location = New-Object System.Drawing.Point(20, 270)
$btnLog.Size = New-Object System.Drawing.Size(100, 25)
$btnLog.Font = $fontRegular
$btnLog.FlatStyle = "Popup"
$form.Controls.Add($btnLog)

# --- Output Log ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 310)
$txtLog.Size = New-Object System.Drawing.Size(540, 180)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = $fontLog
$txtLog.BackColor = "White"
$form.Controls.Add($txtLog)

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
$btnLog.Add_Click({
        if ($isLogVisible) {
            $form.Height = 350
            $btnLog.Text = "Show Log $e_memo"
            $isLogVisible = $false
        }
        else {
            $form.Height = 550
            $btnLog.Text = "Hide Log $e_monkey"
            $isLogVisible = $true
        }
    })

$btnRun.Add_Click({
        $btnRun.Enabled = $false
        $txtLog.Clear()
        $txtLog.AppendText("Starting...`r`n")
    
        $progressBar.MarqueeAnimationSpeed = 30
        $timer.Start()
        $form.Refresh()

        $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Organize-Recipes.ps1"
    
        if (-not (Test-Path $scriptPath)) {
            [System.Windows.Forms.MessageBox]::Show("Could not find Organize-Recipes.ps1", "Error", "OK", "Error")
            $btnRun.Enabled = $true
            $progressBar.MarqueeAnimationSpeed = 0
            $timer.Stop()
            return
        }

        # Use a string for the command to avoid parsing issues with &
        $cmd = "& `"$scriptPath`" -SourcePath `"$($txtSource.Text)`" -DestinationPath `"$($txtDest.Text)`" -Mode `"$($cmbMode.SelectedItem)`" -Verbose *>&1"
        if ($chkNoRecurse.Checked) {
            $cmd += " -NoRecurse"
        }

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "powershell.exe"
        $pinfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`""
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $pinfo.CreateNoWindow = $true
    
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
    
        while (-not $p.HasExited) {
            $line = $p.StandardOutput.ReadLine()
            if ($line) {
                $txtLog.AppendText($line + "`r`n")
                $txtLog.ScrollToCaret()
                $form.Refresh()
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
    
        $rest = $p.StandardOutput.ReadToEnd()
        if ($rest) { $txtLog.AppendText($rest + "`r`n") }
    
        $err = $p.StandardError.ReadToEnd()
        if ($err) { $txtLog.AppendText("ERROR: $err`r`n") }

        $timer.Stop()
        $progressBar.MarqueeAnimationSpeed = 0
        $progressBar.Value = 100
        $progressBar.Style = "Blocks"
    
        $lblStatus.Text = "Done! $e_party Bon Appétit!"
        $txtLog.AppendText("Done.`r`n")
        $btnRun.Enabled = $true
    })

# --- Show Form ---
$form.ShowDialog() | Out-Null
