# 🔍 Hardware Validation

This step ensures your Dell 3521 has compatible hardware for macOS Big Sur 11.0 and generates a validated hardware report for OpCore-Simplify.

---

## 🧪 Step 1: Verify Hardware Compatibility

### Check CPU Details

```bash
# Check CPU model and features
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"

# Expected output for Dell 3521:
# Model name:            Intel(R) Core(TM) i5-3337U CPU @ 1.80GHz
# Architecture:          x86_64
# CPU(s):                4
# Thread(s) per core:     2
# Core(s) per socket:     2
```

**Verification**: Your CPU must be Ivy Bridge generation (3rd generation Intel Core). The i5-3337U is a **Ultra Low Voltage (ULV)** processor with **17W TDP**, which is perfectly compatible with the **MacBookAir5,2** SMBIOS.

### Check GPU

```bash
# Check GPU details
lspci -nn | grep -i vga

# Expected output:
# 00:02.0 VGA compatible controller [0300]: Intel Corporation Ivy Bridge mobile GT2 [HD Graphics 4000] [8086:0166] (rev 09)
```

✅ **Compatibility Confirmed**: Intel HD 4000 (Device ID: **8086:0166**) is fully supported in macOS Big Sur 11.0 with native graphics acceleration.

### Check Audio

```bash
# Check audio controller
lspci -nn | grep -i audio

# Expected output:
# 00:1b.0 Audio device [0403]: Intel Corporation 7 Series/C216 Chipset Family High Definition Audio Controller [8086:1e20] (rev 04)
```

✅ **Compatible**: Intel HD Audio (**8086:1E20**) works with AppleALC.kext using layout-id 1, 2, 3, or 7.

### Check Wi-Fi & Bluetooth

```bash
# Check Wi-Fi
lspci -nn | grep -i network

# Expected output:
# 02:00.0 Network controller [0280]: Qualcomm Atheros AR9485 Wireless Network Adapter [168c:0036] (rev 01)

# Check Bluetooth
lsusb | grep -i bluetooth

# Expected output:
# Bus 001 Device 006: ID 0cf3:0036 Qualcomm Atheros Communications AR9462 Bluetooth
```

✅ **Compatible**:
- **Wi-Fi**: Atheros AR9485 (**168C:0036**) works with IO80211ElCap.kext
- **Bluetooth**: Atheros AR9462 (**0CF3:0036**) works with Ath3kBT*.kext

### Check Ethernet

```bash
# Check Ethernet controller
lspci -nn | grep -i ethernet

# Expected output:
# 01:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL810xE PCI Express Fast Ethernet controller [10ec:8136] (rev 05)
```

✅ **Compatible**: Realtek RTL8136 (**10EC:8136**) works with RealtekRTL8111.kext

### Check Card Reader

```bash
# Check card reader (if present)
lspci -nn | grep -i "card reader\|sd host"

# Expected output will vary - Dell 3521 typically has:
# USB-based Realtek card reader
```

✅ **Compatible**: Works with RealtekCardReader.kext

### Check USB Controllers

```bash
# Check USB controllers
lspci -nn | grep -i usb

# Expected output:
# 00:14.0 USB controller [0c03]: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller [8086:1e31] (rev 04)
# 00:1a.0 USB controller [0c03]: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #2 [8086:1e2d] (rev 04)
# 00:1d.0 USB controller [0c03]: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #1 [8086:1e26] (rev 04)
```

✅ **Compatible**: All Intel USB 2.0 and 3.0 controllers are natively supported.


---

## 📝 Step 2: Create Hardware Report

### Install OpCore-Simplify

```bash
# Download OpCore-Simplify
cd ~/Downloads
mkdir -p Hackintosh && cd Hackintosh

# Clone the repository
git clone https://github.com/lzhoang2801/OpCore-Simplify.git
cd OpCore-Simplify
```

### Generate Hardware Report

```bash
# Run the hardware report generator
./create_hw_report_colon_format.py

# Then update to hyphen format
cp create_hw_report_colon_format.py create_hw_report_hyphen_format.py
sed -i 's/f"{vendor_id.upper()}:{device_id.upper()}"/f"{vendor_id.upper()}-{device_id.upper()}"/g' create_hw_report_hyphen_format.py
sed -i 's/"0000:0000"/"0000-0000"/g' create_hw_report_hyphen_format.py

# Run updated script
./create_hw_report_hyphen_format.py
```

### Verify Hardware Report

```bash
# Validate the report
cd ~/Downloads/Hackintosh/OpCore-Simplify
python3 -c "
from Scripts.report_validator import ReportValidator
v = ReportValidator()
valid, errs, warns, cleaned = v.validate_report('SysReport/Report.json')
print('Valid:', valid)
if not valid:
    print('Errors:', len(errs))
    for e in errs[:3]: print('  -', e)
if warns:
    print('Warnings:', len(warns))
    for w in warns[:3]: print('  -', w)
else:
    print('✅ No errors or warnings!')
"
```

✅ **Expected Result**: `Valid: True` with no errors or warnings.

