@echo off
setlocal

REM Define the directory for the virtual environment
set "VENV_DIR=%~dp0venv"

REM Check if the virtual environment already exists
if not exist "%VENV_DIR%" (
    echo Creating a virtual environment...
    python -m venv "%VENV_DIR%"
    if %errorlevel% neq 0 (
        echo Failed to create a virtual environment. Ensure Python is installed and in PATH.
        pause
        exit /b 1
    )
)

REM Activate the virtual environment
call "%VENV_DIR%\Scripts\activate.bat"

REM Install required packages
echo Installing required packages...
pip install requests ping3 tqdm

REM Validate the installation of required packages
python -c "import requests; import ping3; import tqdm" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to install required packages.
    pause
    exit /b 1
)

REM Run the Python script
echo Running the Python script...
python "%~dp0main.py"

echo Script execution finished - stop your node, close both windows and relaunch your node
pause
