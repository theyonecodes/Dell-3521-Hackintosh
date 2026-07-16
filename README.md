# Hackintosh macOS Big Sur on Dell Inspiron 3521 — Complete Guide

This document details the **exact process** that successfully installed macOS Big Sur 11.7.10 on a Dell Inspiron 3521 using OpenCore. Everything here was tested and verified to work.

---

## Table of Contents
1. [Hardware Specifications](#1-hardware-specifications)
2. [What You Need](#2-what-you-need)
3. [Why It Works — Critical Fixes](#3-why-it-works--critical-fixes)
4. [Step-by-Step Installation](#4-step-by-step-installation)
5. [ESP Folder Structure](#5-esp-folder-structure)
6. [PlatformInfo](#6-platforminfo)
7. [Known Issues & Workarounds](#7-known-issues--workarounds)
8. [Post-Install](#8-post-install)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Hardware Specifications

| Component | Model |
|-----------|-------|
| Laptop | Dell Inspiron 3521 |
| CPU | Intel Core i5-3337U (Ivy Bridge, 3rd Gen) |
| EFI Firmware | IA32 (32-bit) — **NOT x86_64** |
| Graphics | Intel HD Graphics 4000 |
| Audio | Realtek ALC282 |
| WiFi | Qualcomm Atheros AR9485 |
| USB | Kingston DataTraveler 16GB |

### Critical Hardware Detail
> **The Dell 3521 uses a 32-bit (IA32) EFI.**
> This means `BOOTx64.EFI` / `OpenCore.efi` will NOT work.
> You MUST use `BOOTIA32.EFI`.

---

## 2. What You Need

| Item | Details |
|------|---------|
| OpenCore | **1.0.5-RELEASE** — download the IA32 build from GitHub |
| macOS Recovery | Big Sur 11.7.10 `BaseSystem.dmg` (637 MB) |
| USB Drive | Any FAT32-formatted USB (16GB+ recommended) |
| Tools | `gibMacOS` (to download recovery), `ProperTree` (to edit config.plist) |
| Config.plist | Use the **Ivy Bridge** template from Dortania's guide |

---

## 3. Why It Works — Critical Fixes

These are the **non-negotiable** config.plist changes that made it boot. Skipping any one of these will cause boot loops or kernel panics.

### 3.1 Ivy Bridge CPU Power Management
```xml
<key>Kernel</key>
<dict>
    <key>Quirks</key>
    <dict>
        <key>AppleCpuPmCfgLock</key>
        <true/>
        <key>DummyPowerManagement</key>
        <true/>
    </dict>
</dict>
```
**Why:** Ivy Bridge laptops have locked MSR 0xE2 registers. `AppleCpuPmCfgLock` allows macOS to manage the CPU without needing to unlock BIOS. `DummyPowerManagement` prevents kernel panics from AppleIntelCPUPowerManagement on locked firmware.

### 3.2 IgnoreInvalidFlexRatio
```xml
<key>UEFI</key>
<dict>
    <key>Quirks</key>
    <dict>
        <key>IgnoreInvalidFlexRatio</key>
        <true/>
    </dict>
</dict>
```
**Why:** Fixes a BIOS bug on some Ivy Bridge boards where the flex ratio register contains invalid values, causing early boot failures.

### 3.3 ACPI — Remove CPU Power Tables
```xml
<key>ACPI</key>
<dict>
    <key>Delete</key>
    <array>
        <dict>
            <key>TableSignature</key>
            <data>
                Q1BQVA==
            </data>
        </dict>
        <dict>
            <key>TableSignature</key>
            <data>
                Q3B1MEk=
            </data>
        </dict>
    </array>
</dict>
```
**Why:** Removes `CpuPm` and `Cpu0Ist` ACPI tables that conflict with macOS power management on Ivy Bridge.

### 3.4 DeviceProperties — HD 4000 Graphics + IMEI Spoof
```xml
<key>DeviceProperties</key>
<dict>
    <key>Add</key>
    <dict>
        <key>PciRoot(0x0)/Pci(0x2,0x0)</key>
        <dict>
            <key>AAPL,ig-platform-id</key>
            <data>
                BwAAEA==
            </data>
            <key>device-id</key>
            <data>
                RBAQAA==
            </data>
            <key>framebuffer-patch-enable</key>
            <data>
                AQAAAA==
            </data>
        </dict>
        <key>PciRoot(0x0)/Pci(0x1F,0x3)</key>
        <dict>
            <key>device-id</key>
            <data>
                CgQAAA==
            </data>
        </dict>
    </dict>
</dict>
```
**Why:**
- `AAPL,ig-platform-id` `0x03006601` → enables HD 4000 with correct framebuffer
- `device-id` `0x01660000` → spoofs HD 4000 device ID for compatibility
- `framebuffer-patch-enable` → activates framebuffer patching
- IMEI `device-id` spoof → prevents "Missing Platform EFI" errors

### 3.5 SecureBootModel
```xml
<key>Misc</key>
<dict>
    <key>Security</key>
    <dict>
        <key>SecureBootModel</key>
        <string>Disabled</string>
    </dict>
</dict>
```
**Why:** Disables Apple Secure Boot to allow booting unsigned recovery images and older macOS versions.

### 3.6 USB Port Limit
```xml
<key>Kernel</key>
<dict>
    <key>Quirks</key>
    <dict>
        <key>XhciPortLimit</key>
        <true/>
    </dict>
</dict>
```
**Why:** Temporarily lifts the 15 USB port limit during installation. **Remove after install** and use a proper USB port map instead.

### 3.7 Additional Kernel Quirks
```xml
<key>Kernel</key>
<dict>
    <key>Quirks</key>
    <dict>
        <key>DisableIoMapper</key>
        <true/>
        <key>PanicNoKextDump</key>
        <true/>
        <key>PowerTimeoutKernelPanic</key>
        <true/>
    </dict>
</dict>
```
**Why:**
- `DisableIoMapper` → disables VT-d which conflicts with macOS
- `PanicNoKextDump` → prevents kext dump on kernel panic (shows useful error instead)
- `PowerTimeoutKernelPanic` → prevents panics from power timeout issues

---

## 4. Step-by-Step Installation

### 4.1 Prepare the USB on Windows

1. **Format USB** as FAT32 (MBR or GPT — both work, GPT recommended)
2. **Create folder structure:**
   ```
   F:\
   ├── EFI\
   │   ├── BOOT\
   │   │   └── BOOTIA32.EFI        ← OpenCore.efi renamed (32-bit!)
   │   └── OC\
   │       ├── ACPI\                ← SSDTs (EC, HPET, etc.)
   │       ├── Drivers\
   │       │   ├── HfsPlus.efi
   │       │   ├── OpenCanopy.efi
   │       │   ├── OpenRuntime.efi
   │       │   ├── OpenShell.efi
   │       │   └── ResetNvramEntry.efi
   │       ├── Kexts\
   │       │   ├── AppleALC.kext
   │       │   ├── IntelMausi.kext
   │       │   ├── Lilu.kext
   │       │   ├── NVMeFix.kext (if using NVMe)
   │       │   ├── USBMap.kext or USBPorts.kext
   │       │   ├── VirtualSMC.kext
   │       │   └── WhateverGreen.kext
   │       ├── Resources\           ← Audio, Font, Image, Label
   │       ├── Tools\
   │       │   └── OpenShell.efi
   │       └── config.plist         ← THE CRITICAL FILE
   └── com.apple.recovery.boot\
       └── BaseSystem.dmg          ← macOS recovery image
   ```

3. **Copy `OpenCore.efi` → `F:\EFI\BOOT\BOOTIA32.EFI`**
   - This is the step most people miss on 32-bit EFI machines
   - The file is identical, just renamed

4. **Copy `BaseSystem.dmg`** to `F:\com.apple.recovery.boot\`

5. **Copy all kexts, drivers, ACPI files, and config.plist** to their respective folders

### 4.2 Get Your USB's GUID (On Hardware)

1. Boot from USB → OpenCore picker → select **EFI Shell**
2. Run:
   ```
   map -r
   ```
3. Find your USB (usually `FS0:`) and note the GUID:
   ```
   FS0:\EFI\BOOT> map -r
   ```
4. Look for the USB partition GUID in the output, e.g.:
   ```
   EE8AA418-5CCC-4AB0-8688AA4C1A34FDE6
   ```

### 4.3 Update config.plist DevicePath

Edit `Misc → Entries` and set the DevicePath to:
```xml
<string>PciRoot(0x0)/Pci(0x1D,0x0)/USB(0x0,0x0)/USB(0x3,0x0)/HD(1,GPT,YOUR-GUID-HERE)</string>
```

### 4.4 Boot & Install

1. Boot from USB → OpenCore picker appears
2. Select **"macOS Recovery"** (or "macOS (external)")
3. In Recovery, open **Disk Utility** → erase target disk as **Mac OS Extended (Journaled)** or **APFS**
4. Close Disk Utility → select **"Reinstall macOS"**
5. Let it install — it will reboot multiple times
6. **On each reboot**, select the **"macOS Installer"** entry in the OpenCore picker
7. After final reboot → macOS Setup Assistant appears

---

## 5. ESP Folder Structure

```
USB (F:\)
├── EFI/
│   ├── BOOT/
│   │   └── BOOTIA32.EFI          ← 32-bit OpenCore
│   └── OC/
│       ├── ACPI/
│       │   ├── SSDT-EC.aml
│       │   ├── SSDT-HPET.aml
│       │   └── ... (other SSDTs)
│       ├── Drivers/
│       │   ├── HfsPlus.efi
│       │   ├── OpenCanopy.efi
│       │   ├── OpenRuntime.efi
│       │   ├── OpenShell.efi
│       │   └── ResetNvramEntry.efi
│       ├── Kexts/
│       │   ├── AppleALC.kext/
│       │   ├── IntelMausi.kext/
│       │   ├── Lilu.kext/
│       │   ├── USBMap.kext/ (or USBPorts.kext)
│       │   ├── VirtualSMC.kext/
│       │   └── WhateverGreen.kext/
│       ├── Resources/
│       │   ├── Audio/
│       │   ├── Font/
│       │   ├── Image/
│       │   └── Label/
│       ├── Tools/
│       │   └── OpenShell.efi
│       └── config.plist
└── com.apple.recovery.boot/
    └── BaseSystem.dmg
```

---

## 6. PlatformInfo

```xml
<key>PlatformInfo</key>
<dict>
    <key>Generic</key>
    <dict>
        <key>MLB</key>
        <string>C02413600GUFD47AD</string>
        <key>SystemSerialNumber</key>
        <string>C02MH5Y2F5V7</string>
        <key>SystemUUID</key>
        <string>F7301094-8AC7-43E0-9B57-6C9D8BCC8A38</string>
        <key>SystemProductName</key>
        <string>MacBookAir6,2</string>
    </dict>
</dict>
```

**Why MacBookAir6,2:** This is the closest match to the i5-3337U (Ivy Bridge) with HD 4000 graphics. It has the correct framebuffer and power management profiles.

> **IMPORTANT:** These are example serials. Generate your own using GenSMBIOS to avoid iCloud conflicts with other Hackintosh users.

---

## 7. Known Issues & Workarounds

### 7.1 OpenCanopy GUI Not Rendering
- **Problem:** PickerMode=Auto does not show the GUI picker despite OpenCanopy.efi being loaded
- **Workaround:** Use CLI picker (it works fine, just less pretty)
- **Possible cause:** IA32 compatibility issue with OpenCanopy rendering

### 7.2 USB Must Be GPT
- The Dell 3521's IA32 EFI reads GPT USBs better than MBR
- Use `diskpart` or Rufus to create GPT FAT32

### 7.3 Recovery vs Install Media
- We used the **recovery method** (BaseSystem.dmg) not a full macOS installer
- Recovery is simpler and works well for first-time installs

---

## 8. Post-Install

### 8.1 Copy EFI to Internal Disk
Once macOS is installed and working:
1. Mount the internal disk's EFI partition:
   ```bash
   sudo diskutil mount /dev/disk0s1
   ```
2. Copy the entire `EFI` folder from USB to the internal EFI partition
3. **Make sure `BOOTIA32.EFI` is in the right place** — the internal disk also needs the 32-bit bootloader

### 8.2 Remove XhciPortLimit
After USB mapping is done:
```xml
<key>XhciPortLimit</key>
<false/>
```

### 8.3 USB Port Mapping
Create a proper USBMap.kext or USBPorts.kext for your specific port layout. The Dell 3521 typically has:
- 2x USB 3.0 (rear)
- 1x USB 2.0 (right side)
- 1x USB 2.0 (internal, for webcam)

### 8.4 WiFi
The AR9485 may need:
- `AirportItlwm.kext` (for Big Sur) or
- `itlwm.kext` + `HeliPort.app` (alternative)

### 8.5 Audio
ALC282 should work with `alcid=3` boot arg. If not, try other values:
- `alcid=1`, `alcid=2`, `alcid=3`, `alcid=13`, `alcid=27`

---

## 9. Troubleshooting

### Boot Loop (Returns to Picker)
- **Cause:** OpenCore can't find or load the boot volume
- **Fixes:**
  - Verify `SecureBootModel = Disabled`
  - Verify `DmgLoading = Signed` or `Any`
  - Check USB GUID in DevicePath matches `map -r` output
  - Ensure `BOOTIA32.EFI` exists in `EFI\BOOT\`

### Kernel Panic on Boot
- **Cause:** Missing kext, wrong config, or incompatible hardware
- **Fixes:**
  - Boot with `-v debug=0x100 keepsyms=1` to see verbose output
  - Check all kexts are present and compatible with your OpenCore version
  - Verify `AppleCpuPmCfgLock = true` and `DummyPowerManagement = true`

### Black Screen After Boot
- **Cause:** Incorrect ig-platform-id or missing WhateverGreen
- **Fixes:**
  - Verify `AAPL,ig-platform-id` is `0x03006601` (base64: `BwAAEA==`)
  - Ensure `WhateverGreen.kext` is loaded
  - Try different boot args: `igfxonln=1`, `-igfxnohdmi`

### No WiFi
- **Cause:** AR9485 needs specific kext
- **Fix:** Use `itlwm.kext` or `AirportItlwm.kext` for your macOS version

---

## Appendix: File Checksums (Verification)

After copying files to USB, verify these critical files exist:

```bash
# On macOS/Linux, verify:
ls -la /Volumes/EFI/EFI/BOOT/BOOTIA32.EFI
ls -la /Volumes/EFI/EFI/OC/config.plist
ls -la /Volumes/EFI/com.apple.recovery.boot/BaseSystem.dmg
```

---

## Appendix: BIOS Settings

Ensure these BIOS settings on the Dell 3521:

| Setting | Value |
|---------|-------|
| SATA Mode | AHCI (NOT RAID/IDE) |
| Secure Boot | Disabled |
| UEFI Boot | Enabled |
| Legacy Boot | Disabled (or set USB first) |
| VT-d | Disabled (if available) |

---

*Last updated: July 2026*
*Tested on: Dell Inspiron 3521, i5-3337U, OpenCore 1.0.5, macOS Big Sur 11.7.10*
