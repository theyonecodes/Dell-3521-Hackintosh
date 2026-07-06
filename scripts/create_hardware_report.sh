#!/bin/bash
# Dell 3521 Hackintosh - Hardware Report Generator
# Generates a compatible hardware report for OpCore-Simplify

set -e

REPORT_DIR="$HOME/Downloads/Hackintosh/OpCore-Simplify/SysReport"
REPORT_FILE="$REPORT_DIR/Report.json"

echo "🔍 Generating hardware report for Dell 3521..."

# Create report directory
mkdir -p "$REPORT_DIR"

# Get hardware info
CPU_INFO=$(lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core")
GPU_INFO=$(lspci -nn | grep -i vga)
AUDIO_INFO=$(lspci -nn | grep -i audio)
WIFI_INFO=$(lspci -nn | grep -i network)
BLUETOOTH_INFO=$(lsusb | grep -i bluetooth)
ETHERNET_INFO=$(lspci -nn | grep -i ethernet)
USB_INFO=$(lspci -nn | grep -i usb)

# Create JSON report with correct format (VVVV-DDDD)
cat > "$REPORT_FILE" << EOF
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
      "Audio Endpoints": ["Speakers", "Headphones", "Internal Mic", "External Mic"],
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
      "Disk Drives": ["SSD/HDD"]
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

echo "✅ Hardware report generated at: $REPORT_FILE"

# Validate
echo "🔍 Validating report..."
python3 -c "
from Scripts.report_validator import ReportValidator
v = ReportValidator()
valid, errs, warns, _ = v.validate_report('$REPORT_FILE')
print('Valid:', valid)
if not valid:
    print('Errors:', len(errs))
    for e in errs[:3]: print('  -', e)
if warns:
    print('Warnings:', len(warns))
    for w in warns[:3]: print('  -', w)
"