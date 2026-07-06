# Dell 3521 Hackintosh - Hardware Report Generator (PowerShell)
# Better hardware detection using WMI and PowerShell

param(
    [string]$OutputDir = "$env:USERPROFILE\Downloads\Hackintosh\OpCore-Simplify\SysReport"
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dell 3521 Hackintosh - Hardware Report" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
$ReportFile = Join-Path $OutputDir "Report.json"

Write-Host "[INFO] Gathering hardware information..." -ForegroundColor Yellow
Write-Host ""

# CPU Information
Write-Host "[INFO] Detecting CPU..." -ForegroundColor Gray
$cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
$cpuName = $cpu.Name
$cpuCores = $cpu.NumberOfCores
$cpuThreads = $cpu.NumberOfLogicalProcessors
$cpuMaxSpeed = $cpu.MaxClockSpeed
Write-Host "  CPU: $cpuName" -ForegroundColor White
Write-Host "  Cores: $cpuCores, Threads: $cpuThreads" -ForegroundColor White

# GPU Information
Write-Host ""
Write-Host "[INFO] Detecting GPU..." -ForegroundColor Gray
$gpus = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*Intel*" }
$gpuInfo = @()
foreach ($gpu in $gpus) {
    $pnpDeviceId = $gpu.PNPDeviceID
    # Extract Device ID (VVVV-DDDD format)
    if ($pnpDeviceId -match "PCI\\VEN_([0-9A-F]{4})&DEV_([0-9A-F]{4})") {
        $vendor = $matches[1].ToUpper()
        $device = $matches[2].ToUpper()
        $deviceId = "$vendor-$device"
    } else {
        $deviceId = "0000-0000"
    }
    Write-Host "  GPU: $($gpu.Name) - Device ID: $deviceId" -ForegroundColor White
    $gpuInfo += @{
        Manufacturer = "Intel"
        Codename = "Ivy Bridge"
        DeviceID = $deviceId
        DeviceType = "Integrated GPU"
    }
}

# Audio Information
Write-Host ""
Write-Host "[INFO] Detecting Audio..." -ForegroundColor Gray
$audioDevices = Get-WmiObject Win32_SoundDevice
$audioInfo = @()
foreach ($audio in $audioDevices) {
    $pnpDeviceId = $audio.PNPDeviceID
    if ($pnpDeviceId -match "PCI\\VEN_([0-9A-F]{4})&DEV_([0-9A-F]{4})") {
        $vendor = $matches[1].ToUpper()
        $device = $matches[2].ToUpper()
        $deviceId = "$vendor-$device"
    } else {
        $deviceId = "8086-1E20"  # Default Intel HD Audio
    }
    Write-Host "  Audio: $($audio.Name) - Device ID: $deviceId" -ForegroundColor White
    $audioInfo += @{
        BusType = "PCI"
        DeviceID = $deviceId
        SubsystemID = "0000"
        AudioEndpoints = @("Speakers", "Headphones", "Internal Mic", "External Mic")
        ControllerDeviceID = $deviceId
    }
}

# Network Information
Write-Host ""
Write-Host "[INFO] Detecting Network Adapters..." -ForegroundColor Gray

# Ethernet (Realtek)
$ethernet = Get-WmiObject Win32_NetworkAdapter | Where-Object {
    $_.Name -like "*Realtek*" -and $_.Name -like "*Ethernet*"
} | Select-Object -First 1

$ethDeviceId = "10EC-8136"  # Default RTL8136
if ($ethernet) {
    $pnpDeviceId = $ethernet.PNPDeviceID
    if ($pnpDeviceId -match "PCI\\VEN_([0-9A-F]{4})&DEV_([0-9A-F]{4})") {
        $ethDeviceId = "$($matches[1].ToUpper())-$($matches[2].ToUpper())"
    }
    Write-Host "  Ethernet: $($ethernet.Name) - Device ID: $ethDeviceId" -ForegroundColor White
}

# Wi-Fi (Atheros AR9485)
$wifi = Get-WmiObject Win32_NetworkAdapter | Where-Object {
    $_.Name -like "*Atheros*" -or
    $_.Name -like "*Wireless*" -or
    $_.Name -like "*Wi-Fi*" -or
    $_.Name -like "*168C*"
} | Select-Object -First 1

$wifiDeviceId = "168C-0036"  # Default AR9485
if ($wifi) {
    $pnpDeviceId = $wifi.PNPDeviceID
    if ($pnpDeviceId -match "PCI\\VEN_([0-9A-F]{4})&DEV_([0-9A-F]{4})") {
        $wifiDeviceId = "$($matches[1].ToUpper())-$($matches[2].ToUpper())"
    }
    Write-Host "  Wi-Fi: $($wifi.Name) - Device ID: $wifiDeviceId" -ForegroundColor White
}

# Bluetooth
Write-Host ""
Write-Host "[INFO] Detecting Bluetooth..." -ForegroundColor Gray
$bluetooth = Get-PnpDevice -Class Bluetooth | Where-Object { $_.Status -eq "OK" } | Select-Object -First 1
$btDeviceId = "0CF3-0036"  # Default AR9462
if ($bluetooth) {
    $instanceId = $bluetooth.InstanceId
    if ($instanceId -match "([0-9A-F]{4})&([0-9A-F]{4})") {
        $btDeviceId = "$($matches[1].ToUpper())-$($matches[2].ToUpper())"
    }
    Write-Host "  Bluetooth: $($bluetooth.FriendlyName) - Device ID: $btDeviceId" -ForegroundColor White
}

# USB Controllers
Write-Host ""
Write-Host "[INFO] Detecting USB Controllers..." -ForegroundColor Gray
$usbControllers = Get-WmiObject Win32_USBController | Where-Object { $_.Name -like "*Intel*" }
$usbInfo = @()
$usbIndex = 1
foreach ($usb in $usbControllers) {
    $pnpDeviceId = $usb.PNPDeviceID
    if ($pnpDeviceId -match "PCI\\VEN_([0-9A-F]{4})&DEV_([0-9A-F]{4})") {
        $deviceId = "$($matches[1].ToUpper())-$($matches[2].ToUpper())"
    } else {
        $deviceId = "8086-1E31"
    }
    Write-Host "  USB $($usbIndex): $deviceId" -ForegroundColor White
    $usbInfo += @{
        BusType = "PCI"
        DeviceID = $deviceId
        SubsystemID = "0000"
    }
    $usbIndex++
}

# Build JSON Report
Write-Host ""
Write-Host "[INFO] Building hardware report..." -ForegroundColor Yellow

$report = @{
    Motherboard = @{
        Name = "Dell Inspiron 3521"
        Chipset = "Intel Corporation 7 Series/C216 Chipset Family"
        Platform = "Laptop"
    }
    BIOS = @{
        Version = "A16"
        ReleaseDate = "05/24/2018"
        SystemType = "Laptop"
        FirmwareType = "UEFI"
        SecureBoot = "Disabled"
    }
    CPU = @{
        Manufacturer = "Intel"
        ProcessorName = $cpuName
        Codename = "Ivy Bridge"
        CoreCount = [string]$cpuCores
        CPUCount = "1"
        SIMDFeatures = "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid SSE4.1 SSE4.2 x2apic popcnt tsc_deadline_timer aes xsave AVX f16c rdrand lahf_lm cpuid_fault epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid fsgsbase smep erms xsaveopt dtherm arat pln pts vnmi md_clear flush_l1d"
    }
    GPU = @{}
    Network = @{}
    Sound = @{}
    USBControllers = @{}
    StorageControllers = @()
    Input = @{}
    Monitor = @{}
    CardReader = @{}
    Bluetooth = @{}
    SDController = @{}
    Biometric = @{}
    SystemDevices = @{}
}

# GPU
$report.GPU["GPU_1"] = $gpuInfo[0]

# Network
$report.Network["Network_1"] = @{
    BusType = "PCI"
    DeviceID = $ethDeviceId
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x1c,0x0)/Pci(0x0,0x0)"
    ACPIPath = "_SB.PCI0.RP01.NIC0"
}
$report.Network["Network_2"] = @{
    BusType = "PCI"
    DeviceID = $wifiDeviceId
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x1c,0x1)/Pci(0x0,0x0)"
    ACPIPath = "_SB.PCI0.RP02.WIFI"
}

