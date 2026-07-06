# Dell 3521 Hackintosh - Windows Environment Setup (PowerShell)
# Run as Administrator

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dell 3521 Hackintosh - Environment Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Setting up Hackintosh build environment..." -ForegroundColor Yellow
Write-Host ""

# Check for required tools
Write-Host "[INFO] Checking for required tools..." -ForegroundColor Yellow

$tools = @{
    "git" = "Git - https://git-scm.com/"
    "python" = "Python - https://python.org/"
    "powershell" = "PowerShell (included)"
}

$missingTools = @()

foreach ($tool in $tools.Keys) {
    $path = Get-Command $tool -ErrorAction SilentlyContinue
    if ($path) {
        Write-Host "[OK] $tool found: $($path.Source)" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $tool - $($tools[$tool])" -ForegroundColor Red
        $missingTools += $tool
    }
}

if ($missingTools.Count -gt 0) {
    Write-Host ""
    Write-Host "[ERROR] Missing required tools: $($missingTools -join ', ')" -ForegroundColor Red
    Write-Host "Please install the missing tools and run again." -ForegroundColor Yellow
    exit 1
}

# Install Python packages
Write-Host ""
Write-Host "[INFO] Installing Python packages..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
python -m pip install plistlib34 biplist --quiet 2>$null

# Verify Python packages
try {
    python -c "import plistlib; import biplist" 2>$null
    Write-Host "[OK] Python packages installed" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not install Python packages" -ForegroundColor Yellow
}

# Create project directories
Write-Host ""
Write-Host "[INFO] Creating project directories..." -ForegroundColor Yellow

$projectRoot = "$env:USERPROFILE\Downloads\Dell-3521-Hackintosh"
$dirs = @("docs", "scripts", "images", "config_examples", "Tools", "Output", "scripts\windows")

foreach ($dir in $dirs) {
    $fullPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "[CREATE] $fullPath" -ForegroundColor Cyan
    } else {
        Write-Host "[EXISTS] $fullPath" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Environment setup complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: .\scripts\windows\create_hardware_report.ps1" -ForegroundColor White
Write-Host "  2. Run: .\scripts\windows\build_opencore.bat" -ForegroundColor White
Write-Host "  3. Follow docs\windows-installation.md" -ForegroundColor White
Write-Host ""
Write-Host "See docs\prerequisites.md for detailed instructions." -ForegroundColor Gray
Write-Host ""

# Offer to open project folder
$openFolder = Read-Host "Open project folder? (y/n)"
if ($openFolder -eq "y") {
    Start-Explorer $projectRoot
}

exit 0