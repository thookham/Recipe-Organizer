$Version = "1.2.1"
$OutputDir = Join-Path $PSScriptRoot "Releases"
$SrcDir = Join-Path $PSScriptRoot "src"
$ReleaseDir = Join-Path $PSScriptRoot "Release"

# Ensure Output Directory Exists
if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

Write-Host "Packaging Recipe Organizer v$Version..." -ForegroundColor Cyan

# 1. Build C# Version
Write-Host "Building C# Version..." -ForegroundColor Yellow
$CscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$CSharpExe = Join-Path $SrcDir "RecipeOrganizer.exe"
& $CscPath /target:winexe /out:$CSharpExe /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll "$SrcDir\Program.cs" "$SrcDir\MainForm.cs" "$SrcDir\Organizer.cs"

if ($LASTEXITCODE -eq 0) {
    $ZipPath = Join-Path $OutputDir "RecipeOrganizer_CSharp_v$Version.zip"
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    Compress-Archive -Path $CSharpExe -DestinationPath $ZipPath
    Write-Host "Created: $ZipPath" -ForegroundColor Green
}
else {
    Write-Error "C# Build Failed!"
}

# 2. Build PowerShell Version
Write-Host "Building PowerShell Version..." -ForegroundColor Yellow
& "$PSScriptRoot\Build-Standalone.ps1"

$PSExe = Join-Path $ReleaseDir "RecipeOrganizer.exe"
if (Test-Path $PSExe) {
    $ZipPath = Join-Path $OutputDir "RecipeOrganizer_PowerShell_v$Version.zip"
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    Compress-Archive -Path $PSExe -DestinationPath $ZipPath
    Write-Host "Created: $ZipPath" -ForegroundColor Green
}
else {
    Write-Error "PowerShell Build Failed!"
}

Write-Host "Packaging Complete!" -ForegroundColor Cyan
Invoke-Item $OutputDir
