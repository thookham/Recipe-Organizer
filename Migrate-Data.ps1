param(
    [string]$RootPath = "$PSScriptRoot\OrganizedRecipes",
    [string]$OutputPath = "$PSScriptRoot\recipes.json"
)

Write-Host "Scanning $RootPath for recipes..."

$recipes = @()

if (Test-Path $RootPath) {
    $files = Get-ChildItem -Path $RootPath -Recurse -File

    foreach ($file in $files) {
        # Assuming structure: Category\Letter\Filename
        # Relative path: Desserts\A\ApplePie.pdf
        $relativePath = $file.FullName.Substring($RootPath.Length + 1)
        $parts = $relativePath.Split([System.IO.Path]::DirectorySeparatorChar)
        
        $category = "Uncategorized"
        if ($parts.Count -ge 2) {
            $category = $parts[0]
        }

        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256

        $recipe = [PSCustomObject]@{
            id          = $hash.Hash
            filename    = $file.Name
            path        = $file.FullName
            category    = $category
            tags        = @() # Placeholder
            date_added  = $file.CreationTime.ToString("yyyy-MM-dd")
            source_type = $file.Extension.TrimStart('.').ToUpper()
            has_ocr     = $false
        }

        $recipes += $recipe
    }
}

$json = $recipes | ConvertTo-Json -Depth 5
$json | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Migration complete. Index saved to $OutputPath"
Write-Host "Total recipes indexed: $($recipes.Count)"
