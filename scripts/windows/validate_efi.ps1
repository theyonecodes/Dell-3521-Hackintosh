# Dell 3521 Hackintosh - EFI Validation Script
# Validates OpenCore EFI structure

param(
    [string]$EFIPath = "$env:USERPROFILE\Downloads\Dell-3521-Hackintosh\Output\EFI"
)

$ErrorActionPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dell 3521 Hackintosh - EFI Validator" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

# Check EFI exists
if (-not (Test-Path $EFIPath)) {
    Write-Host "[ERROR] EFI not found at: $EFIPath" -ForegroundColor Red
    Write-Host "Please run build_opencore.bat first." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Validating EFI structure at:" -ForegroundColor Yellow
Write-Host "  $EFIPath" -ForegroundColor White
Write-Host ""

# Required directories
$requiredDirs = @(
    "EFI/OC",
    "EFI/OC/ACPI",
    "EFI/OC/Drivers",
    "EFI/OC/Kexts",
    "EFI/OC/Tools",
    "EFI/BOOT"
)

# Check directories
Write-Host "[INFO] Checking directory structure..." -ForegroundColor Yellow
foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $EFIPath $dir
    if (Test-Path $fullPath) {
        Write-Host "[OK] $dir" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing: $dir" -ForegroundColor Red
        $errors++
    }
}

# Required files
$requiredFiles = @(
    "EFI/OC/OpenCore.efi",
    "EFI/OC/config.plist",
    "EFI/BOOT/BOOTX64.efi"
)

Write-Host ""
Write-Host "[INFO] Checking required files..." -ForegroundColor Yellow
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $EFIPath $file
    if (Test-Path $fullPath) {
        Write-Host "[OK] $file" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing: $file" -ForegroundColor Red
        $errors++
    }
}

# Check Kexts
Write-Host ""
Write-Host "[INFO] Checking kexts..." -ForegroundColor Yellow
$kextsPath = Join-Path $EFIPath "EFI/OC/Kexts"
if (Test-Path $kextsPath) {
    $kexts = Get-ChildItem $kextsPath -Filter "*.kext" -ErrorAction SilentlyContinue
    if ($kexts.Count -gt 0) {
        Write-Host "  Found $($kexts.Count) kexts:" -ForegroundColor Gray
        foreach ($kext in $kexts) {
            Write-Host "    - $($kext.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "[WARNING] No kexts found in EFI/OC/Kexts" -ForegroundColor Yellow
        $warnings++
    }
}

# Check ACPI
Write-Host ""
Write-Host "[INFO] Checking ACPI..." -ForegroundColor Yellow
$acpiPath = Join-Path $EFIPath "EFI/OC/ACPI"
if (Test-Path $acpiPath) {
    $acpiFiles = Get-ChildItem $acpiPath -Filter "*.aml" -ErrorAction SilentlyContinue
    if ($acpiFiles.Count -gt 0) {
        Write-Host "  Found $($acpiFiles.Count) ACPI files:" -ForegroundColor Gray
        foreach ($acpi in $acpiFiles) {
            Write-Host "    - $($acpi.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "[INFO] No custom ACPI files (may be using built-in)" -ForegroundColor Gray
    }
}

# Check Drivers
Write-Host ""
Write-Host "[INFO] Checking EFI drivers..." -ForegroundColor Yellow
$driversPath = Join-Path $EFIPath "EFI/OC/Drivers"
if (Test-Path $driversPath) {
    $drivers = Get-ChildItem $driversPath -Filter "*.efi" -ErrorAction SilentlyContinue
    if ($drivers.Count -gt 0) {
        Write-Host "  Found $($drivers.Count) drivers:" -ForegroundColor Gray
        foreach ($driver in $drivers) {
            Write-Host "    - $($driver.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "[WARNING] No drivers found in EFI/OC/Drivers" -ForegroundColor Yellow
        $warnings++
    }
}

# Validate config.plist
Write-Host ""
Write-Host "[INFO] Validating config.plist..." -ForegroundColor Yellow
$configPath = Join-Path $EFIPath "EFI/OC/config.plist"

if (Test-Path $configPath) {
    try {
        $configContent = Get-Content $configPath -Raw

        # Check for private data
        $privateFields = @("SYSTEMUUID", "SYSTEMNVRAM", "MLB", "ROM", "BaseBoardSerial", "SystemSerial")
        $foundPrivate = @()
        foreach ($field in $privateFields) {
            if ($configContent -match $field) {
                $foundPrivate += $field
            }
        }

        if ($foundPrivate.Count -gt 0) {
            Write-Host "[WARNING] Found potentially sensitive fields:" -ForegroundColor Yellow
            foreach ($f in $foundPrivate) {
                Write-Host "    - $f" -ForegroundColor Yellow
            }
            $warnings++
        } else {
            Write-Host "[OK] No obvious private data found" -ForegroundColor Green
        }

        # Check SMBIOS
        if ($configContent -match "MacBookAir5,2") {
            Write-Host "[OK] SMBIOS: MacBookAir5,2" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] SMBIOS MacBookAir5,2 not found" -ForegroundColor Yellow
            $warnings++
        }

        # Check for required kexts
        $requiredKexts = @("Lilu", "VirtualSMC", "WhateverGreen", "AppleALC")
        foreach ($kext in $requiredKexts) {
            if ($configContent -match $kext) {
                Write-Host "[OK] $kext referenced in config" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] $kext not referenced" -ForegroundColor Yellow
            }
        }

    } catch {
        Write-Host "[ERROR] Failed to parse config.plist: $_" -ForegroundColor Red
        $errors++
    }
} else {
    Write-Host "[ERROR] config.plist not found" -ForegroundColor Red
    $errors++
}

# Final summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "[OK] EFI structure is valid!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Create USB: create_usb_installer.bat" -ForegroundColor White
    Write-Host "  2. Follow docs/windows-installation.md" -ForegroundColor White
} elseif ($errors -eq 0) {
    Write-Host "[WARNING] EFI valid with $warnings warnings" -ForegroundColor Yellow
} else {
    Write-Host "[ERROR] EFI has $errors errors" -ForegroundColor Red
}

Write-Host ""
exit $errors