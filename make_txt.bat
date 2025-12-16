@echo off
chcp 65001
cd /d "%~dp0"
echo Starting Whisper text transcription...

if "%~1"=="" (
    echo No file provided. Please drag and drop a file onto this batch file.
    pause
    exit /b 1
)

echo Checking Python installation...
if not exist "python\python.exe" (
    echo Error: Python not found. Please run setup_gpu.bat first.
    pause
    exit /b 1
)

echo Running transcription tool...
python\python.exe whisper_transcriber.py %*

pause
