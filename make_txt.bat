@echo off
chcp 65001
cd /d "%~dp0"
echo Starting Whisper text transcription...

if "%~1"=="" (
    echo No file provided. Please drag and drop a file onto this batch file.
    pause
    exit /b 1
)

echo Activating virtual environment...
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo Error: Virtual environment not found. Please run setup_gpu.bat first.
    pause
    exit /b 1
)

echo Running transcription tool...
python whisper_transcriber.py %*

pause
