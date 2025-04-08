# Set the directory to search (change this to the desired directory)
$directory = "\\yourPathHere"

# Set the output CSV file name
$outputFile = "output.csv"

# Define the list of valid extensions and include 'web.config'
$validExtensions = @("*.aspx", "*.css", "*.png", "*.jpg", "*.gif", "*.vb", "*.vbhtml", "*.html", "*.cshtml", "web.config")

# Ensure the directory exists
if (-Not (Test-Path -Path $directory)) {
    Write-Host "The specified directory does not exist."
    exit
}

# Get all files recursively in the directory, including files that match the extensions or special files
$files = Get-ChildItem -Path $directory -Recurse -File -Include $validExtensions -ErrorAction SilentlyContinue

# Sort the files by last modified date, descending
$sortedFiles = $files | Sort-Object LastWriteTime -Descending

# Prepare CSV output (Exclude file name from full path)
$sortedFiles | Select-Object @{Name="Last Modified Time";Expression={$_.LastWriteTime}}, 
                           @{Name="Full File Path";Expression={$_.DirectoryName}}, 
                           @{Name="File Name";Expression={$_.Name}} | 
    Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "CSV file has been generated: $outputFile"

# Close the PowerShell window after completion
exit
