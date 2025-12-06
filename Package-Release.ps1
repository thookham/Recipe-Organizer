$Version = "2.0.0"
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

$DotnetExe = Get-Command dotnet -ErrorAction SilentlyContinue
if ($DotnetExe) {
    # Use .NET 6 SDK if available
    Push-Location $SrcDir
    dotnet build -c Release -o "$SrcDir\bin\Release\net6.0-windows"
    Pop-Location
    
    $CSharpExe = Join-Path $SrcDir "bin\Release\net6.0-windows\RecipeOrganizer.exe"
    if (Test-Path $CSharpExe) {
        # Include all runtime dependencies
        $ZipPath = Join-Path $OutputDir "RecipeOrganizer_CSharp_v$Version.zip"
        if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
        Compress-Archive -Path "$SrcDir\bin\Release\net6.0-windows\*" -DestinationPath $ZipPath
        Write-Host "Created: $ZipPath" -ForegroundColor Green
    }
    else {
        Write-Error "C# Build Failed - exe not found!"
    }
}
else {
    # Fallback to .NET Framework csc.exe (limited - won't work with .NET 6 code)
    $CscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    if (Test-Path $CscPath) {
        Write-Warning ".NET SDK not found. Attempting legacy build (may fail with .NET 6 features)..."
        $CSharpExe = Join-Path $SrcDir "RecipeOrganizer.exe"
        & $CscPath /target:winexe /out:$CSharpExe /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll "$SrcDir\Program.cs" "$SrcDir\MainForm.cs" "$SrcDir\Organizer.cs" "$SrcDir\RecipeDatabase.cs"
        
        if ($LASTEXITCODE -eq 0) {
            $ZipPath = Join-Path $OutputDir "RecipeOrganizer_CSharp_v$Version.zip"
            if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
            Compress-Archive -Path $CSharpExe -DestinationPath $ZipPath
            Write-Host "Created: $ZipPath" -ForegroundColor Green
        }
        else {
            Write-Error "C# Build Failed! Install .NET 6 SDK for full compatibility."
        }
    }
    else {
        Write-Error "No build tools available. Install .NET 6 SDK from https://dotnet.microsoft.com/download/dotnet/6.0"
    }
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
    Write-Warning "PowerShell standalone build skipped or failed."
}

Write-Host "Packaging Complete!" -ForegroundColor Cyan
Write-Host "Release packages are in: $OutputDir" -ForegroundColor Gray
