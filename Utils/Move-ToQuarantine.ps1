function Move-ToQuarantine {
    <#
    .SYNOPSIS
        Safely moves a file to a quarantine folder, handling name collisions.
    
    .DESCRIPTION
        This function moves a specified file to a quarantine directory (defaulting to '_Duplicates').
        If a file with the same name already exists in the quarantine directory, it renames the 
        incoming file by appending a counter (e.g., file_1.ext, file_2.ext) to prevent overwriting.
    
    .PARAMETER FilePath
        The full path to the file to be moved.
    
    .PARAMETER QuarantineRoot
        The root directory for quarantined files. Defaults to '_Duplicates' in the current script location.
    
    .EXAMPLE
        Move-ToQuarantine -FilePath "C:\Recipes\ApplePie.pdf"
        Moves ApplePie.pdf to .\_Duplicates\ApplePie.pdf
    
    .EXAMPLE
        Move-ToQuarantine -FilePath "C:\Recipes\ApplePie.pdf" -QuarantineRoot "C:\Quarantine"
        Moves ApplePie.pdf to C:\Quarantine\ApplePie.pdf. If it exists, tries ApplePie_1.pdf.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string]$QuarantineRoot = (Join-Path $PSScriptRoot "_Duplicates")
    )

    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        Write-Warning "File not found: $FilePath"
        return $null
    }

    # Ensure quarantine directory exists
    if (-not (Test-Path -Path $QuarantineRoot)) {
        New-Item -Path $QuarantineRoot -ItemType Directory -Force | Out-Null
    }

    $fileObj = Get-Item -Path $FilePath
    $fileName = $fileObj.Name
    $baseName = $fileObj.BaseName
    $extension = $fileObj.Extension

    $destPath = Join-Path -Path $QuarantineRoot -ChildPath $fileName
    $counter = 1

    # Collision handling
    while (Test-Path -Path $destPath) {
        $newFileName = "${baseName}_${counter}${extension}"
        $destPath = Join-Path -Path $QuarantineRoot -ChildPath $newFileName
        $counter++
    }

    try {
        Move-Item -Path $FilePath -Destination $destPath -Force -ErrorAction Stop
        Write-Verbose "Moved '$fileName' to '$destPath'"
        return $destPath
    }
    catch {
        Write-Error "Failed to move file '$FilePath' to '$destPath': $_"
        return $null
    }
}

Export-ModuleMember -Function Move-ToQuarantine
