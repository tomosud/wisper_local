@echo off
chcp 65001
cd /d "%~dp0"
echo ======================================================================
echo Whisper Local Project Downloader
echo ======================================================================
echo.

echo Downloading project files from GitHub...
echo This may take a few minutes...
curl -L -o project.zip "https://codeload.github.com/tomosud/wisper_local/zip/refs/heads/main"

if exist project.zip (
    echo.
    echo Extracting project files...
    tar -xf project.zip

    echo Moving files to current directory...
    xcopy /E /I /Y wisper_local-main\* .
    rmdir /s /q wisper_local-main
    del project.zip

    echo.
    echo ======================================================================
    echo Project files downloaded successfully!
    echo ======================================================================
    echo.
    echo Next step: Run setup_gpu.bat to install dependencies
    echo.
) else (
    echo.
    echo ======================================================================
    echo Error: Failed to download project files
    echo ======================================================================
    echo Please check your internet connection and try again.
    echo.
)

pause