# Sound
$report.Sound["Sound_1"] = $audioInfo[0]

# USB
$report.USBControllers["USB_1"] = @{
    BusType = "PCI"
    DeviceID = "8086-1E31"
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x14,0x0)"
    ACPIPath = "_SB.PCI0.XHC"
}
$report.USBControllers["USB_2"] = @{
    BusType = "PCI"
    DeviceID = "8086-1E2D"
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x1A,0x0)"
    ACPIPath = "_SB.PCI0.EHC1"
}
$report.USBControllers["USB_3"] = @{
    BusType = "PCI"
    DeviceID = "8086-1E26"
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x1D,0x0)"
    ACPIPath = "_SB.PCI0.EHC2"
}

# Storage
$report.StorageControllers += @{
    Storage_1 = @{
        BusType = "PCI"
        DeviceID = "8086-1E03"
        SubsystemID = "0000"
        PCIPath = "PciRoot(0x0)/Pci(0x1F,0x2)"
        ACPIPath = "_SB.PCI0.SATA"
    }
}

# Input
$report.Input["Keyboard"] = @{
    BusType = "PS2"
    Device = "Standard Keyboard"
    DeviceID = "0000-0000"
    DeviceType = "Keyboard"
}
$report.Input["Mouse"] = @{
    BusType = "PS2"
    Device = "Synaptics Touchpad"
    DeviceID = "0000-0000"
    DeviceType = "Trackpad"
}

