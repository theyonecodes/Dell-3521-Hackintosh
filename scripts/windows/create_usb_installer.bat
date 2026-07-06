@echo off
REM Dell 3521 Hackintosh - Windows USB Installer Creator
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Dell 3521 Hackintosh - USB Installer Creator
echo ============================================

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script requires Administrator privileges!
    echo Please run Command Prompt as Administrator.
    pause
    exit /b 1
)

set EFI_SOURCE=%USERPROFILE%\Downloads\Dell-3521-Hackintosh\Output\EFI
set RECOVERY_SOURCE=%USERPROFILE%\Downloads\OpCore\OpenCore-0.7.8-RELEASE\Utilities\macrecovery\com.apple.recovery.boot

echo.
echo [INFO] Checking source files...
echo.

if not exist "%EFI_SOURCE%" (
    echo [ERROR] EFI not found at: %EFI_SOURCE%
    echo Please run build_opencore.bat first.
    goto :error
)

if not exist "%RECOVERY_SOURCE%" (
    echo [ERROR] Recovery image not found at: %RECOVERY_SOURCE%
    echo Please download macOS recovery using OpCore-Simplify.
    goto :error
)

echo [OK] EFI found
echo [OK] Recovery image found
echo.

echo ============================================
echo SELECT USB DRIVE
echo ============================================
echo.
echo [INFO] Available drives:
echo.

wmic logicaldisk get deviceid,size,volumename

echo.
echo [WARNING] This will ERASE all data on the selected drive!
echo.

set /p USB_DRIVE="Enter USB drive letter (e.g., D): "

if "!USB_DRIVE!"=="" (
    echo [ERROR] No drive specified
    goto :error
)

set USB_DRIVE=!USB_DRIVE:~0,1:

REM Verify drive exists
wmic logicaldisk where "DeviceID='!USB_DRIVE!:'" get DeviceID 2>nul | findstr /i "!USB_DRIVE!:" >nul
if %errorLevel% neq 0 (
    echo [ERROR] Drive !USB_DRIVE!: not found
    goto :error
)

echo.
echo [WARNING] You selected drive !USB_DRIVE!:
echo This will ERASE ALL DATA on this drive.
echo.
set /p CONFIRM="Type 'YES' to confirm: "

if /i not "!CONFIRM!"=="YES" (
    echo Aborted.
    pause
    exit /b 1
)

echo.
echo [INFO] Preparing USB drive !USB_DRIVE!:...
echo.

REM Use diskpart to clean and create EFI partition
(
echo select disk 0
echo list disk
) > %TEMP%\diskpart_list.txt 2>&1

wmic diskdrive get index,model,size 2>nul

echo.
set /p DISK_NUM="Enter disk number for !USB_DRIVE!: (check above list): "

echo select disk !DISK_NUM! > %TEMP%\diskpart_clean.txt
echo clean >> %TEMP%\diskpart_clean.txt
echo convert gpt >> %TEMP%\diskpart_clean.txt
echo create partition primary size=500 >> %TEMP%\diskpart_clean.txt
echo format fs=fat32 quick label="OPENCORE" >> %TEMP%\diskpart_clean.txt
echo assign letter=Z >> %TEMP%\diskpart_clean.txt
echo exit >> %TEMP%\diskpart_clean.txt

echo [INFO] Running diskpart...
diskpart /s %TEMP%\diskpart_clean.txt

if %errorLevel% neq 0 (
    echo [ERROR] diskpart failed
    goto :error
)

echo.
echo [INFO] Copying EFI files...
xcopy /E /H /Y "%EFI_SOURCE%\*" "Z:\EFI\" 
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy EFI
    goto :error
)

echo [INFO] Copying macOS Recovery...
xcopy /E /H /Y "%RECOVERY_SOURCE%\*" "Z:\com.apple.recovery.boot\" 
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy recovery
    goto :error
)

echo.
echo [INFO] Verifying USB structure...
dir Z:\
dir Z:\EFI\
dir Z:\com.apple.recovery.boot\

echo.
echo [INFO] Cleaning up temporary files...
del %TEMP%\diskpart_list.txt 2>nul
del %TEMP%\diskpart_clean.txt 2>nul

echo.
echo ============================================
echo USB Installer created successfully!
echo ============================================
echo.
echo Next steps:
echo 1. Plug USB into Dell 3521
echo 2. Boot with F12, select USB
echo 3. Follow docs\windows-installation.md
echo.
pause
exit /b 0

:error
echo.
echo [ERROR] USB creation failed
echo.
pause
exit /b 1