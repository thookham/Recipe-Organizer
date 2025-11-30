# Run-Simulation.ps1
$ErrorActionPreference = "Stop"

$ExePath = Join-Path $PSScriptRoot "Release\RecipeOrganizer.exe"
if (-not (Test-Path $ExePath)) {
    Write-Error "RecipeOrganizer.exe not found in Release folder. Build it first."
}

# 1. Generate Edge Cases
$SimulationLog = "$PSScriptRoot\simulation_log.txt"
if (Test-Path $SimulationLog) { Remove-Item $SimulationLog -Force }
New-Item -Path $SimulationLog -ItemType File -Force | Out-Null

Write-Host "Generating Edge Cases..." -ForegroundColor Cyan
& "$PSScriptRoot\Generate-EdgeCases.ps1"

$SourceDir = Join-Path $PSScriptRoot "EdgeCases"
$DestDir = Join-Path $PSScriptRoot "SimulationOutput"

# Clean Destination
if (Test-Path $DestDir) { Remove-Item $DestDir -Recurse -Force }
New-Item -Path $DestDir -ItemType Directory -Force | Out-Null

# 2. Run Simulation (AutoRun Mode)
Write-Host "Running Simulation (AutoRun)..." -ForegroundColor Cyan
Write-Host "Source: $SourceDir"
Write-Host "Dest: $DestDir"

# Call EXE with arguments
# Note: Arguments are passed to Main(string[] args) -> PowerShellRunner.Run(args) -> GUI Script Params
$ArgList = @(
    "-SourcePath", "`"$SourceDir`"",
    "-DestinationPath", "`"$DestDir`"",
    "-Mode", "Copy",
    "-AutoRun"
)
$Process = Start-Process -FilePath $ExePath -ArgumentList $ArgList -PassThru -Wait

if ($Process.ExitCode -ne 0) {
    Write-Warning "EXE exited with code $($Process.ExitCode)"
}

# 3. Verify Results
Write-Host "Verifying Results..." -ForegroundColor Cyan
$Files = Get-ChildItem -Path $DestDir -Recurse -File
if ($Files.Count -gt 0) {
    Write-Host "Success! Found $($Files.Count) organized files." -ForegroundColor Green
    $Files | Select-Object Name, DirectoryName | Format-Table -AutoSize
}
else {
    Write-Error "Simulation Failed! No files found in destination."
}
