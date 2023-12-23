@echo off
setlocal enabledelayedexpansion

REM Define Python and Pip paths
set PYTHONEXE=%LocalAppData%\Programs\Python\Python311\python.exe
set PIPCMD=%LocalAppData%\Programs\Python\Python311\Scripts\pip.exe

REM Check if Python is installed
"%PYTHONEXE%" --version >nul 2>&1
if %errorlevel% == 0 goto pythoninstalled

echo Python is not installed. Downloading Python 3.11...

REM Download Python Installer
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe' -OutFile '%~dp0python-installer.exe'"

REM Check if the Python installer was downloaded
if not exist "%~dp0python-installer.exe" (
    echo Failed to download Python installer.
    pause
    exit /b 1
)

echo Python installer downloaded to: %~dp0python-installer.exe
echo Please install Python manually using the downloaded installer and ensure to add Python to PATH.
echo Once Python is installed, please run this script again.
pause
exit

:pythoninstalled
echo Python is installed.

REM Install necessary Python packages
echo Installing required Python packages...
"%PIPCMD%" install requests ping3 tqdm colorama

if %errorlevel% neq 0 (
    echo Failed to install Python packages. Ensure Python and pip are correctly installed.
    pause
    exit /b 1
)

echo Packages installed successfully.

echo REM: SEARCHING GOOD NODES AND WRITING TO THE FOLDER
"%PYTHONEXE%" "%~dp0main.py"
echo REM: TOTAL SUCCESS. RESTART YOUR NODE AND ENJOY
pause