# Monitor
$report.Monitor["Monitor_1"] = @{
    ConnectorType = "Internal"
    Resolution = "1366x768"
    ConnectedGPU = "GPU_1"
}

# Card Reader
$report.CardReader["CardReader_1"] = @{
    BusType = "USB"
    Device = "Realtek USB Card Reader"
    DeviceID = "0BDA-0129"
}

# Bluetooth
$report.Bluetooth["Bluetooth_1"] = @{
    BusType = "USB"
    Device = "Atheros AR9462 Bluetooth"
    DeviceID = $btDeviceId
}

# System Devices
$report.SystemDevices["PCI Bridge"] = @{
    BusType = "PCI"
    Device = "Host Bridge"
    DeviceID = "8086-0154"
    SubsystemID = "0000"
    PCIPath = "PciRoot(0x0)/Pci(0x0,0x0)"
    ACPIPath = "_SB.PCI0"
}

# Save JSON
$json = $report | ConvertTo-Json -Depth 10
$json | Out-File -FilePath $ReportFile -Encoding UTF8

Write-Host ""
Write-Host "[OK] Hardware report saved to:" -ForegroundColor Green
Write-Host "  $ReportFile" -ForegroundColor White
Write-Host ""

# Validate report format
Write-Host "[INFO] Validating report format..." -ForegroundColor Yellow

$validationErrors = 0

# Check Device ID format (VVVV-DDDD)
$content = Get-Content $ReportFile -Raw
if ($content -match "[0-9A-F]{4}:[0-9A-F]{4}") {
    Write-Host "[WARNING] Found VVVV:DDDD format - should be VVVV-DDDD (hyphen)" -ForegroundColor Yellow
    $validationErrors++
}

if ($validationErrors -eq 0) {
    Write-Host "[OK] Report format validated" -ForegroundColor Green
} else {
    Write-Host "[WARNING] $validationErrors validation issues found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[INFO] Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run build_opencore.bat to build OpenCore EFI" -ForegroundColor White
Write-Host "  2. Follow docs/windows-installation.md" -ForegroundColor White
Write-Host ""

exit $validationErrors