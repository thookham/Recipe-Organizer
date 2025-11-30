# Build-Release.ps1
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ReleaseDir = Join-Path $ProjectRoot "Release"
$ZipPath = Join-Path $ProjectRoot "RecipeOrganizer_v1.0.0.zip"

# 1. Clean up
if (Test-Path $ReleaseDir) { Remove-Item $ReleaseDir -Recurse -Force }
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null

# 2. Build Standalone EXE
Write-Host "Building Standalone EXE..." -ForegroundColor Cyan
# We'll invoke the logic from Build-Standalone.ps1 here directly or call it.
# For simplicity, let's call the existing Build-Standalone.ps1 but redirect output to Release dir
& "$PSScriptRoot\Build-Standalone.ps1"

# Rename the standalone exe to the main name
# Rename the standalone exe to the main name (if needed, but Build-Standalone now outputs RecipeOrganizer.exe directly)
$MainExe = Join-Path $ReleaseDir "RecipeOrganizer.exe"

if (-not (Test-Path $MainExe)) {
    # Fallback check for old name just in case
    $StandaloneExe = Join-Path $ReleaseDir "RecipeOrganizer_Standalone.exe"
    if (Test-Path $StandaloneExe) {
        Move-Item $StandaloneExe $MainExe -Force
    }
    else {
        Write-Error "Standalone EXE build failed. Could not find $MainExe"
    }
}

# 3. Copy Only Essential Files
Write-Host "Copying essential files..." -ForegroundColor Cyan
Copy-Item (Join-Path $ProjectRoot "Organize-Recipes.ps1") $ReleaseDir
Copy-Item (Join-Path $ProjectRoot "README.md") $ReleaseDir
Copy-Item (Join-Path $ProjectRoot "CHANGELOG.md") $ReleaseDir

# Remove intermediate artifacts if any (like the source .cs from standalone build)
Remove-Item (Join-Path $ReleaseDir "StandaloneLauncher.cs") -ErrorAction SilentlyContinue

# 4. Create Zip
Write-Host "Creating Zip archive..." -ForegroundColor Cyan
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($ReleaseDir, $ZipPath)

Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "Release Zip: $ZipPath"
Write-Host "Contents: RecipeOrganizer.exe (Standalone), Organize-Recipes.ps1, Docs"
