<#
.SYNOPSIS
    Identifies recipe files and organizes them into a centralized folder structure.

.DESCRIPTION
    This script recursively searches a source directory for files that appear to be recipes.
    It identifies recipes by looking for specific keywords (e.g., "Ingredients") within the file content.
    It supports .docx, .doc, .pdf, .txt, and .tiff files.
    Files can be copied or moved to a destination directory, organized alphabetically.
    A 'Test' mode is available to simulate the process without making changes.

.PARAMETER SourcePath
    The root directory to search for recipes. Defaults to the user's Documents folder.

.PARAMETER DestinationPath
    The directory where recipes will be organized. Defaults to 'C:\Recipes'.

.PARAMETER Mode
    The operation mode: 'Test', 'Copy', or 'Move'. Defaults to 'Test'.

.PARAMETER Keywords
    An array of strings to search for in files to identify them as recipes. Defaults to "Ingredients", "Directions", "Recipe".

.PARAMETER NoRecurse
    If set, the script will only search the top-level directory of the SourcePath.

.EXAMPLE
    .\Organize-Recipes.ps1 -SourcePath "C:\Users\User\Downloads" -DestinationPath "C:\MyRecipes" -Mode Copy

.EXAMPLE
    .\Organize-Recipes.ps1 -Mode Test -Verbose
#>

