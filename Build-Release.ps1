# Build-Release.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ReleaseDir = Join-Path $ProjectRoot "Release"
$ZipPath = Join-Path $ProjectRoot "RecipeOrganizer_v1.0.0.zip"

# 1. Clean up
if (Test-Path $ReleaseDir) { Remove-Item $ReleaseDir -Recurse -Force }
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null

# 2. Compile Launcher
Write-Host "Compiling Launcher..." -ForegroundColor Cyan
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    $csc = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

if (Test-Path $csc) {
    $LauncherSrc = Join-Path $ProjectRoot "Launcher.cs"
    $LauncherExe = Join-Path $ReleaseDir "RecipeOrganizer.exe"
    # Compile as WinExe (/target:winexe) to avoid console window
    & $csc /target:winexe /out:"$LauncherExe" "$LauncherSrc"
}
else {
    Write-Warning "C# Compiler (csc.exe) not found. Skipping EXE generation."
}

# 3. Copy Artifacts
Write-Host "Copying files..." -ForegroundColor Cyan
Copy-Item (Join-Path $ProjectRoot "Organize-Recipes.ps1") $ReleaseDir
Copy-Item (Join-Path $ProjectRoot "RecipeOrganizerGUI.ps1") $ReleaseDir
Copy-Item (Join-Path $ProjectRoot "README.md") $ReleaseDir
Copy-Item (Join-Path $ProjectRoot "CHANGELOG.md") $ReleaseDir

# 4. Create Zip
Write-Host "Creating Zip archive..." -ForegroundColor Cyan
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($ReleaseDir, $ZipPath)

Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "Release Zip: $ZipPath"
