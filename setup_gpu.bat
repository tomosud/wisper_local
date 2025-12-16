@echo off
chcp 65001
cd /d "%~dp0"
echo Setting up Whisper with GPU support...

REM Check and download Python embedded version if needed
if not exist "python\python.exe" (
    echo Downloading Python embedded version...
    echo This may take a few minutes...
    curl -L -o python.zip "https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip"
    if exist python.zip (
        echo Extracting Python...
        mkdir python
        tar -xf python.zip -C python
        del python.zip

        echo Setting up pip...
        curl -L -o get-pip.py "https://bootstrap.pypa.io/get-pip.py"
        python\python.exe get-pip.py
        del get-pip.py

        echo Enabling site-packages...
        echo import site >> python\python312._pth

        echo Python embedded version installed successfully
    ) else (
        echo Error: Failed to download Python
        pause
        exit /b 1
    )
) else (
    echo Python embedded version already exists
)

echo.
echo Creating fresh virtual environment...
if exist venv (
    echo Removing old virtual environment...
    rmdir /s /q venv
)
python\python.exe -m venv venv

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