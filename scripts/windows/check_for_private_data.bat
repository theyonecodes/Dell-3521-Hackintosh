@echo off
REM Dell 3521 Hackintosh - Windows Privacy Checker
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Dell 3521 Hackintosh - Privacy Data Checker
echo ============================================
echo.
echo [INFO] Scanning for sensitive data in config.plist...
echo.

set REPORT_DIR=%USERPROFILE%\Downloads\Dell-3521-Hackintosh
set FOUND_PRIVATE=0

REM List of sensitive fields to check
set SENSITIVE_FIELDS=SYSTEMUUID SYSTEMNVRAM MLB ROM ROm-DATA BaseBoardSerial SystemSerial

echo Checking: %REPORT_DIR%\Output\EFI\OC\config.plist
echo.

if not exist "%REPORT_DIR%\Output\EFI\OC\config.plist" (
    echo [SKIP] config.plist not found
    goto :check_docs
)

REM Use PowerShell to check for private data
powershell -Command "
    $configPath = '%REPORT_DIR%\Output\EFI\OC\config.plist'
    if (Test-Path $configPath) {
        $content = Get-Content $configPath -Raw

        $sensitive = @(
            'SYSTEMUUID',
            'SYSTEMNVRAM',
            'MLB',
            'ROM',
            'BaseBoardSerial',
            'SystemSerial',
            'HwAddr',
            'AppleClientId'
        )

        $found = @()
        foreach ($field in $sensitive) {
            if ($content -match $field) {
                $found += $field
            }
        }

        if ($found.Count -gt 0) {
            Write-Host '[WARNING] Found potentially sensitive fields:' -ForegroundColor Yellow
            foreach ($f in $found) {
                Write-Host \"  - $f\"
            }
            exit 1
        } else {
            Write-Host '[OK] No obvious private data found' -ForegroundColor Green
            exit 0
        }
    } else {
        Write-Host '[SKIP] config.plist not found'
        exit 2
    }
"

if %errorLevel% equ 1 (
    set FOUND_PRIVATE=1
    echo.
    echo [WARNING] Private data may be present in config.plist
    echo Please review and sanitize before sharing!
) else if %errorLevel% equ 2 (
    echo [SKIP] config.plist not found
)

:check_docs
echo.
echo Checking documentation for private data...
echo.

REM Check README and docs for serial numbers, UUIDs, etc.
for %%F in (README.md docs\*.md) do (
    if exist "%REPORT_DIR%\%%F" (
        findstr /I /C:"serial" /C:"uuid" /C:"0x123456" "%REPORT_DIR%\%%F" >nul 2>&1
        if not errorlevel 1 (
            echo [WARNING] %%F may contain private data references
        )
    )
)

REM Check for any leftover .json files with real hardware info
if exist "%REPORT_DIR%\scripts\windows\hardware_info.json" (
    echo [WARNING] Found hardware_info.json - should be deleted before sharing
    set FOUND_PRIVATE=1
)

if exist "%REPORT_DIR%\SysReport" (
    echo [INFO] SysReport directory exists
    echo        Review contents before sharing
)

echo.
echo ============================================
echo Privacy Check Complete
echo ============================================
echo.

if %FOUND_PRIVATE%==1 (
    echo [WARNING] Some private data may be present
    echo Review the warnings above and sanitize manually
) else (
    echo [OK] No obvious private data found
)

echo.
echo To sanitize your repository:
echo 1. Delete any hardware_info.json files
echo 2. Generate new SMBIOS serial numbers
echo 3. Remove or sanitize any personal info from docs
echo.
pause
exit /b %FOUND_PRIVATE%