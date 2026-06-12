@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: ================= Configuration Section =================
:: Set the WinRAR path (modify it if WinRAR is installed elsewhere)
set "WINRAR_PATH=C:\Program Files\WinRAR\WinRAR.exe"

:: Set the relative path to the OBS executable
set "OBS_EXE=bin\64bit\obs64.exe"
:: ==========================================

echo ==========================================
echo       OBS Auto Extract and Launch Tool
echo ==========================================
echo.

:: Check whether OBS already exists
if exist "%OBS_EXE%" (
    echo [Detected] OBS already exists, launching directly...
    goto StartOBS
)

echo [Not Detected] OBS is missing locally, searching for the ZIP package...
echo.

:: Search the parent directory for a ZIP file matching OBS-Studio-XXX-Windows-x64.zip
set "ZIP_FOUND="
for %%F in ("..\OBS-Studio-*-Windows-x64.zip") do (
    set "ZIP_FOUND=%%F"
    goto FoundZip
)

:NotFound
echo [Error] Could not find "OBS-Studio-XXX-Windows-x64.zip" in the parent folder!
echo Please place the correct ZIP package in the parent directory and try again.
pause
exit /b

:FoundZip
echo [ZIP Found] !ZIP_FOUND!
echo Extracting to the current folder, please wait...

:: Check whether WinRAR exists
if not exist "%WINRAR_PATH%" (
    echo [Error] WinRAR was not found. Please check the WINRAR_PATH setting in the script!
    pause
    exit /b
)

:: Use WinRAR for silent extraction (-y means "Yes to All", x means extract with full paths preserved)
"%WINRAR_PATH%" x -y "!ZIP_FOUND!" "%cd%\"
if !errorlevel! neq 0 (
    echo [Error] Extraction failed. Please check whether the archive is corrupted or password-protected.
    pause
    exit /b
)

echo [Extraction Complete] Launching OBS...
echo.

:StartOBS
:: Check again whether the extracted file exists
if exist "%OBS_EXE%" (
    :: Switch to the program directory before launching to avoid configuration file loading issues
    pushd "bin\64bit"
    start "" "obs64.exe" --multi --disable-updater
    popd
) else (
    echo [Error] "%OBS_EXE%" was still not found after extraction. Please check the folder structure inside the ZIP package.
    pause
    exit /b
)

endlocal