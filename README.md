# FileModTime

This PowerShell script retrieves the last modified time of all files in a folder, including subfolders.

### Scripts:

- **findFilesMod.ps1**: Filters files based on their filename or extension.
- **findAllFilesMod.ps1**: Retrieves all files, without filtering by file type.

The `output.csv` file will be saved in the same location as the script.

### Instructions:

1. To run the script, right-click the script file and choose **Run with PowerShell**.
2. The `output.csv` will be pre-sorted by date and time modified, in descending order.

### Script Execution Policy:

If you encounter an error about script execution being disabled, run the following command in PowerShell as Administrator:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

