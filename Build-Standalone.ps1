# Build-Standalone.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
# Build-Standalone.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ReleaseDir = Join-Path $ProjectRoot "Release"
# Build-Standalone.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
# Build-Standalone.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ReleaseDir = Join-Path $ProjectRoot "Release"
if (-not (Test-Path $ReleaseDir)) { New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null }

$ScriptPath = Join-Path $ProjectRoot "Organize-Recipes.ps1"
$GuiPath = Join-Path $ProjectRoot "RecipeOrganizerGUI.ps1"

# Path to System.Management.Automation.dll
# We need to copy this to the release dir to embed it easily
$RefAssemblySource = "C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll"
$RefAssemblyDest = Join-Path $ReleaseDir "System.Management.Automation.dll"

if (Test-Path $RefAssemblySource) {
    Copy-Item -Path $RefAssemblySource -Destination $RefAssemblyDest -Force
}
else {
    Write-Error "Could not find System.Management.Automation.dll at $RefAssemblySource"
}

# Prepare Resources
# 1. Backend Script (Already contains Invoke-OrganizeRecipes)
$ScriptContent = Get-Content $ScriptPath -Raw
$ScriptResFile = Join-Path $ReleaseDir "script.b64"
[System.IO.File]::WriteAllText($ScriptResFile, [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ScriptContent)))

# 2. GUI Script (No changes needed, just encode)
$GuiResFile = Join-Path $ReleaseDir "gui.b64"
$GuiBytes = [System.IO.File]::ReadAllBytes($GuiPath)
[System.IO.File]::WriteAllText($GuiResFile, [Convert]::ToBase64String($GuiBytes))

# C# Source Code (Hosted PowerShell with Embedded DLL)
$CSharpCode = @"
using System;
using System.Reflection;
using System.IO;
using System.Windows.Forms;

class Program {
    [STAThread]
    static void Main(string[] args) {
        try {
            File.WriteAllText("launcher_debug.txt", "Main Started\nArgs: " + string.Join(" ", args) + "\n");
            
            // 1. Setup Assembly Resolver for Embedded DLLs (System.Management.Automation)
            AppDomain.CurrentDomain.AssemblyResolve += (sender, resolveArgs) => {
                File.AppendAllText("launcher_debug.txt", "Resolving: " + resolveArgs.Name + "\n");
                string resourceName = new AssemblyName(resolveArgs.Name).Name + ".dll";
                using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName)) {
                    if (stream == null) {
                        File.AppendAllText("launcher_debug.txt", "Resource NOT found: " + resourceName + "\n");
                        return null;
                    }
                    File.AppendAllText("launcher_debug.txt", "Resource found: " + resourceName + "\n");
                    byte[] assemblyData = new byte[stream.Length];
                    stream.Read(assemblyData, 0, assemblyData.Length);
                    return Assembly.Load(assemblyData);
                }
            };

            // 2. Run Application Logic
            RunApp(args);
        } catch (Exception ex) {
            File.AppendAllText("launcher_debug.txt", "Main Exception: " + ex.ToString() + "\n");
            MessageBox.Show("Critical Error: " + ex.Message);
        }
    }

    static void RunApp(string[] args) {
        try {
            File.AppendAllText("launcher_debug.txt", "RunApp Started\n");
            PowerShellRunner.Run(args);
            File.AppendAllText("launcher_debug.txt", "RunApp Finished\n");
        }
        catch (Exception ex) {
            File.AppendAllText("launcher_debug.txt", "RunApp Exception: " + ex.ToString() + "\n");
            MessageBox.Show("Critical Error: " + ex.Message, "Recipe Organizer", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}

// Helper class to force JIT compilation only when called
public static class PowerShellRunner {
    public static void Run(string[] args) {
        // Now we can use System.Management.Automation types
        // The AssemblyResolve event will fire when this method is JIT-compiled/executed
        
        using (var runspace = System.Management.Automation.Runspaces.RunspaceFactory.CreateRunspace()) {
            runspace.Open();
            
            // Load Embedded Script (The Function Wrapper)
            string scriptContent = DecodeResource("Script");
            using (var ps = System.Management.Automation.PowerShell.Create()) {
                ps.Runspace = runspace;
                ps.AddScript(scriptContent);
                ps.Invoke(); // Defines the function 'Invoke-OrganizeRecipes'
            }

            // Load and Run GUI
            string guiContent = DecodeResource("Gui");
            using (var ps = System.Management.Automation.PowerShell.Create()) {
                ps.Runspace = runspace;
                ps.AddScript(guiContent);
                
                // Parse and pass arguments
                // Simple parser: -Name Value switch
                for (int i = 0; i < args.Length; i++) {
                    string arg = args[i];
                    if (arg.StartsWith("-")) {
                        string paramName = arg.Substring(1);
                        if (i + 1 < args.Length && !args[i+1].StartsWith("-")) {
                            ps.AddParameter(paramName, args[i+1]);
                            i++;
                        } else {
                            ps.AddParameter(paramName, true); // Switch
                        }
                    }
                }

                ps.Invoke();

                if (ps.HadErrors) {
                    File.AppendAllText("launcher_debug.txt", "PowerShell Errors:\n");
                    foreach (var err in ps.Streams.Error) {
                        File.AppendAllText("launcher_debug.txt", err.ToString() + "\n");
                    }
                }
            }
            
            runspace.Close();
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

    static string DecodeResource(string name) {
        string base64 = ReadResource(name);
        byte[] bytes = Convert.FromBase64String(base64);
        return System.Text.Encoding.UTF8.GetString(bytes);
    }
}
"@

$SourceFile = Join-Path $ReleaseDir "StandaloneLauncher.cs"
$ExeFile = Join-Path $ReleaseDir "RecipeOrganizer.exe" # Renamed to cleaner name
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
    Write-Host "Compiling Standalone EXE (Embedded Dependencies)..." -ForegroundColor Cyan
    # Use Start-Process to ensure arguments are passed correctly without PowerShell parsing interference
    $ArgList = @(
        "/target:winexe",
        "/win32manifest:`"$ManifestFile`"",
        "/reference:System.Windows.Forms.dll",
        "/reference:`"$RefAssemblyDest`"",
        "/resource:`"$ScriptResFile`",Script",
        "/resource:`"$GuiResFile`",Gui",
        "/resource:`"$RefAssemblyDest`",System.Management.Automation.dll",
        "/out:`"$ExeFile`"",
        "`"$SourceFile`""
    )
    
    $p = Start-Process -FilePath $csc -ArgumentList $ArgList -PassThru -NoNewWindow -Wait
    
    if ($p.ExitCode -eq 0) {
        Write-Host "Created: $ExeFile" -ForegroundColor Green
        # Cleanup DLL from release folder so it's not zipped (it's inside the EXE now)
        Remove-Item $RefAssemblyDest -Force
    }
    else {
        Write-Error "Compilation Failed! Exit Code: $($p.ExitCode)"
    }
}
else {
    Write-Error "CSC.exe not found."
}
