# Set the directory to search
$directory = "\\your\path\here"

# Set output directory (default is current directory)
$OutputDirectory = "./"

# Set the output CSV file name
$outputFile = ("FileLookup_" + $(([System.Uri]$directory).Host) + "_" + $(Get-Date -Format yyyyMMdd_HHmmss) + ".csv")
$OutputFile_FullPath = Join-Path -Path $OutputDirectory -ChildPath $outputFile

# Define extensions to include
$validExtensions = @(".aspx", ".css", ".png", ".jpg", ".gif", ".vb", ".vbhtml", ".html", ".cshtml")

# Define exact filenames to include (case-insensitive)
$SpecificFileNames = @("web.config", "robots.txt", "sitemap.xml", "custom.config")

# Define wildcard filename patterns to include (e.g., anything ending in bundle.config)
<# $WildcardPatterns = @("*bundle.config", "*override.json") #>
$WildcardPatterns = @()  # Empty, no wildcard patterns used

# Folders to exclude by name (not full path)
$excludedFolders = @("surgeimage")
<# $excludedFolders = @() # Empty, no excluded subfolders #>

# Ensure the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Host "The specified directory does not exist."
    exit
}

# Function to recursively collect files, skipping excluded folders
function Get-FilesExcludingFolders {
    param (
        [string]$BasePath,
        [string[]]$ExcludedFolders,
        [string[]]$ExtensionsToInclude,
        [string[]]$FileNamesToInclude,
        [string[]]$WildcardPatterns
    )

    $allFiles = @()

    # Recurse through subdirectories
    foreach ($subdir in Get-ChildItem -Path $BasePath -Directory -ErrorAction SilentlyContinue) {
        if ($ExcludedFolders -contains $subdir.Name) {
            continue
        }

        # Recurse into subdir
        $allFiles += Get-FilesExcludingFolders -BasePath $subdir.FullName `
                                               -ExcludedFolders $ExcludedFolders `
                                               -ExtensionsToInclude $ExtensionsToInclude `
                                               -FileNamesToInclude $FileNamesToInclude `
                                               -WildcardPatterns $WildcardPatterns
    }

    # Get matching files in current folder
    $currentFiles = Get-ChildItem -Path $BasePath -File -ErrorAction SilentlyContinue | Where-Object {
        ($_.Extension -in $ExtensionsToInclude) -or
        ($_.Name -in $FileNamesToInclude) -or
        ($WildcardPatterns | Where-Object { $_ -and ($_.Name -like $_) })
    }

    $allFiles += $currentFiles
    return $allFiles
}

# Collect filtered files
$files = Get-FilesExcludingFolders -BasePath $directory `
                                   -ExcludedFolders $excludedFolders `
                                   -ExtensionsToInclude $validExtensions `
                                   -FileNamesToInclude $SpecificFileNames `
                                   -WildcardPatterns $WildcardPatterns

# Sort files by last modified date, descending
$sortedFiles = $files | Sort-Object LastWriteTime -Descending

# Export to CSV
$sortedFiles | Select-Object `
    @{Name="File Create Time"; Expression = { $_.CreationTime }},
    @{Name="Last Modified Time"; Expression = { $_.LastWriteTime }},
    @{Name="Full File Path"; Expression = { $_.DirectoryName }},
    @{Name="File Name"; Expression = { $_.Name }} |
    Export-Csv -Path $OutputFile_FullPath -NoTypeInformation

Write-Host "CSV file has been generated: $OutputFile_FullPath"

# Pause to see any output/errors
Pause

# Exit script
exit