function Invoke-OrganizeRecipes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Alias("src", "s")]
        [string]$SourcePath = [Environment]::GetFolderPath("MyDocuments"),
        
        [Parameter(Mandatory = $false)]
        [Alias("dst", "d")]
        [string]$DestinationPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "OrganizedRecipes"),

        [Parameter(Mandatory = $false)]
        [Alias("mod", "m")]
        [ValidateSet("Test", "Copy", "Move")]
        [string]$Mode = "Test",

        [Parameter(Mandatory = $false)]
        [Alias("key", "k")]
        [string[]]$Keywords = @("Ingredients", "Directions", "Recipe", "Servings", "Prep time", "Cook time", "Instructions", "Method", "Yield", "Total time", "Nutrition", "Calories"),

        [Parameter(Mandatory = $false)]
        [Alias("nr")]
        [switch]$NoRecurse,

        [Parameter(Mandatory = $false)]
        [string]$LogPath
    )

    # --- Helper Functions ---

    function Write-Log {
        param (
            [string]$Message,
            [string]$Level = "INFO",
            [ConsoleColor]$Color = "White"
        )
        
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMsg = "[$timestamp] [$Level] $Message"
        
        # Write to Host
        switch ($Level) {
            "ERROR" { Write-Host $logMsg -ForegroundColor Red }
            "WARN"  { Write-Host $logMsg -ForegroundColor Yellow }
            "INFO"  { Write-Host $logMsg -ForegroundColor $Color }
            "DEBUG" { Write-Verbose $logMsg }
        }

        # Write to File if LogPath is set
        if ($LogPath) {
            Add-Content -Path $LogPath -Value $logMsg -ErrorAction SilentlyContinue
        }
    }

    function Get-DocxText {
        param ([string]$Path)
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
            $entry = $zip.GetEntry("word/document.xml")
            if ($entry) {
                $reader = New-Object System.IO.StreamReader($entry.Open())
                $content = $reader.ReadToEnd()
                $reader.Close()
                $zip.Dispose()
                return $content -replace '<[^>]+>', ' '
            }
            $zip.Dispose()
        }
        catch {
            Write-Log -Message "Error reading .docx content for $Path : $_" -Level DEBUG
        }
        return ""
    }

    function Get-FileText {
        param ([System.IO.FileInfo]$File)
        
        $content = ""
        switch ($File.Extension.ToLower()) {
            ".txt" { 
                $content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue 
            }
            ".docx" { 
                $content = Get-DocxText -Path $File.FullName 
            }
            ".doc" {
                $content = Get-Content -Path $File.FullName -Raw -Encoding String -ErrorAction SilentlyContinue
            }
            ".pdf" {
                $content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
            }
            ".tiff" { $content = "" }
            ".tif" { $content = "" }
        }
        return $content
    }

    function Test-IsRecipe {
        param (
            [string]$Content,
            [string]$Filename
        )

        # 1. Check Content
        foreach ($keyword in $Keywords) {
            if ($Content -match "$keyword") {
                Write-Log -Message "Found keyword '$keyword' in content of $Filename" -Level DEBUG
                return $true
            }
        }

        # 2. Check Filename (Fallback)
        if ($Filename -match "Recipe") {
            Write-Log -Message "Found 'Recipe' in filename of $Filename" -Level DEBUG
            return $true
        }

        return $false
    }

    function Process-ZipFile {
        param (
            [System.IO.FileInfo]$ZipFile,
            [string]$DestPath,
            [string]$Mode
        )
        
        Write-Log -Message "Inspecting Zip Archive: $($ZipFile.Name)" -Level DEBUG
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile.FullName)
            
            foreach ($entry in $zip.Entries) {
                # Skip directories
                if ($entry.FullName.EndsWith("/")) { continue }

                $isRecipe = $false
                
                # Check filename
                if ($entry.Name -match "Recipe") {
                    $isRecipe = $true
                    Write-Log -Message "Found 'Recipe' in zip entry filename: $($entry.Name)" -Level DEBUG
                }
                # Check content for text-based files inside zip
                elseif ($entry.Name -match "\.(txt|xml|json|md)$") {
                    $reader = New-Object System.IO.StreamReader($entry.Open())
                    $text = $reader.ReadToEnd()
                    $reader.Close()
                    
                    foreach ($keyword in $Keywords) {
                        if ($text -match "$keyword") {
                            $isRecipe = $true
                            Write-Log -Message "Found keyword '$keyword' in zip entry content: $($entry.Name)" -Level DEBUG
                            break
                        }
                    }
                }

                if ($isRecipe) {
                    $firstLetter = $entry.Name.Substring(0, 1).ToUpper()
                    if ($firstLetter -notmatch "[A-Z]") { $firstLetter = "#" }
                    
                    $targetFolder = Join-Path -Path $DestPath -ChildPath $firstLetter
                    $targetFile = Join-Path -Path $targetFolder -ChildPath $entry.Name

                    $actionMsg = "[$Mode] Found Recipe in Zip ($($ZipFile.Name)): $($entry.FullName)"
                    
                    if ($Mode -eq "Test") {
                        Write-Log -Message $actionMsg -Level INFO -Color Green
                        Write-Log -Message "  -> Would extract to: $targetFile" -Level INFO -Color Gray
                    }
                    else {
                        # Always extract (Copy behavior)
                        if (-not (Test-Path $targetFolder)) {
                            New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
                        }
                        Write-Log -Message "Extracting: $($entry.Name) -> $targetFolder" -Level INFO -Color Green
                        
                        # ExtractToFile doesn't support overwrite easily, so delete first if exists
                        if (Test-Path $targetFile) { Remove-Item $targetFile -Force }
                        
                        # Using CopyTo stream approach for reliability
                        $destStream = [System.IO.File]::Create($targetFile)
                        $srcStream = $entry.Open()
                        $srcStream.CopyTo($destStream)
                        $destStream.Close()
                        $srcStream.Close()
                    }
                }
            }
            $zip.Dispose()
        }
        catch {
            Write-Log -Message "Failed to process zip file $($ZipFile.Name): $_" -Level WARN
        }
    }

    # --- Main Logic ---

    Write-Log -Message "Starting Recipe Organizer in '$Mode' mode." -Level INFO -Color Cyan
    Write-Log -Message "Source: $SourcePath"
    Write-Log -Message "Destination: $DestinationPath"
    Write-Log -Message "Keywords: $($Keywords -join ', ')"
    if ($NoRecurse) { Write-Log -Message "Recursive Search: DISABLED" -Level WARN }
    Write-Log -Message "--------------------------------------------------"

    if (-not (Test-Path $SourcePath)) {
        Write-Log -Message "Source path does not exist: $SourcePath" -Level ERROR
        return
    }

    if ($Mode -ne "Test" -and -not (Test-Path $DestinationPath)) {
        Write-Log -Message "Creating destination directory: $DestinationPath"
        New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
    }

    # Build Get-ChildItem parameters
    $gciParams = @{
        Path    = (Join-Path -Path $SourcePath -ChildPath "*")
        File    = $true
        Include = "*.docx", "*.doc", "*.txt", "*.pdf", "*.zip", "*.tiff", "*.tif"
    }

    if (-not $NoRecurse) {
        $gciParams.Recurse = $true
    }

    $files = Get-ChildItem @gciParams | Where-Object { $_.FullName -notlike "$DestinationPath*" }

    Write-Log -Message "Found $($files.Count) files to scan." -Level INFO -Color Cyan

    $count = 0
    $found = 0

    foreach ($file in $files) {
        $count++
        Write-Log -Message "Processing $($file.Name)..." -Level DEBUG
        
        if ($file.Extension.ToLower() -eq ".zip") {
            Process-ZipFile -ZipFile $file -DestPath $DestinationPath -Mode $Mode
            continue
        }

        $content = Get-FileText -File $file
        if (Test-IsRecipe -Content $content -Filename $file.Name) {
            $found++
            $firstLetter = $file.Name.Substring(0, 1).ToUpper()
            if ($firstLetter -notmatch "[A-Z]") { $firstLetter = "#" }
            
            $targetFolder = Join-Path -Path $DestinationPath -ChildPath $firstLetter
            $targetFile = Join-Path -Path $targetFolder -ChildPath $file.Name

            $actionMsg = "[$Mode] Found Recipe: $($file.FullName)"
            
            if ($Mode -eq "Test") {
                Write-Log -Message $actionMsg -Level INFO -Color Green
                Write-Log -Message "  -> Would move/copy to: $targetFile" -Level INFO -Color Gray
            }
            else {
                if (-not (Test-Path $targetFolder)) {
                    New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
                }

                if ($Mode -eq "Copy") {
                    Write-Log -Message "Copying: $($file.Name) -> $targetFolder" -Level INFO -Color Green
                    Copy-Item -Path $file.FullName -Destination $targetFile -Force
                }
                elseif ($Mode -eq "Move") {
                    Write-Log -Message "Moving: $($file.Name) -> $targetFolder" -Level INFO -Color Green
                    Move-Item -Path $file.FullName -Destination $targetFile -Force
                }
            }
        }
    }

    Write-Log -Message "--------------------------------------------------"
    Write-Log -Message "Scan Complete."
    Write-Log -Message "Total Files Scanned: $count"
    Write-Log -Message "Recipes Found: $found"
}

# Auto-Run if executed directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-OrganizeRecipes @PSBoundParameters
}