> 🔧 **Troubleshooting Tip**: If validation fails, check Device ID formats and ensure:
> - All Device IDs are in **VVVV-DDDD** format (hyphen, not colon)
> - SIMD Features contain **SSE4.1 SSE4.2** (uppercase with dots)
> - **Monitor section** exists with **Internal** connection type
> - Sound Device ID is **8086-1E20** (not 0000-0000)

### Apply Manual Corrections if Needed

```bash
# Manually edit the report if validation fails
nano SysReport/Report.json

# Key corrections to make:
# 1. Change "Device ID": "8086:0166" --> "8086-0166"
# 2. Change "SIMD Features": "sse4_1 sse4_2" --> "SSE4.1 SSE4.2"
# 3. Add "Monitor" section if missing
# 4. Change Sound Device ID to "8086-1E20"
```

### Sample Validated Hardware Report Structure

```json
{
  "Motherboard": {
    "Name": "Unknown",
    "Chipset": "Intel Corporation 3rd Gen Core processor DRAM Controller",
    "Platform": "Laptop"
  },
  "CPU": {
    "Manufacturer": "Intel",
    "Processor Name": "Intel(R) Core(TM) i5-3337U CPU @ 1.80GHz",
    "Codename": "Ivy Bridge",
    "Core Count": "2",
    "CPU Count": "1",
    "SIMD Features": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 SSE4.1 SSE4.2 xsave AVX"
  },
  "GPU": {
    "GPU_1": {
      "Manufacturer": "Intel",
      "Codename": "Ivy Bridge",
      "Device ID": "8086-0166",
      "Device Type": "Integrated GPU"
    }
  },
  "Monitor": {
    "Monitor_1": {
      "Connector Type": "Internal",
      "Resolution": "1366x768",
      "Connected GPU": "GPU_1"
    }
  },
  "Sound": {
    "Sound_1": {
      "Bus Type": "PCI",
      "Device ID": "8086-1E20",
      "Subsystem ID": "0000"
    }
  }
}
```


---

## 🧩 Step 3: Apply Hardware-Specific Fixes

### For Intel HD Graphics 4000

✅ **Natively Supported**: Intel HD 4000 is fully supported with **WhateverGreen.kext**. No additional patches needed beyond proper Device ID format.

### For Audio (8086-1E20)

✅ **Detection**: Works with AppleALC.kext
- **Recommended layout-id**: 1, 2, 3, or 7 (test all)
- **Post-install**: Set via boot-args: `alcid=1`

### For Wi-Fi (168C-0036)

✅ **Detection**: Works with IO80211ElCap.kext
- **Boot-arg**: `airportatheros=1`
- **Anticipated interface**: `en0`

### For Bluetooth (0CF3-0036)

✅ **Detection**: Works with Ath3kBT + Ath3kBTInjector
- **Boot-arg**: `bluetoothio=1`

### For Realtek Ethernet (10EC-8136)

✅ **Detection**: Works with RealtekRTL8111.kext

### For USB

⚠️ **Post-install**: USB ports will work initially with **UTBDefault.kext**, but proper mapping is required (covered in [Post-Install Setup](post-install.md)).

### For Power Management

✅ **Working**: i5-3337U has native power management with **MacBookAir5,2** SMBIOS.


---

## 📊 Compatibility Summary

| Hardware Component      | Device ID      | Status      | Solution                          | Notes                          |
|------------------------|----------------|-------------|-----------------------------------|--------------------------------|
| **CPU**               | -              | ✅         | MacBookAir5,2 SMBIOS             | Ivy Bridge ULV compatible      |
| **GPU**               | 8086-0166      | ✅         | WhateverGreen.kext               | Native acceleration            |
| **Wi-Fi**             | 168C-0036      | ✅         | IO80211ElCap.kext                | Works perfectly                |
| **Bluetooth**         | 0CF3-0036      | ✅         | Ath3kBTInjector.kext + Ath3kBT.kext | Working firmware upload      |
| **Ethernet**          | 10EC-8136      | ✅         | RealtekRTL8111.kext              | Full network functionality     |
| **Audio**             | 8086-1E20      | ✅         | AppleALC.kext (layout-id=?)      | Layout-id 1-7 may work         |
| **Card Reader**       | -              | ✅         | RealtekCardReader.kext           | Working detection              |
| **USB**               | Various        | ✅         | USBToolBox mapping               | All ports functional            |
| **Battery**           | -              | ✅         | SMCBatteryManager.kext           | Percentage & status working    |
| **Sleep/Wake**        | -              | ✅         | HibernationFixup.kext + ECEnabler  | Working perfectly               |
| **Display Brightness**| -              | ✅         | BrightnessKeys.kext              | Full control                   |


---

## 🚀 Next Steps

📖 **[EFI Configuration](efi-configuration.md)** → 
Learn how to configure and build your OpenCore EFI using OpCore-Simplify.

```mermaid
flowchart LR
    A[🔍 Hardware Validation] --> B[⚙️ EFI Configuration]
    B --> C[💾 macOS Installation]
```