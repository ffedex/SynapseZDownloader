@echo off
setlocal enabledelayedexpansion

:: Check if the script is already running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    set "rightsStatus=User"
) else (
    set "rightsStatus=Admin"
)

:: Define variables
set "url=https://synapsez.net/download"
set "currentDir=%~dp0"  :: Gets the current directory of the batch file
set "zipFile=%currentDir%Synapse Z.zip"

:: Check if the zip file already exists
if exist "%zipFile%" (
    set "newZipFile=%currentDir%!random!_Synapse Z.zip"
    echo The file "Synapse Z.zip" already exists. Renaming the new download to "!newZipFile!".
) else (
    set "newZipFile=%zipFile%"
)

:: Ask if the user wants to download Synapse Z.zip
:askDownload
cls  :: Clear the console
echo Rights status: [%rightsStatus%]
set /p downloadInput="Do you want to download Synapse Z.zip? [yes or no]: "

if /i "%downloadInput%"=="y" (
    goto download
) else if /i "%downloadInput%"=="n" (
    echo You chose not to download Synapse Z.zip.
    exit /b  :: Exit without downloading
) else (
    cls  :: Clear the console again for invalid input
    echo Invalid input. Please enter 'yes' or 'no'.
    goto askDownload  :: Repeat the question
)

:download
:: Change to current directory
cd /d "%currentDir%" || exit /b

:: Download the file with the new name if it doesn't exist
echo Downloading Synapse Z...
powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%newZipFile%'"

:: Check if the download was successful
if not exist "%newZipFile%" (
    echo Failed to download the file. Please check the URL and your internet connection.
    pause
    exit /b
)

:: Create extraction directory with random name
set "randomFolderName=!random!"
mkdir "%currentDir%!randomFolderName!"

:: Extract the zip file into the new extraction directory with a random name
echo Extracting files...
powershell -Command "Expand-Archive -Path '%newZipFile%' -DestinationPath '%currentDir%!randomFolderName!' -Force"

:: Check if extraction was successful by looking for SynapseLauncher.exe in the new directory
if not exist "%currentDir%!randomFolderName!\SynapseLauncher.exe" (
    echo Extraction failed. Please check if the zip file is valid.
    pause
    exit /b
)

:: Delete the zip file after extraction
del "%newZipFile%"
echo Deleted zip file: %newZipFile%

:: Prompt user to run SynapseLauncher.exe or not
:askRunAdmin
cls  :: Clear the console
echo Rights status: [%rightsStatus%]
set /p runInput="Do you want to run SynapseLauncher.exe? [yes or no]: "

if /i "%runInput%"=="y" (
    start "" "%currentDir%!randomFolderName!\SynapseLauncher.exe"
) else if /i "%runInput%"=="n" (
    echo You chose not to run SynapseLauncher.exe.
) else (
    cls  :: Clear the console again for invalid input
    echo Invalid input. Please enter 'yes' or 'no'.
    goto askRunAdmin  :: Repeat the question for running prompt
)

endlocal