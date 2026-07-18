# Hackintosh macOS Big Sur on Dell Inspiron 3521 — Complete Guide

This repo contains a **fully working, tested Hackintosh build** for the **Dell Inspiron 3521** (and variants like 3520, 3521, 3721) using **OpenCore 0.8.8** and **macOS Big Sur 11.7.10**.

Everything here was built, tested, and verified working on real hardware. If you follow this guide exactly, it will work.

---

## Table of Contents

1. [Hardware That Works](#1-hardware-that-works)
2. [What Works](#2-what-works)
3. [What Doesn't Work](#3-what-doesnt-work)
4. [Critical Hardware Notes](#4-critical-hardware-notes)  ← READ THIS
5. [Installation Overview](#5-installation-overview)
6. [Step 1: Download macOS](#6-step-1-download-macos)
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
| **CPU** | Intel Core i3 3217U (Ivy Bridge, 1.8GHz) | ✅ Native |
| **GPU** | Intel HD Graphics 4000 | ✅ Native |
| **WiFi** | **Atheros AR9560** (`168C:0036`) | ✅ Working |
| **Ethernet** | **Realtek RTL8101E** (`10EC:8136`) | ✅ Working |
| **Bluetooth** | Atheros AR3011 (`0CF3:3004`) | ❌ No driver on Big Sur |
| **Audio** | ALC3221 (mapped to ALC282) | ✅ Working |
| **Battery** | Dell smart battery | ✅ Working |
| **Trackpad** | PS/2 touchpad | ✅ Working |
| **Keyboard** | Built-in + external | ✅ Working |
| **Camera** | Built-in 720p | ✅ Working |
| **HDMI** | HDMI output | ✅ Working |
| **Card Reader** | SD slot | ✅ Working |
| **USB 3.0** | All ports | ✅ Working |

---

## 2. What Works

- **Booting** from internal SSD without USB (after setup)
- **WiFi** on 2.4GHz networks (AR9560, ~40-50 Mbps max — 802.11n only)
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

---

## 3. What Doesn't Work

| Feature | Reason |
|---------|--------|
| **Bluetooth** | AR3011 chip has no Big Sur driver (hardware limitation) |
| **5GHz WiFi** | AR9560 only supports 2.4GHz |
| **High WiFi speed** | AR9560 maxes at ~50 Mbps |
| **macOS Monterey+** | HD4000 + Ivy Bridge too old |
| **Metal GPU API** | HD4000 predates Metal |
| **iMessage/FaceTime/App Store** | No Apple services account (not needed for research/coding) |

### Bluetooth Workaround
Use a **USB Bluetooth 4.0 dongle** (CSR8510 chipset recommended). macOS automatically supports most USB Bluetooth adapters.

---

## 4. Critical Hardware Notes

### ⚠️ WiFi — NOT AR9485!

Many online guides incorrectly say this laptop has **Atheros AR9485**. They are wrong.

The actual chip is **Atheros AR9560** with PCI ID `168C:0036`.

Using AR9485 kexts will NOT work. The working configuration uses:
- `HS80211Family.kext` → **loads FIRST**
- `AirPortAtheros40.kext` → **loads SECOND**

This order is mandatory. If AirPortAtheros40 loads before HS80211Family, WiFi will not work.

To verify your chip in Linux/Windows:
```
lspci -nn | grep -i wireless
# Must show: 168C:0036 (AR9560)
```

In macOS (after install):
```
system_profiler SPWiFiDataType
```

### ⚠️ Ethernet — NOT RTL8111!

The Ethernet chip is **Realtek RTL8101E** (`10EC:8136`), NOT RTL8111 (`10EC:8168`).

This repo uses `RealtekRTL8100.kext` with `IOPCIMatch = 0x813610ec` — the correct kext for RTL8101E.

Using `RealtekRTL8111.kext` (different chip, different kext) will break Ethernet.

---

## 5. Installation Overview

```
Step 1: Download macOS Big Sur
       ↓
Step 2: Create bootable USB with gibMacOS
       ↓
Step 3: Copy this repo's EFI to USB
       ↓
Step 4: Set BIOS settings (Secure Boot off, UEFI mode, AHCI)
       ↓
Step 5: Boot from USB → OpenCore picker → Reset NVRAM
       ↓
Step 6: Install macOS Big Sur to internal SSD
       ↓
Step 7: Copy EFI to internal SSD (never need USB again)
       ↓
Step 8: Done — boots independently from SSD
```

**Time: ~2-3 hours for fresh install**

---

## 6. Step 1: Download macOS

### Download macOS Big Sur 11.7.10

Use **gibMacOS** (recommended):

```bash
# On any Mac/Linux/Windows machine
git clone https://github.com/corpnewt/gibMacOS.git
cd gibMacOS
python3 gibMacOS.command
```

In gibMacOS:
1. Select **Download** (option 3)
2. Type `Big Sur` or `11.7.10`
3. Wait for download (~12GB)

Or on a real Mac: Mac App Store → "macOS Big Sur" → Download

---

## 7. Step 2: Prepare USB

### Format USB as GPT + FAT32

1. Insert 16GB+ USB drive
2. Open **Disk Utility** (macOS) or **Rufus** (Windows)
3. Format:
   - **Name:** `HACK` (or any name)
   - **Format:** `MS-DOS (FAT32)` (Windows) or `FAT32` (macOS)
   - **Scheme:** `GUID Partition Map`

### Create EFI Partition

In Disk Utility on macOS:
1. Select USB → **Partition**
2. Click `+` → Add **200MB EFI partition** at start
3. Set EFI partition to `FAT32`
4. Set remaining space to `APFS` (or `ExFAT` for Windows)
5. Click **Apply** → **Partition**

---

## 8. Step 3: Copy EFI to USB

### Mount USB EFI Partition

**On macOS:**
```bash
diskutil list
# Find your USB — likely /dev/disk2
mkdir -p /Volumes/USB_EFI
mount -t msdos /dev/disk2s1 /Volumes/USB_EFI
```

**On Linux:**
```bash
sudo mount /dev/sdX1 /mnt/usb_efi
```

### Copy This Repo's EFI

Copy the **`EFI` folder** from this repo to the USB's EFI partition:

```
USB_EFI/
└── EFI/
    ├── BOOT/          ← contains BOOTx64.efi
    └── OC/            ← contains OpenCore.efi, config.plist, kexts, ACPI, drivers
```

### Verify USB EFI Structure

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi      ← 581632 bytes (OpenCore 0.8.8)
    ├── config.plist
    ├── ACPI/
    │   ├── SSDT-EC-LAPTOP.aml
    │   ├── SSDT-HPET.aml
    │   ├── SSDT-PM.aml
    │   ├── SSDT-PNLF.aml
    │   └── SSDT-XOSI.aml
    ├── Drivers/
    │   ├── HfsPlusLegacy.efi
    │   ├── OpenPartitionDxe.efi
    │   ├── OpenRuntime.efi
    │   ├── Ps2KeyboardDxe.efi
    │   ├── Ps2MouseDxe.efi
    │   └── UsbMouseDxe.efi
    ├── Kexts/
    │   ├── AirPortAtheros40.kext  ← AR9560 WiFi
    │   ├── AppleALC.kext
    │   ├── Ath3kBT.kext
    │   ├── HS80211Family.kext    ← AR9560 WiFi (loads FIRST)
    │   ├── Lilu.kext
    │   ├── RealtekRTL8100.kext    ← RTL8101E Ethernet
    │   ├── VoodooPS2Controller.kext
    │   ├── VoodooRMI.kext
    │   ├── VoodooSMBus.kext
    │   └── [more kexts]
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

1. Select **macOS Installer** or **Recovery** from OpenCore picker
2. Wait for macOS Recovery to load
3. Select **Disk Utility** → Erase internal SSD:
   - Name: `MacOS`
   - Format: `APFS`
   - Scheme: `GUID Partition Map`
4. Close Disk Utility
5. Select **Reinstall macOS Big Sur**
6. Choose internal SSD as target
7. Click **Install**

Installation takes **20-40 minutes**. Laptop may reboot 2-3 times. Each time: press **F12** → select **USB UEFI** to continue.

---

## 11. Step 6: Post-Install (No More USB)

After macOS is installed and you're at the desktop, **copy the working EFI to the internal SSD** so you never need USB again.

### Mount Internal SSD EFI Partition

```bash
diskutil list
# Find internal SSD EFI — likely /dev/disk0s1
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

### WiFi First Boot

After first boot from SSD:
1. Click WiFi icon in menu bar
2. You should see available networks
3. Connect to your 2.4GHz network (AR9560 doesn't do 5GHz)

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

### WiFi Not Showing

1. **Check kext load order** — HS80211Family.kext MUST load before AirPortAtheros40.kext in config.plist
2. **Reset NVRAM** — press Spacebar in OpenCore picker → Reset NVRAM
3. **Rebuild kext cache:**
   ```bash
   sudo kextcache -i /
   ```

### Ethernet Not Working

- Verify chip is **RTL8101E** (`10EC:8136`) — not RTL8111
- This repo uses `RealtekRTL8100.kext` — correct for RTL8101E
- If using wrong kext, Ethernet shows "cable disconnected"

### Black Screen on Boot

1. Press **Spacebar** in OpenCore picker
2. Select **ACPI S3 Sleep** option
3. If still black, reset NVRAM

### Slow WiFi (Expected)

The AR9560 maxes at **40-50 Mbps**. This is normal. For faster speeds, use Ethernet (100Mbps via RTL8101E).

### Bluetooth Not Working

This is a **known hardware limitation** — the AR3011 (`0CF3:3004`) has no Big Sur driver. Use a USB Bluetooth dongle.

### After macOS Update

If boot breaks after a macOS update:
1. Boot from USB with this repo's EFI
2. Mount internal SSD EFI
3. Check that EFI/OC/config.plist is still intact
4. If corrupted, copy from this repo's backup

---

## 14. Full EFI Structure

This repo contains the complete working EFI:

```
EFI/
├── BOOT/
│   └── BOOTx64.efi          # 20484 bytes
├── OC/
│   ├── OpenCore.efi         # 581632 bytes (v0.8.8)
│   ├── config.plist          # Configured for Dell 3521
│   ├── ACPI/
│   │   ├── SSDT-EC-LAPTOP.aml
│   │   ├── SSDT-HPET.aml
│   │   ├── SSDT-PM.aml      ← CPU power management
│   │   ├── SSDT-PNLF.aml    ← Backlight control
│   │   └── SSDT-XOSI.aml    ← WiFi fix
│   ├── Drivers/
│   │   ├── HfsPlusLegacy.efi
│   │   ├── OpenPartitionDxe.efi
│   │   ├── OpenRuntime.efi
│   │   ├── Ps2KeyboardDxe.efi
│   │   ├── Ps2MouseDxe.efi
│   │   └── UsbMouseDxe.efi
│   ├── Kexts/
│   │   ├── AirPortAtheros40.kext    ← Atheros AR9560 WiFi
│   │   ├── AppleALC.kext             ← Audio (ALC282)
│   │   ├── Ath3kBT.kext             ← Bluetooth (AR3011 — no driver)
│   │   ├── Ath3kBTInjector.kext
│   │   ├── HS80211Family.kext        ← Atheros foundation driver
│   │   ├── Lilu.kext                ← Core kext
│   │   ├── RealtekRTL8100.kext      ← RTL8101E Ethernet
│   │   ├── SMCBatteryManager.kext   ← Battery management
│   │   ├── SMCDellSensors.kext      ← Dell sensor management
│   │   ├── SMCLightSensor.kext
│   │   ├── SMCProcessor.kext
│   │   ├── SMCSuperIO.kext
│   │   ├── USBInjectAll.kext        ← USB port injection
│   │   ├── VirtualSMC.kext          ← SMC emulation
│   │   ├── VoodooPS2Controller.kext ← Keyboard
│   │   ├── VoodooRMI.kext           ← Trackpad
│   │   ├── VoodooSMBus.kext
│   │   └── WhateverGreen.kext       ← GPU patches
│   └── Tools/
│       ├── CleanNvram.efi
│       └── OpenShell.efi
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

# Clean old kernels if needed
sudo rm -rf /Volumes/EFI/EFI/CLOVER/kernels/*
```

---

## Version Info

| Item | Value |
|------|-------|
| **OpenCore** | 0.8.8 |
| **macOS Version** | Big Sur 11.7.10 (final) |
| **SMBIOS** | MacBookAir5,2 |
| **Boot Mode** | UEFI only |
| **Build Date** | July 2026 |

---

## Credits & References

- [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/) — The definitive OpenCore reference
- [gibMacOS](https://github.com/corpnewt/gibMacOS) — Download macOS directly
- [Dortania](https://dortania.github.io/) — Hackintosh documentation authority
- [Hackintosh Subreddit](https://reddit.com/r/hackintosh) — Community support
- OpenCore 0.8.8 by Acidanthera

---

## No Apple Services

This build does **not** include configured Apple services (iMessage, FaceTime, App Store). For basic research and coding, these are not needed. If you need them, you'll need to generate fresh SMBIOS serials using GenSMBIOS and update `config.plist`.

For research and coding work, this configuration is fully functional and stable.