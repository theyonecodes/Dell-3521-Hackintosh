@echo off
REM Dell 3521 Hackintosh - Windows Environment Setup
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Dell 3521 Hackintosh - Windows Environment Setup
echo ============================================

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo Please run PowerShell or Command Prompt as Administrator.
    pause
    exit /b 1
)

echo [INFO] Setting up Hackintosh build environment on Windows...
echo.

REM Check for required tools
echo [INFO] Checking for required tools...

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git not found. Please install Git from https://git-scm.com/
    goto :error
)

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python from https://python.org/
    goto :error
)

where git >nul 2>&1 && echo [OK] Git found
where python >nul 2>&1 && echo [OK] Python found

REM Install Python packages
echo Installing Python packages...
python -m pip install --upgrade pip
python -m pip install plistlib34 biplist 2>nul

REM Create project directories
if not exist "Dell-3521-Hackintosh" mkdir "Dell-3521-Hackintosh"
cd Dell-3521-Hackintosh
if not exist docs mkdir docs
if not exist scripts mkdir scripts
if not exist images mkdir images
if not exist config_examples mkdir config_examples
if not exist scripts\windows mkdir scripts\windows
if not exist Output mkdir Output

echo.
echo ============================================
echo Environment setup complete!
echo.
echo Next steps:
echo 1. Run hardware validation: python scripts\create_hardware_report.py
echo 2. Build OpenCore EFI: Run OpCore-Simplify.exe
echo 4. Create USB installer
echo.
echo See docs\prerequisites.md for detailed instructions.
echo.

pause
exit /b 0

:error
echo.
echo Please install the missing requirements and try again.
pause
exit /b 1