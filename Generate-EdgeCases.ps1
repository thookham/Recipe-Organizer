# Generate-EdgeCases.ps1
$TestDir = Join-Path $PSScriptRoot "EdgeCases"
New-Item -Path $TestDir -ItemType Directory -Force | Out-Null

# 1. Number Start (Should go to '#')
Set-Content -Path "$TestDir/123Recipe.txt" -Value "Ingredients: 1. Dough"

# 2. Symbol Start (Should go to '#')
Set-Content -Path "$TestDir/!SuperRecipe.txt" -Value "Directions: Mix well."

# 3. Mock .docx (Valid Zip with XML)
$DocxPath = "$TestDir/MockDocx.docx"
$TempDir = "$TestDir/TempDocx"
$WordDir = "$TempDir/word"
New-Item -Path $WordDir -ItemType Directory -Force | Out-Null
# Create valid XML with keyword
Set-Content -Path "$WordDir/document.xml" -Value "<?xml version='1.0'?><w:document><w:body><w:p><w:t>This contains Ingredients for testing.</w:t></w:p></w:body></w:document>"
# Zip it up
Compress-Archive -Path "$TempDir/*" -DestinationPath $DocxPath -Force
Remove-Item -Path $TempDir -Recurse -Force

# 4. Fake PDF (Text content, script should read it if using Get-Content fallback)
Set-Content -Path "$TestDir/Fake.pdf" -Value "This is a PDF with Directions inside."

# 5. False Positive Check
Set-Content -Path "$TestDir/Receipt.txt" -Value "This is a Receipt for groceries."

# 6. Case Insensitivity
Set-Content -Path "$TestDir/lower_ingredients.txt" -Value "ingredients: sugar, spice."

# 7. Nested Folder
$NestedDir = "$TestDir/Deep/Nested"
New-Item -Path $NestedDir -ItemType Directory -Force | Out-Null
Set-Content -Path "$NestedDir/DeepRecipe.txt" -Value "Recipe for disaster."

# 8. Zero Byte File
New-Item -Path "$TestDir/ZeroByte.txt" -ItemType File -Force | Out-Null

# 9. No Extension (Should be ignored by default filter, but good to check)
Set-Content -Path "$TestDir/NoExtension" -Value "Ingredients: Mystery."

# 10. Long Path (> 260 chars)
$LongPath = $TestDir
for ($i = 0; $i -lt 10; $i++) {
    $LongPath = Join-Path $LongPath "ThisIsAVeryLongDirectoryNameToTestPathLimits"
}
# We might hit OS limits creating this, so we try/catch
try {
    New-Item -Path $LongPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    Set-Content -Path "$LongPath/LongPathRecipe.txt" -Value "Ingredients: Patience."
}
catch {
    Write-Warning "Could not create long path: $_"
}

Write-Host "Edge cases generated in $TestDir"
