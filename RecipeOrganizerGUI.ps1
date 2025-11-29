Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Recipe Organizer"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# --- Fonts ---
$fontRegular = New-Object System.Drawing.Font("Segoe UI", 9)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

# --- Source Path ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 20)
$lblSource.AutoSize = $true
$lblSource.Font = $fontBold
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 45)
$txtSource.Size = New-Object System.Drawing.Size(450, 25)
$txtSource.Text = [Environment]::GetFolderPath("MyDocuments")
$txtSource.Font = $fontRegular
$form.Controls.Add($txtSource)

$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = "Browse"
$btnSource.Location = New-Object System.Drawing.Point(480, 44)
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
$lblDest.Text = "Destination Folder:"
$lblDest.Location = New-Object System.Drawing.Point(20, 80)
$lblDest.AutoSize = $true
$lblDest.Font = $fontBold
$form.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 105)
$txtDest.Size = New-Object System.Drawing.Size(450, 25)
$txtDest.Text = "C:\Recipes"
$txtDest.Font = $fontRegular
$form.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = "Browse"
$btnDest.Location = New-Object System.Drawing.Point(480, 104)
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
$lblMode.Text = "Mode:"
$lblMode.Location = New-Object System.Drawing.Point(20, 150)
$lblMode.AutoSize = $true
$lblMode.Font = $fontBold
$form.Controls.Add($lblMode)

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(70, 147)
$cmbMode.Size = New-Object System.Drawing.Size(100, 25)
$cmbMode.Items.AddRange(@("Test", "Copy", "Move"))
$cmbMode.SelectedIndex = 0
$cmbMode.DropDownStyle = "DropDownList"
$cmbMode.Font = $fontRegular
$form.Controls.Add($cmbMode)

$chkNoRecurse = New-Object System.Windows.Forms.CheckBox
$chkNoRecurse.Text = "No Recursion (Top folder only)"
$chkNoRecurse.Location = New-Object System.Drawing.Point(200, 148)
$chkNoRecurse.AutoSize = $true
$chkNoRecurse.Font = $fontRegular
$form.Controls.Add($chkNoRecurse)

# --- Output Log ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 190)
$txtLog.Size = New-Object System.Drawing.Size(540, 200)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtLog.BackColor = "White"
$form.Controls.Add($txtLog)

# --- Run Button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Start Organizer"
$btnRun.Location = New-Object System.Drawing.Point(20, 410)
$btnRun.Size = New-Object System.Drawing.Size(540, 40)
$btnRun.Font = $fontBold
$btnRun.BackColor = "LightGreen"
$btnRun.Add_Click({
        $btnRun.Enabled = $false
        $txtLog.Clear()
        $txtLog.AppendText("Starting...`r`n")
        $form.Refresh()

        $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Organize-Recipes.ps1"
    
        if (-not (Test-Path $scriptPath)) {
            [System.Windows.Forms.MessageBox]::Show("Could not find Organize-Recipes.ps1", "Error", "OK", "Error")
            $btnRun.Enabled = $true
            return
        }

        $cmd = "& '$scriptPath' -SourcePath '$($txtSource.Text)' -DestinationPath '$($txtDest.Text)' -Mode '$($cmbMode.SelectedItem)'"
        if ($chkNoRecurse.Checked) {
            $cmd += " -NoRecurse"
        }

        # Run script and capture output
        # Using a runspace or job would be better for non-blocking UI, but simple Invoke-Expression is easier for a basic script.
        # To keep UI responsive-ish, we'll use a simple process start or just accept the freeze for this version.
        # Let's try to capture output in real-time-ish by running in a separate process and reading stdout.
    
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
                $form.Refresh() # Force UI update
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
    
        $rest = $p.StandardOutput.ReadToEnd()
        if ($rest) { $txtLog.AppendText($rest + "`r`n") }
    
        $err = $p.StandardError.ReadToEnd()
        if ($err) { $txtLog.AppendText("ERROR: $err`r`n") }

        $txtLog.AppendText("Done.`r`n")
        $btnRun.Enabled = $true
    })
$form.Controls.Add($btnRun)

# --- Show Form ---
$form.ShowDialog() | Out-Null
