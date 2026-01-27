@echo off
chcp 65001
cd /d "%~dp0"

if not exist "python\python.exe" (
    echo Error: Python not found. Please run setup_gpu.bat first.
    pause
    exit /b 1
)

start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0whisper_ui.ps1"

