@echo off
setlocal enabledelayedexpansion

:: Set the directory to search (change this to the desired directory)
set "directory=\\webtst\E$\websites"

:: Set the output CSV file name
set "outputFile=output.csv"

:: Clear the output file if it exists
if exist "%outputFile%" del "%outputFile%"

:: Add header to CSV file
echo Last Modified Time,Full File Path,File Name > "%outputFile%"

:: Set the list of valid extensions (lowercase)
set "validExtensions=.aspx .css .png .jpg .gif .vb .vbhtml .html .cshtml"

:: Recursively find all files in the directory and subdirectories
for /r "%directory%" %%f in (*) do (
    set "file=%%f"
    set "fileExt=%%~xf"
    set "fileName=%%~nxf"
    set "fileNameNoExt=%%~nf"

    :: Convert file extension to lowercase for comparison
    set "fileExt=!fileExt:.=!"
    set "fileExtLower=!fileExt!"
    set "fileExtLower=!fileExtLower:~1!"

    :: Initialize flag for valid files
    set "isValidFile=0"

    :: Check if file has a valid extension
    for %%e in (%validExtensions%) do (
        if /i "!fileExtLower!"=="%%e" set "isValidFile=1"
    )

    :: Special case: check if the file is exactly "web.config"
    if /i "!fileNameNoExt!"=="web.config" set "isValidFile=1"

    :: If the file is valid (either matching extension or special file), process it
    if !isValidFile! equ 1 (
        :: Use the 'forfiles' command to get the last modified time
        for /f "tokens=1,2,3,*" %%a in ('forfiles /m "%%f" /t /c "cmd /c echo @fdate @ftime @path"') do (
            set "modifiedTime=%%a %%b"
            set "fullPath=%%f"
            set "fileName=%%~nxf"
            echo "!modifiedTime!,!fullPath!,!fileName!" >> "%outputFile%"
        )
    )
)

echo CSV file has been generated: %outputFile%
endlocal
