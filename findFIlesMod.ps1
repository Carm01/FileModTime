# Set the directory to search (change this to the desired directory)
$directory = "\\your/path/here"

$OutputDirectory = "./" # Set the output directory (change this to the desired output directory) - Default is current directory

# Set the output CSV file name
<# $outputFile = "output.csv" #>
$outputFile = ("WebsiteFileLookup_" + $(([System.Uri]$directory).host) + "_" + $(Get-Date -Format yyyyMMdd) + ".csv")
$OutputFile_FullPath = Join-Path -Path $OutputDirectory -ChildPath $outputFile

# Define the list of valid extensions and include 'web.config'
$validExtensions = @("*.aspx", "*.css", "*.png", "*.jpg", "*.gif", "*.vb", "*.vbhtml", "*.html", "*.cshtml", "web.config")
<# $validExtensions = @("*.png", "*.jpg", "*.gif") #>
# Ensure the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Host "The specified directory does not exist."
    exit
}

# Get all files recursively in the directory, including files that match the extensions or special files
$files = Get-ChildItem -Path $directory -Recurse -File -Include $validExtensions -ErrorAction SilentlyContinue

# Sort the files by last modified date, descending
$sortedFiles = $files | Sort-Object LastWriteTime  -Descending

# Prepare CSV output (Exclude file name from full path)
$sortedFiles | Select-Object @{Name="File Create Time";Expression={$_.CreationTime}},
							@{Name="Last Modified Time";Expression={$_.LastWriteTime}},
                           @{Name="Full File Path";Expression={$_.DirectoryName}}, 
                           @{Name="File Name";Expression={$_.Name}} | 
    Export-Csv -Path $OutputFile_FullPath -NoTypeInformation

Write-Host "CSV file has been generated: $OutputFile_FullPath"

# Close the PowerShell window after completion
Pause
exit
