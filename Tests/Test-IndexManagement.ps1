$ErrorActionPreference = "Stop"

$root = "$PSScriptRoot\.."
$organizer = "$root\Organize-Recipes.ps1"
$dbScript = "$root\Update-RecipeDatabase.ps1"
$recipesJson = "$root\recipes.json"
$testSource = "$root\Tests\TempSource"
$testDest = "$root\Tests\TempDest"

# Cleanup previous run
if (Test-Path $testSource) { Remove-Item $testSource -Recurse -Force }
if (Test-Path $testDest) { Remove-Item $testDest -Recurse -Force }
if (Test-Path $recipesJson) { Remove-Item $recipesJson -Force }

# Setup
New-Item -Path $testSource -ItemType Directory | Out-Null
New-Item -Path $testDest -ItemType Directory | Out-Null

# Create dummy recipe
$dummyRecipe = "$testSource\TestRecipe.txt"
"Ingredients: Water" | Set-Content $dummyRecipe

Write-Host "Debug: Checking source folder $testSource"
Get-ChildItem $testSource | Select-Object Name, FullName | Format-Table

Write-Host "Running Organize-Recipes.ps1 with -Mode Copy..."
& $organizer -SourcePath $testSource -DestinationPath $testDest -Mode "Copy" -NoRecurse -Verbose

# Verify
if (Test-Path $recipesJson) {
    $json = Get-Content $recipesJson | ConvertFrom-Json
    $found = $json | Where-Object { $_.filename -eq "TestRecipe.txt" }
    
    if ($found) {
        Write-Host "SUCCESS: TestRecipe.txt found in recipes.json" -ForegroundColor Green
    }
    else {
        Write-Error "FAILURE: TestRecipe.txt NOT found in recipes.json"
    }
}
else {
    Write-Error "FAILURE: recipes.json was not created"
}

# Cleanup
Remove-Item $testSource -Recurse -Force
Remove-Item $testDest -Recurse -Force
# Remove-Item $recipesJson -Force # Keep for inspection
