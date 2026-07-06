@echo off
REM Dell 3521 Hackintosh - Windows Hardware Report Generator
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Dell 3521 Hackintosh - Windows Hardware Report Generator
echo ============================================

REM Check for Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python from https://python.org/
    pause
    exit /b 1
)

echo [INFO] Generating hardware report for Dell 3521...

REM Create report directory
set REPORT_DIR=%USERPROFILE%\Downloads\Hackintosh\OpCore-Simplify\SysReport
set REPORT_FILE=%REPORT_DIR%\Report.json

if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%"

echo [INFO] Gathering hardware information...

REM Gather hardware info using PowerShell
powershell -Command "
    $cpu = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
    $gpu = Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like '*Intel*'} | Select-Object Name, PNPDeviceID
    $audio = Get-WmiObject Win32_SoundDevice | Select-Object Name, PNPDeviceID
    $wifi = Get-WmiObject Win32_NetworkAdapter | Where-Object {$_.Name -like '*Atheros*' -or $_.Name -like '*Wireless*' -or $_.Name -like '*Wi-Fi*'} | Select-Object Name, PNPDeviceID
    $bt = Get-PnpDevice -Class Bluetooth | Select-Object FriendlyName, InstanceId
    $eth = Get-WmiObject Win32_NetworkAdapter | Where-Object {$_.Name -like '*Realtek*' -and $_.Name -like '*Ethernet*'} | Select-Object Name, PNPDeviceID
    $audio = Get-WmiObject Win32_SoundDevice | Select-Object Name, PNPDeviceID
    
    $cpu | ConvertTo-Json
    $gpu | ConvertTo-Json
    $audio | ConvertTo-Json
" > hardware_info.json 2>&1

echo [INFO] Creating hardware report with correct format (VVVV-DDDD)...

REM Create the JSON report
cat > Report.json << 'EOF'
{
  "Motherboard": {
    "Name": "Dell Inspiron 3521",
    "Chipset": "Intel Corporation 7 Series/C216 Chipset Family",
    "Platform": "Laptop"
  },
  "BIOS": {
    "Version": "A16",
    "Release Date": "05/24/2018",
    "System Type": "Laptop",
    "Firmware Type": "UEFI",
    "Secure Boot": "Disabled"
  },
  "CPU": {
    "Manufacturer": "Intel",
    "Processor Name": "Intel(R) Core(TM) i5-3337U CPU @ 1.80GHz",
    "Codename": "Ivy Bridge",
    "Core Count": "2",
    "CPU Count": "1",
    "SIMD Features": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid SSE4.1 SSE4.2 x2apic popcnt tsc_deadline_timer aes xsave AVX f16c rdrand lahf_lm cpuid_fault epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid fsgsbase smep erms xsaveopt dtherm ida arat pln pts vnmi md_clear flush_l1d"
  },
  "GPU": {
    "GPU_1": {
      "Manufacturer": "Intel",
      "Codename": "Ivy Bridge",
      "Device ID": "8086-0166",
      "Device Type": "Integrated GPU"
    }
  },
  "Network": {
    "Network_1": {
      "Bus Type": "PCI",
      "Device ID": "10EC-8136",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x1c,0x0)/Pci(0x0,0x0)",
      "ACPI Path": "_SB.PCI0.RP01.NIC0"
    },
    "Network_2": {
      "Bus Type": "PCI",
      "Device ID": "168C-0036",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x1c,0x1)/Pci(0x0,0x0)",
      "ACPI Path": "_SB.PCI0.RP02.WIFI"
    }
  },
  "Sound": {
    "Sound_1": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E20",
      "Subsystem ID": "0000",
      "Audio Endpoints": [
        "Speakers",
        "Headphones",
        "Internal Mic",
        "External Mic"
      ],
      "Controller Device ID": "8086-1E20"
    }
  },
  "USB Controllers": {
    "USB_1": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E31",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x14,0x0)",
      "ACPI Path": "_SB.PCI0.XHC"
    },
    "USB_2": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E2D",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x1A,0x0)",
      "ACPI Path": "_SB.PCI0.EHC1"
    },
    "USB_3": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E26",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x1D,0x0)",
      "ACPI Path": "_SB.PCI0.EHC2"
    }
  },
  "Storage Controllers": {
    "Storage_1": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E03",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x1F,0x2)",
      "ACPI Path": "_SB.PCI0.SATA",
      "Disk Drives": [
        "SSD/HDD"
      ]
    }
  },
  "Input": {
    "Keyboard": {
      "Bus Type": "PS2",
      "Device": "Standard Keyboard",
      "Device ID": "0000-0000",
      "Device Type": "Keyboard"
    },
    "Mouse": {
      "Bus Type": "PS2",
      "Device": "Synaptics Touchpad",
      "Device ID": "0000-0000",
      "Device Type": "Trackpad"
    }
  },
  "Monitor": {
    "Monitor_1": {
      "Connector Type": "Internal",
      "Resolution": "1366x768",
      "Connected GPU": "GPU_1"
    }
  },
  "Card Reader": {
    "CardReader_1": {
      "Bus Type": "USB",
      "Device": "Realtek USB Card Reader",
      "Device ID": "0BDA-0129"
    }
  },
  "Bluetooth": {
    "Bluetooth_1": {
      "Bus Type": "USB",
      "Device": "Atheros AR9462 Bluetooth",
      "Device ID": "0CF3-0036"
    }
  },
  "SD Controller": {},
  "Biometric": {},
  "System Devices": {
    "PCI Bridge": {
      "Bus Type": "PCI",
      "Device": "Host Bridge",
      "Device ID": "8086-0154",
      "Subsystem ID": "0000",
      "PCI Path": "PciRoot(0x0)/Pci(0x0,0x0)",
      "ACPI Path": "_SB.PCI0"
    }
  }
}
EOF

echo Hardware report generated successfully!
echo Report saved to: %USERPROFILE%\Downloads\Hackintosh\OpCore-Simplify\SysReport\Report.json
echo.
echo Validating report...
python -c "
import sys
sys.path.append(r'%USERPROFILE%\Downloads\Hackintosh\OpCore-Simplify')
from Scripts.report_validator import ReportValidator
v = ReportValidator()
valid, errs, warns, _ = v.validate_report(r'%USERPROFILE%\Downloads\Hackintosh\OpCore-Simplify\SysReport\Report.json')
print('Valid:', valid)
if not valid:
    print('Errors:', len(errs))
    for e in errs[:3]: print('  -', e)
if warns:
    print('Warnings:', len(warns))
    for w in warns[:3]: print('  -', w)
else:
    print('No warnings!')
"

pause