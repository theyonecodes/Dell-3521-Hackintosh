# Hackintosh macOS Monterey on Dell Inspiron 3521 — Complete Guide

This repo contains a **fully working, tested Hackintosh build** for the **Dell Inspiron 3521** (and variants like 3520, 3521, 3721) using **OpenCore 1.0.7** and **macOS Monterey 12.7.x**. Everything here was built, tested, and verified working on real hardware. If you follow this guide exactly, it will work.

---

## Table of Contents
1. [Hardware That Works](#1-hardware-that-works)
2. [What Works](#2-what-works)
3. [What Doesn't Work](#3-what-doesnt-work)
4. [Critical Hardware Notes](#4-critical-hardware-notes) ← READ THIS
5. [Installation Overview](#5-installation-overview)
6. [Step 1: Download macOS Monterey](#6-step-1-download-macos-monterey)
7. [Step 2: Prepare USB](#7-step-2-prepare-usb)
8. [Step 3: Copy EFI to USB](#8-step-3-copy-efi-to-usb)
9. [Step 4: BIOS Settings](#9-step-4-bios-settings)
10. [Step 5: Boot & Install](#10-step-5-boot--install)
11. [Step 6: Post-Install (No More USB)](#11-step-6-post-install-no-more-usb)
12. [Post-Installation](#12-post-installation)
13. [Troubleshooting](#13-troubleshooting)
14. [Full EFI Structure](#14-full-efi-structure)
15. [Maintenance & Updates](#15-maintenance--updates)

---

## 1. Hardware That Works

### Verified Hardware Specs
| Component | Model | macOS Status |
|-----------|-------|-------------|
| **CPU** | Intel Core i5-3337U (Ivy Bridge, 2.0GHz) | ✅ Native |
| **GPU** | Intel HD Graphics 4000 | ✅ QE/CI native |
| **WiFi** | **Broadcom BCM94352Z** (replaces stock Atheros AR9560) | ✅ Working |
| **Ethernet** | **Realtek RTL8101E** (`10EC:8136`) | ✅ Working |
| **Bluetooth** | **Broadcom BCM20702A3** (on BCM94352Z card) | ✅ Working |
| **Audio** | ALC3221 (mapped to ALC282) | ✅ Working |
| **Battery** | Dell smart battery | ✅ Working |
| **Trackpad** | PS/2 touchpad (VoodooRMI) | ✅ Working |
| **Keyboard** | Built-in + external | ✅ Working |
| **Camera** | Built-in 720p | ✅ Working |
| **HDMI** | HDMI output | ✅ Working |
| **Card Reader** | SD slot | ✅ Working |
| **USB 3.0** | All ports | ✅ Working |

---

## 2. What Works

- **Booting** from internal SSD without USB (after setup)
- **WiFi** via Broadcom BCM94352Z (full 5GHz + 2.4GHz, ~100+ Mbps)
- **Ethernet** at full speed (RTL8101E)
- **Brightness** control (Fn + Up/Down)
- **Battery** percentage in menu bar
- **Sleep/Wake** (close lid = sleep)
- **Audio** (speakers + headphone jack)
- **Camera** (FaceTime, Photo Booth)
- **USB** (all ports working)
- **HDMI** external display
- **Card reader** (SD cards)
- **Trackpad** with basic gestures
- **Bluetooth** (keyboard, mouse, audio — native via BCM94352Z)

---

## 3. What Doesn't Work

| Feature | Reason |
|---------|--------|
| **AirDrop/Handoff** | Requires newer WiFi card or compatible Broadcom |
| **iMessage/FaceTime** | Requires proper Apple services account setup (not included) |
| **Metal GPU API** | HD4000 predates Metal (some apps may not work) |
| **Native App Store** | Requires Apple ID config — see post-install notes |

### Wireless Note
Stock WiFi (Atheros AR9560) is **not supported** on Monterey — it has no compatible driver. **You must replace the internal WiFi card with a Broadcom BCM94352Z** (or BCM94360CS2) for full WiFi + Bluetooth support.

---

## 4. Critical Hardware Notes

### ⚠️ WiFi Card Swap — AR9560 → Broadcom BCM94352Z
The stock Dell 3521 comes with **Atheros AR9560** (`168C:0036`), which is **not supported on macOS Monterey**. To get WiFi + Bluetooth working, you **must replace the internal WiFi card** with a compatible Broadcom card such as:
- **BCM94352Z** (half Mini PCIe, NGFF key E) ← recommended
- **BCM94360CS2** (full height Mini PCIe)

After swapping, use `AirportBrcmFixup.kext`, `BrcmFirmwareData.kext`, and `BrcmBluetoothInjector.kext` for WiFi + Bluetooth support.

### ⚠️ Ethernet — NOT RTL8111!
The Ethernet chip is **Realtek RTL8101E** (`10EC:8136`), NOT RTL8111 (`10EC:8168`). This repo uses `RealtekRTL8100.kext` with `IOPCIMatch = 0x813610ec` — the correct kext for RTL8101E. Using `RealtekRTL8111.kext` will break Ethernet.

### ⚠️ CPU — Ivy Bridge i5-3337U
This laptop has an **Ivy Bridge** (3rd gen Intel) CPU, not Kaby Lake. Correct SMBIOS is **MacBookAir5,2**. Do NOT use MacBookPro14,1 or MacBookAir6,2 — they are for different CPU generations and will cause boot issues.

---

## 5. Installation Overview

```
Step 1: Download macOS Monterey recovery image (macrecovery.py)
↓
Step 2: Create bootable USB (FAT32, GPT) with OpenCore 1.0.7
↓
Step 3: Copy this repo's EFI to USB EFI partition
↓
Step 4: Set BIOS settings (Secure Boot off, UEFI mode, AHCI)
↓
Step 5: Boot from USB → OpenCore picker → macOS Monterey Installer
↓
Step 6: Install macOS Monterey to internal SSD
↓
Step 7: Copy EFI to internal SSD (never need USB again)
↓
Step 8: Done — boots independently from SSD
```

**Time: ~2-3 hours for fresh install**

---

## 6. Step 1: Download macOS Monterey

Use the **macrecovery.py** script from OpenCorePkg:

```bash
# Download OpenCorePkg from: https://github.com/acidanthera/OpenCorePkg/releases
# Extract and open Utilities/macrecovery/ folder

# For macOS Monterey (12):
python macrecovery.py -b Mac-FFE5EF870D7BA81A -m 00000000000000000 download
```

This downloads the `BaseSystem.dmg` and `BaseSystem.chunklist` files needed for the installer.

> **macOS 12 note:** It is advisable to map your USB ports (with USBToolBox) before installing. Monterey introduces changes to the USB stack. However, `USBInjectAll.kext` + `XhciPortLimit` quirk (enabled in this config) provides basic USB support for installation.

---

## 7. Step 2: Prepare USB

### Format USB as GPT + FAT32
1. Insert 16GB+ USB drive
2. Open **Disk Management** (Windows) or **Disk Utility** (macOS)
3. Format:
   - **Name:** `EFIBOOT` (or any name)
   - **Format:** `MS-DOS (FAT32)` (Windows) or `FAT32` (macOS)
   - **Scheme:** `GUID Partition Map`

### Create Recovery Folder
At the root of the USB drive, create folder: `com.apple.recovery.boot`
Copy the downloaded `BaseSystem.dmg` and `BaseSystem.chunklist` into this folder.

### Copy OpenCore EFI
From OpenCorePkg, copy the **`EFI`** folder (from X64 directory) to the USB root.
Then replace the `EFI/OC/` folder with this repo's EFI folder.

The USB should look like:
```
USB/
├── com.apple.recovery.boot/
│   ├── BaseSystem.dmg
│   └── BaseSystem.chunklist
└── EFI/
    ├── BOOT/
    │   └── BOOTx64.efi
    └── OC/
        ├── OpenCore.efi ← OpenCore 1.0.7
        ├── config.plist
        ├── ACPI/
        ├── Drivers/
        ├── Kexts/
        └── Tools/
```

---

## 8. Step 3: Copy EFI to USB

### Mount USB EFI Partition
**On Windows:** The EFI partition mounts automatically when you insert the USB (drive letter `I:` or similar). Copy the `EFI` folder contents to the root of the USB.

**On macOS:**
```bash
diskutil list
# Find USB EFI partition (e.g., /dev/disk2s1)
mkdir -p /Volumes/USB_EFI
mount -t msdos /dev/disk2s1 /Volumes/USB_EFI
cp -R EFI /Volumes/USB_EFI/
```

### Verify USB EFI Structure
```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi          ← OpenCore 1.0.7
    ├── config.plist           ← MacBookAir5,2 SMBIOS
    ├── ACPI/
    │   ├── SSDT-EC-LAPTOP.aml
    │   ├── SSDT-HPET.aml
    │   ├── SSDT-PM.aml        ← CPU power management
    │   ├── SSDT-PNLF.aml      ← Backlight control
    │   └── SSDT-XOSI.aml      ← OS fix
    ├── Drivers/
    │   ├── OpenHfsPlus.efi    ← HFS+ support (OC 1.0.7)
    │   ├── OpenPartitionDxe.efi
    │   ├── OpenRuntime.efi
    │   ├── Ps2KeyboardDxe.efi
    │   ├── Ps2MouseDxe.efi
    │   └── UsbMouseDxe.efi
    ├── Kexts/
    │   ├── AirportBrcmFixup.kext ← BCM94352Z WiFi
    │   ├── AppleALC.kext         ← Audio (ALC282)
    │   ├── BrcmBluetoothInjector.kext ← BCM Bluetooth
    │   ├── BrcmFirmwareData.kext ← BCM firmware
    │   ├── BrcmPatchRAM3.kext    ← BCM BT patch
    │   ├── Lilu.kext             ← Core kext
    │   ├── RealtekRTL8100.kext   ← RTL8101E Ethernet
    │   ├── SMCBatteryManager.kext ← Battery
    │   ├── SMCDellSensors.kext   ← Dell sensors
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBInjectAll.kext     ← USB ports
    │   ├── VirtualSMC.kext       ← SMC emulation
    │   ├── VoodooPS2Controller.kext ← Keyboard
    │   │   ├── VoodooPS2Keyboard.kext
    │   │   ├── VoodooPS2Mouse.kext
    │   │   └── VoodooPS2Trackpad.kext
    │   ├── VoodooRMI.kext        ← Trackpad (RMI)
    │   │   ├── RMII2C.kext
    │   │   ├── RMISMBus.kext
    │   │   └── VoodooInput.kext
    │   ├── VoodooSMBus.kext
    │   └── WhateverGreen.kext   ← GPU patches
    └── Tools/
        ├── CleanNvram.efi
        └── OpenShell.efi
```

---

## 9. Step 4: BIOS Settings

**Power off → F2 to enter BIOS**

| Setting | Value | Location |
|---------|-------|----------|
| Secure Boot | **Disabled** | Boot → Secure Boot → Disabled |
| SATA Operation | **AHCI** | Storage → SATA Operation → AHCI |
| Boot List Option | **UEFI** | Boot → Boot List Option → UEFI |
| Fast Boot | **Disabled** | Boot → Fast Boot → Disabled |
| Legacy Option ROMs | **Disabled** | Boot → Legacy ROMs → Disabled |

Press **F10** to save and exit.

---

## 10. Step 5: Boot & Install

### Boot from USB
1. Power on → press **F12** repeatedly → Boot Menu appears
2. Select **USB UEFI: [your USB device]**
3. **OpenCore picker** appears ✅

### Reset NVRAM (Important — Do This First)
Before installing, reset NVRAM to clear old boot data:
1. From OpenCore picker: press **Spacebar**
2. Select **Reset NVRAM**
3. Press **Enter**
4. System reboots

### Boot Again from USB
Press **F12** → select **USB UEFI** again. OpenCore picker should reappear.

### Install macOS
1. Select **macOS Monterey Installer** from OpenCore picker
2. Wait for macOS Recovery to load
3. Select **Disk Utility** → Erase internal SSD:
   - Name: `MacOS`
   - Format: `APFS`
   - Scheme: `GUID Partition Map`
4. Close Disk Utility
5. Select **Reinstall macOS Monterey**
6. Choose internal SSD as target
7. Click **Install**

Installation takes **20-40 minutes**. Laptop may reboot 2-3 times. Each time: press **F12** → select **USB UEFI** to continue.

---

## 11. Step 6: Post-Install (No More USB)

After macOS is installed and you're at the desktop, **copy the working EFI to the internal SSD** so you never need USB again.

### Mount Internal SSD EFI Partition
```bash
diskutil list
# Find internal SSD EFI partition — likely /dev/disk0s1
mkdir -p ~/Desktop/SSD_EFI
mount -t msdos /dev/disk0s1 ~/Desktop/SSD_EFI
```

### Copy EFI to Internal SSD
```bash
# Backup old EFI first (optional)
cp -R ~/Desktop/SSD_EFI/EFI ~/Desktop/SSD_EFI/EFI.backup

# Copy working EFI
cp -R /Volumes/USB_EFI/EFI ~/Desktop/SSD_EFI/
```

### Verify
```bash
ls ~/Desktop/SSD_EFI/EFI/OC/
# Should show: OpenCore.efi, config.plist, Kexts/, ACPI/, etc.
```

### Remove USB and Reboot
1. **Eject USB safely**
2. **Reboot without USB** — press F12 or let it boot normally
3. OpenCore picker should appear from **internal SSD** ✅
4. Select **macOS** → boots to desktop

### Final NVRAM Reset
From OpenCore picker → press **Spacebar** → **Reset NVRAM** one last time.

**You're done. The laptop now boots macOS independently from the internal SSD.**

---

## 12. Post-Installation

### Verify Hardware
```bash
# WiFi
system_profiler SPWiFiDataType

# Ethernet
ifconfig en0

# Audio
sudo system_profiler SPAirPortDataType

# Battery
pmset -g batt
```

### Install Development Tools
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install common tools
brew install git python3 node

# Install VS Code
brew install --cask visual-studio-code
```

### Keyboard Reminders (Coming from Windows)
| Action | Windows | macOS |
|--------|---------|-------|
| Copy | Ctrl + C | ⌘ + C |
| Paste | Ctrl + V | ⌘ + V |
| Quit | Alt + F4 | ⌘ + Q |
| Save | Ctrl + S | ⌘ + S |
| Find | Ctrl + F | ⌘ + F |
| Preferences | Alt + , | ⌘ + , |

**Alt key on Dell = Option (⌥) key on Mac**

### Enable Developer Mode
```bash
# Allow apps from anywhere
sudo spctl --master-disable
```

### Show Hidden Files
Press **⌘ + Shift + .** (Command + Shift + Period)

---

## 13. Troubleshooting

### Boot Freeze / Black Screen
1. **Check OpenCore log** — if available on USB (opencore-*.txt in USB root)
2. Try adding boot argument: `-v` (verbose mode) in config.plist
3. **Reset NVRAM** — press Spacebar in OpenCore picker → Reset NVRAM
4. Remove `XhciPortLimit` quirk if boot loops (already removed in this config)

### WiFi Not Showing
1. **Verify BCM94352Z card is installed** (check `system_profiler SPWiFiDataType`)
2. **Reset NVRAM** and reboot
3. **Rebuild kext cache:**
   ```bash
   sudo kextcache -i /
   ```

### Ethernet Not Working
- Verify chip is **RTL8101E** (`10EC:8136`) — not RTL8111
- This repo uses `RealtekRTL8100.kext` — correct for RTL8101E

### Bluetooth Not Working
- Verify BCM94352Z card is properly seated
- Check `BrcmBluetoothInjector.kext` and `BrcmPatchRAM3.kext` are present
- In System Preferences → Bluetooth, check if device appears

### Audio Not Working
- Verify `AppleALC.kext` is injected
- Try different `alcid` values in config.plist (current: `11` for ALC282)
- Reset NVRAM after changing audio layout ID

### USB Ports Not Working
- `USBInjectAll.kext` provides basic USB support for installation
- For full USB mapping, use **USBToolBox** post-install
- `XhciPortLimit` quirk is enabled for basic port support (removable after USB mapping)

### After macOS Update
If boot breaks after a macOS update:
1. Boot from USB with this repo's EFI
2. Mount internal SSD EFI
3. Copy the working EFI over:
   ```bash
   cp -R /Volumes/USB_EFI/EFI /Volumes/SSD_EFI/
   ```

---

## 14. Full EFI Structure

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi            ← OpenCore 1.0.7
    ├── config.plist             ← MacBookAir5,2 SMBIOS
    ├── ACPI/
    │   ├── SSDT-EC-LAPTOP.aml  ← Embedded controller
    │   ├── SSDT-HPET.aml       ← HPET fix
    │   ├── SSDT-PM.aml         ← CPU power management
    │   ├── SSDT-PNLF.aml       ← Backlight control
    │   └── SSDT-XOSI.aml       ← OS fix
    ├── Drivers/
    │   ├── OpenHfsPlus.efi     ← HFS+ support
    │   ├── OpenPartitionDxe.efi
    │   ├── OpenRuntime.efi
    │   ├── Ps2KeyboardDxe.efi
    │   ├── Ps2MouseDxe.efi
    │   └── UsbMouseDxe.efi
    ├── Kexts/
    │   ├── AirportBrcmFixup.kext   ← Broadcom WiFi
    │   ├── AppleALC.kext           ← Audio
    │   ├── BrcmBluetoothInjector.kext ← Broadcom BT
    │   ├── BrcmFirmwareData.kext  ← BCM firmware
    │   ├── BrcmPatchRAM3.kext     ← BT patch
    │   ├── Lilu.kext              ← Core
    │   ├── RealtekRTL8100.kext    ← Ethernet
    │   ├── SMCBatteryManager.kext
    │   ├── SMCDellSensors.kext
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBInjectAll.kext      ← USB injection
    │   ├── VirtualSMC.kext        ← SMC
    │   ├── VoodooPS2Controller.kext ← Keyboard/Mouse
    │   │   ├── VoodooPS2Keyboard.kext
    │   │   ├── VoodooPS2Mouse.kext
    │   │   └── VoodooPS2Trackpad.kext
    │   ├── VoodooRMI.kext         ← Trackpad RMI
    │   │   ├── RMII2C.kext
    │   │   ├── RMISMBus.kext
    │   │   └── VoodooInput.kext
    │   ├── VoodooSMBus.kext
    │   └── WhateverGreen.kext     ← GPU
    └── Tools/
        ├── CleanNvram.efi
        └── OpenShell.efi
```

---

## 15. Maintenance & Updates

### Before Updating macOS
1. **Backup your EFI** — copy `EFI` folder to a safe location
2. Run Time Machine backup
3. Note current OpenCore version

### After Updating macOS
```bash
# Rebuild kext cache if anything breaks
sudo kextcache -i /
```

If boot breaks after update:
1. Boot from USB (with this repo's EFI on USB)
2. Mount internal SSD EFI
3. Copy the working EFI over:
   ```bash
   cp -R /Volumes/USB_EFI/EFI /Volumes/SSD_EFI/
   ```

### Check EFI Partition Health
```bash
diskutil list
# Check EFI partition size — should be ~200MB
# If full, old kernels/logs may be filling it
```

---

## Version Info

| Item | Value |
|------|-------|
| **OpenCore** | 1.0.7 |
| **macOS Version** | Monterey 12.7.x |
| **SMBIOS** | MacBookAir5,2 |
| **Boot Mode** | UEFI only |
| **Build Date** | July 2026 |

---

## Credits & References

- [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/) — The definitive OpenCore reference
- [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) — OpenCore releases
- [macrecovery.py](https://github.com/acidanthera/OpenCorePkg/tree/master/Utilities/macrecovery) — macOS recovery image downloader
- [Dortania](https://dortania.github.io/) — Hackintosh documentation authority
- [Hackintosh Subreddit](https://reddit.com/r/hackintosh) — Community support

---

## Notes

- **BCM94352Z WiFi/BT card is required** for WiFi and Bluetooth on Monterey
- This build does **not** include configured Apple services (iMessage, FaceTime, App Store)
- For research and coding work, this configuration is fully functional and stable
- macOS 12.7.x is the final release of Monterey — recommended for Ivy Bridge systems
