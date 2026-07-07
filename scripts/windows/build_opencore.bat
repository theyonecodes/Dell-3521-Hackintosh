@echo off
REM Dell 3521 Hackintosh - Windows OpenCore EFI Builder
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Dell 3521 Hackintosh - OpenCore EFI Builder
echo ============================================

set OC_SIMPLIFY_DIR=%USERPROFILE%\Downloads\Hackintosh\OpCore-Simplify
set OUTPUT_DIR=%USERPROFILE%\Downloads\Dell-3521-Hackintosh\Output

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Check if OpCore-Simplify exists
if not exist "%OC_SIMPLIFY_DIR%" (
    echo [ERROR] OpCore-Simplify not found at: %OC_SIMPLIFY_DIR%
    echo Please run setup_environment.bat first.
    pause
    exit /b 1
)

REM Check hardware report exists
if not exist "%OC_SIMPLIFY_DIR%\SysReport\Report.json" (
    echo [ERROR] Hardware report not found.
    echo Run create_hardware_report.bat first.
    pause
    exit /b 1
)

echo.
echo [INFO] Building OpenCore EFI with OpCore-Simplify...
echo.

REM Check for OpCore-Simplify executable/batch
if exist "%OC_SIMPLIFY_DIR%\OpCore-Simplify.bat" (
    set OPCORE_EXEC=%OC_SIMPLIFY_DIR%\OpCore-Simplify.bat
) else if exist "%OC_SIMPLIFY_DIR%\OpCore-Simplify.exe" (
    set OPCORE_EXEC=%OC_SIMPLIFY_DIR%\OpCore-Simplify.exe
) else if exist "%OC_SIMPLIFY_DIR%\OpCore-Simplify.py" (
    set OPCORE_EXEC=python "%OC_SIMPLIFY_DIR%\OpCore-Simplify.py"
) else (
    echo [ERROR] OpCore-Simplify executable not found
    echo Expected: OpCore-Simplify.bat, .exe, or .py
    pause
    exit /b 1
)

echo ============================================
echo INSTRUCTIONS - Follow these steps in the menu:
echo ============================================
echo.
echo 1. Select '1. Select Hardware Report'
echo    - Enter: %OC_SIMPLIFY_DIR%\SysReport\Report.json
echo.
echo 2. Select '2. Select macOS Version'
echo    - Select '20. macOS Big Sur 11'
echo.
echo 3. Press Enter for '3. Customize ACPI Patch' (skip)
echo.
echo 4. Select '4. Customize Kexts'
echo    - Enter: 1,2,3,4,6,8,11,12,17,21,22,23,41,42,44,45,64,65,75,76,80,81,82,84,85
echo.
echo 5. Customize SMBIOS
echo    - Select '30. MacBookAir5,2'
echo.
echo 6. Select '6. Build OpenCore EFI'
echo.
echo ============================================
echo.

set /p CONTINUE="Press Enter to launch OpCore-Simplify..."

REM Launch OpCore-Simplify
cd /d "%OC_SIMPLIFY_DIR%"
start "" %OPCORE_EXEC%

echo.
echo [INFO] After building EFI in OpCore-Simplify:
echo - The EFI will be saved to Results\EFI\
echo - This script will copy it to %OUTPUT_DIR%\EFI
echo.

set /p COPY_NOW="Copy EFI to Output directory now? (y/n): "

if /i "!COPY_NOW!"=="y" (
    if exist "%OC_SIMPLIFY_DIR%\Results\EFI" (
        echo [INFO] Copying EFI to Output...
        xcopy /E /H /Y "%OC_SIMPLIFY_DIR%\Results\EFI\*" "%OUTPUT_DIR%\EFI\"
        echo [OK] EFI copied successfully!
    ) else (
        echo [ERROR] Results\EFI not found. Build may have failed.
        pause
        exit /b 1
    )
)

echo.
echo ============================================
echo EFI Build Complete
echo ============================================
echo.
echo Output: %OUTPUT_DIR%\EFI

echo 🔽 Downloading macOS Big Sur recovery image...
echo.

set OPENCORE_PKG=%USERPROFILE%\Downloads\Hackintosh\OpenCorePkg

if exist "%OPENCORE_PKG%" (
    cd /d "%OPENCORE_PKG%\Utilities\macrecovery"
    
    python macrecovery.py -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
    
    if exist "com.apple.recovery.boot" (
        xcopy /E /H /Y "com.apple.recovery.boot\*" "%OUTPUT_DIR%\com.apple.recovery.boot\" >nul
        echo ✅ Recovery image downloaded to %OUTPUT_DIR%\com.apple.recovery.boot
    ) else (
        echo ⚠️ Create USB: Copy recovery manually from:
        echo    %OPENCORE_PKG%\Utilities\macrecovery\com.apple.recovery.boot
    )
) else (
    echo ⚠️ Download macOS recovery manually:
    echo.
    echo 1. cd %USERPROFILE%\Downloads\Hackintosh\OpenCorePkg\Utilities\macrecovery
    echo 2. python macrecovery.py -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
    echo 3. Copy com.apple.recovery.boot to USB
)

echo.
echo Next steps:
echo 1. Verify EFI: dir %OUTPUT_DIR%\EFI\OC\Kexts\
echo 2. Download confirmed: dir %OUTPUT_DIR%\com.apple.recovery.boot\
echo 3. Create USB installer: create_usb_installer.bat
echo.
pause
exit /b 0