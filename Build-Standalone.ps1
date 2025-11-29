# Build-Standalone.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ReleaseDir = Join-Path $ProjectRoot "Release"
if (-not (Test-Path $ReleaseDir)) { New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null }

$ScriptPath = Join-Path $ProjectRoot "Organize-Recipes.ps1"
$GuiPath = Join-Path $ProjectRoot "RecipeOrganizerGUI.ps1"

# Prepare Resources (Base64 Encoded to ensure integrity)
function Create-ResourceFile {
    param($SourcePath, $DestPath)
    $bytes = [System.IO.File]::ReadAllBytes($SourcePath)
    $base64 = [Convert]::ToBase64String($bytes)
    [System.IO.File]::WriteAllText($DestPath, $base64)
}

$ScriptResFile = Join-Path $ReleaseDir "script.b64"
$GuiResFile = Join-Path $ReleaseDir "gui.b64"

Create-ResourceFile $ScriptPath $ScriptResFile
Create-ResourceFile $GuiPath $GuiResFile

# C# Source Code
$CSharpCode = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms; // Requires /reference:System.Windows.Forms.dll

class Program {
    [STAThread]
    static void Main() {
        try {
            // Create a unique temp directory
            string tempDir = Path.Combine(Path.GetTempPath(), "RecipeOrganizer_" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(tempDir);

            // Extract Resources
            string scriptContent = ReadResource("Script");
            string guiContent = ReadResource("Gui");

            string scriptPath = Path.Combine(tempDir, "Organize-Recipes.ps1");
            string guiPath = Path.Combine(tempDir, "RecipeOrganizerGUI.ps1");

            // Decode and Write scripts to temp
            File.WriteAllBytes(scriptPath, Convert.FromBase64String(scriptContent));
            File.WriteAllBytes(guiPath, Convert.FromBase64String(guiContent));

            // Launch GUI
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = "powershell.exe";
            // -WindowStyle Hidden to hide the console window of the PowerShell process itself
            psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + guiPath + "\"";
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;

            Process p = Process.Start(psi);
            if (p == null) {
                throw new Exception("Failed to start PowerShell process.");
            }
            p.WaitForExit();

            // Cleanup
            try {
                if (Directory.Exists(tempDir)) {
                    Directory.Delete(tempDir, true);
                }
            } catch { }
        }
        catch (Exception ex) {
            MessageBox.Show("An error occurred launching the application:\n" + ex.Message, "Recipe Organizer Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    static string ReadResource(string name) {
        var assembly = Assembly.GetExecutingAssembly();
        using (var stream = assembly.GetManifestResourceStream(name)) {
            if (stream == null) throw new Exception("Resource not found: " + name);
            using (var reader = new StreamReader(stream)) {
                return reader.ReadToEnd();
            }
        }
    }
}
"@

$SourceFile = Join-Path $ReleaseDir "StandaloneLauncher.cs"
$ExeFile = Join-Path $ReleaseDir "RecipeOrganizer_Standalone.exe"
$ManifestFile = Join-Path $ReleaseDir "app.manifest"

Set-Content -Path $SourceFile -Value $CSharpCode

# Create Manifest for asInvoker (No Admin Required)
$ManifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <assemblyIdentity version="1.0.0.0" name="RecipeOrganizer" />
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPrivileges xmlns="urn:schemas-microsoft-com:asm.v3">
        <requestedExecutionLevel level="asInvoker" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>
"@
Set-Content -Path $ManifestFile -Value $ManifestContent

# Compile
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    $csc = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

if (Test-Path $csc) {
    Write-Host "Compiling Standalone EXE..." -ForegroundColor Cyan
    # Use Start-Process to ensure arguments are passed correctly without PowerShell parsing interference
    $ArgList = @(
        "/target:winexe",
        "/win32manifest:`"$ManifestFile`"",
        "/reference:System.Windows.Forms.dll",
        "/resource:`"$ScriptResFile`",Script",
        "/resource:`"$GuiResFile`",Gui",
        "/out:`"$ExeFile`"",
        "`"$SourceFile`""
    )
    
    $p = Start-Process -FilePath $csc -ArgumentList $ArgList -PassThru -NoNewWindow -Wait
    
    if ($p.ExitCode -eq 0) {
        Write-Host "Created: $ExeFile" -ForegroundColor Green
    }
    else {
        Write-Error "Compilation Failed! Exit Code: $($p.ExitCode)"
    }
}
else {
    Write-Error "CSC.exe not found."
}
