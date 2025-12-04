<#
.SYNOPSIS
    Updates the recipes.json database by scanning the OrganizedRecipes directory.
.DESCRIPTION
    This script scans the OrganizedRecipes directory for all files, generates a list of recipe objects
    including metadata like hash, category, and tags, and saves it to recipes.json.
    It effectively rebuilds the index to ensure it matches the file system state.
.PARAMETER RootPath
    The root directory containing organized recipes. Defaults to "$PSScriptRoot\OrganizedRecipes".
.PARAMETER OutputPath
    The path to the output JSON file. Defaults to "$PSScriptRoot\recipes.json".
.EXAMPLE
    .\Update-RecipeDatabase.ps1
#>
param(
    [string]$RootPath = "$PSScriptRoot\OrganizedRecipes",
    [string]$OutputPath = "$PSScriptRoot\recipes.json"
)

Write-Host "Updating Recipe Database..." -ForegroundColor Cyan

if (-not (Test-Path $RootPath)) {
    Write-Warning "Root path '$RootPath' does not exist. Database will be empty."
    $recipes = @()
}
else {
    Write-Host "Scanning $RootPath..."
    $files = Get-ChildItem -Path $RootPath -Recurse -File
    
    $recipes = foreach ($file in $files) {
        # Relative path: Desserts\A\ApplePie.pdf
        $relativePath = $file.FullName.Substring($RootPath.Length + 1)
        $parts = $relativePath.Split([System.IO.Path]::DirectorySeparatorChar)
        
        $category = "Uncategorized"
        if ($parts.Count -ge 2) {
            $category = $parts[0]
        }

        # Calculate hash for ID and integrity
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256

        [PSCustomObject]@{
            id          = $hash.Hash
            filename    = $file.Name
            path        = $file.FullName
            category    = $category
            tags        = @() # Placeholder for future tagging logic
            date_added  = $file.CreationTime.ToString("yyyy-MM-dd")
            source_type = $file.Extension.TrimStart('.').ToUpper()
            has_ocr     = $false
        }
    }
}

$json = $recipes | ConvertTo-Json -Depth 5
$json | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Database updated successfully." -ForegroundColor Green
Write-Host "Total recipes indexed: $($recipes.Count)" -ForegroundColor Gray
Write-Host "Database saved to: $OutputPath" -ForegroundColor Gray
