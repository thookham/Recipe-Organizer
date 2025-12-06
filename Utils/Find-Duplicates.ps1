function Find-ExactDuplicates {
    <#
    .SYNOPSIS
        Finds exact duplicate files in a directory based on SHA256 hash.
    .DESCRIPTION
        Recursevely scans a directory, calculates file hashes, and returns groups of files that have identical content.
    .PARAMETER Path
        The directory to scan.
    .EXAMPLE
        Find-ExactDuplicates -Path "C:\Recipes"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }

    Write-Host "Scanning for duplicates in: $Path" -ForegroundColor Cyan

    $hashes = @{}
    $files = Get-ChildItem -Path $Path -Recurse -File
    $count = 0
    $total = $files.Count

    foreach ($file in $files) {
        $count++
        if ($count % 10 -eq 0) {
            Write-Progress -Activity "Hashing Files" -Status "$count / $total" -PercentComplete (($count / $total) * 100)
        }
        
        $hash = Get-FileHash $file.FullName -Algorithm SHA256
        if ($hashes.ContainsKey($hash.Hash)) {
            $hashes[$hash.Hash] += @($file.FullName)
        } else {
            $hashes[$hash.Hash] = @($file.FullName)
        }
    }
    Write-Progress -Activity "Hashing Files" -Completed

    $duplicates = $hashes.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    
    if ($duplicates) {
        Write-Host "Found $($duplicates.Count) sets of duplicates." -ForegroundColor Yellow
        $duplicates | ForEach-Object {
            Write-Host "Hash: $($_.Key)" -ForegroundColor Gray
            $_.Value | ForEach-Object { Write-Host "  - $_" }
            Write-Host ""
        }
    } else {
        Write-Host "No duplicates found." -ForegroundColor Green
    }

    return $duplicates
}

# Export the function if utilized as a module, or run if invoked directly
if ($MyInvocation.InvocationName -ne '.') {
    # Script is being run directly
    # Allow passing arguments or just define the function
    if ($args) {
        Find-ExactDuplicates @args
    }
}
