@echo off
chcp 65001
echo Setting up Whisper with GPU support...

echo Creating fresh virtual environment...
if exist venv (
    echo Removing old virtual environment...
    rmdir /s /q venv
)
python -m venv venv

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing PyTorch with CUDA support...
pip uninstall torch torchvision torchaudio -y
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

echo Installing other dependencies...
pip install -r requirements.txt

echo Downloading ffmpeg...
if exist "ffmpeg.exe" (
    echo Removing old ffmpeg.exe...
    del ffmpeg.exe
)
echo This may take a few minutes...
curl -L -o ffmpeg.zip "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
if exist ffmpeg.zip (
    echo Extracting ffmpeg...
    tar -xf ffmpeg.zip --strip-components=2 "ffmpeg-master-latest-win64-gpl/bin/ffmpeg.exe"
    del ffmpeg.zip
    echo ffmpeg.exe downloaded successfully
) else (
    echo Warning: Failed to download ffmpeg. Please download manually from https://ffmpeg.org/
)

echo.
echo GPU setup completed!
pause