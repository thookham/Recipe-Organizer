Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "🍳 Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 350) # Initial size (Log hidden)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# --- Fonts ---
$fontTitle = New-Object System.Drawing.Font("Segoe UI Emoji", 12, [System.Drawing.FontStyle]::Bold)
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 9)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9)

# --- Header ---
$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Organize Your Kitchen! 🥗"
$lblHeader.Location = New-Object System.Drawing.Point(20, 10)
$lblHeader.Size = New-Object System.Drawing.Size(560, 30)
$lblHeader.Font = $fontTitle
$lblHeader.TextAlign = "MiddleCenter"
$form.Controls.Add($lblHeader)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "📂 Source Folder:"
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
$lblDest.Text = "🎯 Destination Folder:"
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
$lblMode.Text = "⚙️ Mode:"
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
$chkNoRecurse.Text = "🚫 Top folder only (No Recursion)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(220, 178)
$chkNoRecurse.AutoSize = $true
$chkNoRecurse.Font = $fontRegular
$form.Controls.Add($chkNoRecurse)

# --- Progress Bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 220)
$progressBar.Size = New-Object System.Drawing.Size(540, 20)
$progressBar.Style = "Marquee" # Indeterminate animation
$progressBar.MarqueeAnimationSpeed = 0 # Stopped initially
$form.Controls.Add($progressBar)

# --- Status Label ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready to organize! 👨‍🍳"
$lblStatus.Location = New-Object System.Drawing.Point(20, 245)
$lblStatus.Size = New-Object System.Drawing.Size(300, 20)
$lblStatus.Font = $fontRegular
$form.Controls.Add($lblStatus)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "🚀 Start Organizing"
$btnRun.Location = New-Object System.Drawing.Point(360, 250)
$btnRun.Size = New-Object System.Drawing.Size(200, 40)
$btnRun.Font = $fontBold
$btnRun.BackColor = "LightGreen"
$btnRun.FlatStyle = "Flat"
$form.Controls.Add($btnRun)

# --- Toggle Log Button ---
$btnLog = New-Object System.Windows.Forms.Button
$btnLog.Text = "Show Log 📝"
$btnLog.Location = New-Object System.Drawing.Point(20, 270)
$btnLog.Size = New-Object System.Drawing.Size(100, 25)
$btnLog.Font = $fontRegular
$btnLog.FlatStyle = "Popup"
$form.Controls.Add($btnLog)

# --- Output Log (Hidden by default) ---
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
        $lblStatus.Text = "Working$dots 🥘"
    })

# --- Event Handlers ---

$isLogVisible = $false
$btnLog.Add_Click({
        if ($isLogVisible) {
            $form.Height = 350
            $btnLog.Text = "Show Log 📝"
            $isLogVisible = $false
        }
        else {
            $form.Height = 550
            $btnLog.Text = "Hide Log 🙈"
            $isLogVisible = $true
        }
    })

$btnRun.Add_Click({
        $btnRun.Enabled = $false
        $txtLog.Clear()
        $txtLog.AppendText("Starting...`r`n")
    
        # Start Animation
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

        # Construct Command with Verbose redirection
        $cmd = "& '$scriptPath' -SourcePath '$($txtSource.Text)' -DestinationPath '$($txtDest.Text)' -Mode '$($cmbMode.SelectedItem)' -Verbose *>&1"
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

        # Stop Animation
        $timer.Stop()
        $progressBar.MarqueeAnimationSpeed = 0
        $progressBar.Value = 100 # Fill it up to show done
        $progressBar.Style = "Blocks"
    
        $lblStatus.Text = "Done! 🎉 Bon Appétit!"
        $txtLog.AppendText("Done.`r`n")
        $btnRun.Enabled = $true
    
        # Reset progress bar style for next run after a delay? 
        # For now, just leave it full.
    })

# --- Show Form ---
$form.ShowDialog() | Out-Null
