# Set the directory to search (change this to the desired directory)
$directory = "\\your\path\here"

# Set the output CSV file name
$outputFile = "output.csv"

# Define the list of valid extensions and the special file name
$validExtensions = @(".aspx", ".css", ".png", ".jpg", ".gif", ".vb", ".vbhtml", ".html", ".cshtml")
$specialFiles = @("web.config")

# Ensure the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Host "The specified directory does not exist."
    exit
}

# Get all files recursively in the directory
$files = Get-ChildItem -Path $directory -Recurse -File -ErrorAction SilentlyContinue

# Filter files based on extension or special file name
$filteredFiles = $files | Where-Object {
    $fileExtension = $_.Extension.ToLower()
    $fileName = $_.Name.ToLower()

    # Check if the file's extension matches any of the valid extensions or if it's the special "web.config"
    $validExtensions -contains $fileExtension -or $specialFiles -contains $fileName
}

# Sort the filtered files by last modified date, descending
$sortedFiles = $filteredFiles | Sort-Object LastWriteTime -Descending

# Prepare CSV output (Exclude file name from full path)
$sortedFiles | Select-Object @{Name="Last Modified Time";Expression={$_.LastWriteTime}}, 
                           @{Name="Full File Path";Expression={$_.DirectoryName}}, 
                           @{Name="File Name";Expression={$_.Name}} | 
    Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "CSV file has been generated: $outputFile"

# Close the PowerShell window after completion
exit
