# Hackintosh macOS Big Sur on Dell Inspiron 3521 — Complete Guide

This document details the **exact process** that successfully installed macOS Big Sur 11.7.10 on a Dell Inspiron 3521 using OpenCore. Everything here was tested and verified to work.

---

## Table of Contents
1. [⚠️ Mistakes to Avoid (Read First!)](#️-mistakes-to-avoid-read-first)
2. [Hardware Specifications](#1-hardware-specifications)
3. [Download These Folders to Your Desktop](#2-download-these-folders-to-your-desktop)
4. [What Each Folder Does](#3-what-each-folder-does)
5. [BIOS Settings (Do This First)](#4-bios-settings-do-this-first)
6. [Step 1: Format the USB Drive](#5-step-1-format-the-usb-drive)
7. [Step 2: Download macOS Recovery](#6-step-2-download-macos-recovery)
8. [Step 3: Download & Extract OpenCore](#7-step-3-download--extract-opencore)
9. [Step 4: Build the EFI Folder](#8-step-4-build-the-efi-folder)
10. [Step 5: Edit config.plist](#9-step-5-edit-configplist)
11. [Step 6: Copy Everything to USB](#10-step-6-copy-everything-to-usb)
12. [Step 7: Boot & Install macOS](#11-step-7-boot--install-macos)
13. [Step 8: Post-Install (Copy EFI to Internal Disk)](#12-step-8-post-install-copy-efi-to-internal-disk)
14. [ESP Folder Structure](#13-esp-folder-structure)
15. [PlatformInfo](#14-platforminfo)
16. [Known Issues & Workarounds](#15-known-issues--workarounds)
17. [Troubleshooting](#16-troubleshooting)
18. [FAQ](#17-faq)
19. [Tools & Resources](#18-tools--resources)

---

## 1. Hardware Specifications

| Component | Model |
|-----------|-------|
| Laptop | Dell Inspiron 3521 |
| CPU | Intel Core i5-3337U (Ivy Bridge, 3rd Gen) |
| EFI Firmware | IA32 (32-bit) — **NOT x86_64** |
| Graphics | Intel HD Graphics 4000 |
| Audio | Realtek ALC282 |
| WiFi | **Atheros AR9485** (Qualcomm, `168C-0036`) — no native macOS support |
| USB | Kingston DataTraveler 16GB |

### Critical Hardware Detail
> **The Dell 3521 uses a 32-bit (IA32) EFI.**
> This means `BOOTx64.EFI` / `OpenCore.efi` will NOT work.
> You MUST use `BOOTIA32.EFI`.

---

## 2. Download These Folders to Your Desktop

Before starting, download **all of these** to your Desktop. You need every single one:

| # | Folder/File | What It Is | Where to Get It |
|---|-------------|------------|-----------------|
| 1 | `gibMacOS-master/` | Downloads macOS Recovery from Apple | [GitHub](https://github.com/corpnewt/gibMacOS) — click Code → Download ZIP |
| 2 | `OpenCorePkg-master/` | The OpenCore bootloader (IA32 build) | [GitHub](https://github.com/acidanthera/OpenCorePkg/releases) — download `OpenCore-1.0.5-RELEASE.zip` |
| 3 | `ProperTree-master/` | Edits config.plist files correctly | [GitHub](https://github.com/corpnewt/ProperTree) — click Code → Download ZIP |
| 4 | `MacOS/` (or `macOS_Recovery/`) | Where gibMacOS saves downloaded recovery files | Created automatically when you run gibMacOS |
| 5 | `EFI/` | Your final OpenCore EFI folder (built in Step 4) | You build this yourself using files from folders 1-4 |
| 6 | `com.apple.recovery.boot/` | Contains BaseSystem.dmg (~637 MB) | Created automatically when you run gibMacOS |

### Your Desktop Should Look Like This:
```
Desktop/
├── gibMacOS-master/          ← Download tool (has MakeInstall.bat inside)
├── OpenCorePkg-master/       ← Bootloader files (has IA32/ folder inside)
├── ProperTree-master/        ← Config editor (has ProperTree.bat inside)
├── MacOS/                    ← Created by gibMacOS (recovery files land here)
│   ├── EFI/                  ← Your built EFI folder goes here
│   └── com.apple.recovery.boot/
│       ├── BaseSystem.dmg
│       └── BaseSystem.chunklist
└── Dell-3521-Hackintosh/     ← This repo (the guide you're reading)
```

---

## 3. What Each Folder Does

### `gibMacOS-master/` — The Recovery Downloader
- **What it does:** Downloads macOS Recovery files directly from Apple's servers
- **Key files inside:**
  - `MakeInstall.bat` — **THE MAIN TOOL** — creates the USB installer (formats + copies files)
  - `gibMacOS.bat` — Downloads recovery files only (no USB creation)
- **What you'll do with it:** Run `MakeInstall.bat` to format your USB and copy everything in one step

### `OpenCorePkg-master/` — The Bootloader
- **What it does:** Contains the OpenCore bootloader that makes macOS think it's running on a real Mac
- **Key files inside:**
  - `X64/` — 64-bit build (DON'T USE THIS)
  - `IA32/` — 32-bit build (**USE THIS ONE** — Dell 3521 needs 32-bit)
  - `IA32/EFI/BOOT/BOOTIA32.EFI` — The actual bootloader file
  - `IA32/EFI/OC/OpenCore.efi` — OpenCore core
  - `IA32/EFI/OC/Drivers/` — Required driver files (HfsPlus.efi, OpenRuntime.efi, etc.)
  - `IA32/EFI/OC/Kexts/` — Kernel extensions ( Lilu.kext, VirtualSMC.kext, etc.)
  - `IA32/EFI/OC/ACPI/` — ACPI tables (SSDTs)
  - `IA32/EFI/OC/config.plist` — The configuration file you'll edit
  - `Utilities/ocvalidate/ocvalidate.exe` — Validates your config.plist

### `ProperTree-master/` — The Config Editor
- **What it does:** Opens and edits `.plist` files (XML config files) correctly without breaking them
- **Key files inside:**
  - `ProperTree.bat` — **Double-click this to open ProperTree on Windows**
  - `ProperTree.py` — The actual Python script (runs when you double-click .bat)
- **What you'll do with it:** Open `config.plist` in it, make changes, save

### `MacOS/` — Where Recovery Files Land
- **What it does:** This folder is created by gibMacOS. It's where all your downloaded and built files end up
- **Key files inside after running gibMacOS:**
  - `EFI/` — The OpenCore EFI folder (copy this to USB)
  - `com.apple.recovery.boot/` — Contains BaseSystem.dmg (copy this to USB)

### `com.apple.recovery.boot/` — The macOS Recovery Image
- **What it does:** Contains the actual macOS installer that Apple's servers provide
- **Key files inside:**
  - `BaseSystem.dmg` (~637 MB) — The recovery image (this IS macOS)
  - `BaseSystem.chunklist` — Integrity check file (small, always comes with .dmg)
- **What you'll do with it:** Copy the entire folder to your USB drive

---

## 4. BIOS Settings (Do This First)

Before touching any tools, configure the Dell 3521's BIOS:

1. **Shut down** the laptop completely
2. **Power on** and immediately press **F2** repeatedly (before Windows loads)
3. You're now in BIOS Setup. Navigate and change these settings:

### Required BIOS Changes:

| Setting | Where to Find It | What to Set It To |
|---------|-------------------|-------------------|
| **SATA Operation** | System Configuration → SATA Operation | **AHCI** (NOT RAID or IDE) |
| **Secure Boot** | Security → Secure Boot | **Disabled** |
| **Boot Mode** | Boot Sequence → Boot List Option | **UEFI** |
| **Legacy Boot** | Boot Sequence → Boot List Option | **Uncheck/Disable** |
| **VT-d** | Advanced (if available) | **Disabled** |

### How to Change Each Setting:

**SATA Operation (Most Important!):**
1. BIOS → System Configuration → SATA Operation
2. Change from "RAID On" to "AHCI"
3. A warning will appear — click "Yes" to confirm
4. **NOTE:** If Windows is installed in RAID mode, it may not boot after this change. You'll need to reinstall Windows or repair it. This is expected.

**Secure Boot:**
1. BIOS → Security → Secure Boot
2. Uncheck "Secure Boot Enable" or set to "Disabled"

**Boot Mode:**
1. BIOS → Boot Sequence → Boot List Option
2. Select "UEFI" (uncheck "Legacy" if both are checked)

4. **Press F10** to save and exit
5. Laptop will restart

---

## 5. Step 1: Format the USB Drive

You have **two options** — pick whichever is easier for you:

### Option A: Use MakeInstall.bat (RECOMMENDED — Does Everything Automatically)

This is the easiest method. It formats the USB AND copies all files in one step.

1. **Plug in your USB drive** (16GB or larger)
2. **Open File Explorer** → navigate to `Desktop\gibMacOS-master\`
3. **Double-click `MakeInstall.bat`**
4. **A command prompt window opens** — it will ask you to select your USB drive
5. **Type the number** next to your USB drive and press Enter
6. **Wait** — the script will:
   - Format the USB as MBR + FAT32
   - Create the EFI partition
   - Copy OpenCore boot files
   - Copy recovery files
7. **When it says "Done"**, press any key to close the window
8. **Your USB is ready** — skip to Step 7 (Boot & Install macOS)

### Option B: Use diskpart Manually (More Control)

If Option A doesn't work or you want more control:

1. **Open diskpart:**
   - Press `Win + R` on your keyboard
   - Type `diskpart` and press Enter
   - Click "Yes" if Windows asks for permission
   - A black command prompt window opens with `DISKPART>` prompt

2. **Find your USB drive:**
   ```
   DISKPART> list disk
   ```
   This shows all disks. Look for your USB in the "Size" column. Note the disk number (e.g., Disk 2).

3. **Select your USB** (replace `2` with your disk number):
   ```
   DISKPART> select disk 2
   ```

4. **Erase everything on the USB:**
   ```
   DISKPART> clean
   ```

5. **Convert to GPT partition table:**
   ```
   DISKPART> convert gpt
   ```

6. **Create a FAT32 partition:**
   ```
   DISKPART> create partition primary
   DISKPART> format fs=fat32 quick label="OPENCORE"
   DISKPART> assign letter=F
   ```

7. **Exit diskpart:**
   ```
   DISKPART> exit
   ```

8. **Your USB is now formatted.** Now you need to copy files to it (see Step 6).

> **WARNING:** `clean` destroys ALL data on the selected disk. Double-check the disk number before running it. If you select the wrong disk (like your main hard drive), you'll lose all your data.

---

## 6. Step 2: Download macOS Recovery

This step downloads the macOS Recovery image from Apple's servers.

1. **Open File Explorer** → navigate to `Desktop\gibMacOS-master\`
2. **Double-click `gibMacOS.bat`**
3. **A command prompt window opens** with a menu like this:
   ```
   [1] Download macOS Recovery
   [2] Make Install (USB)
   [3] Exit
   ```
4. **Type `1` and press Enter** — this starts the download process
5. **It will ask you to select a macOS version** — choose Big Sur (11.7.10 if available, or latest Big Sur)
6. **Wait for the download** — it will download `BaseSystem.dmg` (~637 MB) and `BaseSystem.chunklist`
7. **When it says "Done"**, the files are saved to `Desktop\MacOS\com.apple.recovery.boot\`

### Where Are the Downloaded Files?
After running gibMacOS, check this folder:
```
Desktop\MacOS\com.apple.recovery.boot\
├── BaseSystem.dmg        (~637 MB — this is macOS)
└── BaseSystem.chunklist  (small integrity file)
```

---

## 7. Step 3: Download & Extract OpenCore

1. **Download OpenCore 1.0.5 IA32:**
   - Go to: https://github.com/acidanthera/OpenCorePkg/releases
   - Download `OpenCore-1.0.5-RELEASE.zip`
   - Extract the ZIP file to your Desktop
   - You'll get a folder called `OpenCore-1.0.5-RELEASE`

2. **Find the IA32 folder:**
   - Open `OpenCore-1.0.5-RELEASE\`
   - Look for the `IA32\` folder (NOT `X64\`)
   - This is the 32-bit version your Dell 3521 needs

3. **Copy these files from IA32 to your working folder:**
   - Copy the entire `IA32\EFI` folder to `Desktop\MacOS\EFI`
   - Copy `IA32\Utilities\ocvalidate\ocvalidate.exe` somewhere accessible (you'll need it later)

### What You Should Have Now:
```
Desktop\MacOS\
├── EFI\                        ← From OpenCore IA32
│   ├── BOOT\
│   │   └── BOOTIA32.EFI       ← The bootloader (ALREADY INCLUDED — don't rename anything!)
│   └── OC\
│       ├── ACPI\               ← SSDTs (already included)
│       ├── Drivers\            ← HfsPlus.efi, OpenRuntime.efi, etc. (already included)
│       ├── Kexts\              ← Lilu.kext, VirtualSMC.kext, etc. (already included)
│       ├── Resources\          ← Audio, Font, Image, Label (already included)
│       ├── Tools\              ← OpenShell.efi (already included)
│       └── config.plist        ← THE FILE YOU'LL EDIT
└── com.apple.recovery.boot\
    ├── BaseSystem.dmg
    └── BaseSystem.chunklist
```

---

## 8. Step 4: Build the EFI Folder

Now you need to add the missing files to your EFI folder. Here's exactly what to do:

### 4.1 Copy SSDTs to ACPI Folder
The SSDTs (Secondary System Description Tables) are pre-compiled `.aml` files that patch your Dell's ACPI tables for macOS.

**Where to get them:** The SSDTs are already included in the OpenCore IA32 download under `EFI\OC\ACPI\`. Check if these files exist:
- `SSDT-EC.aml` — Embedded Controller
- `SSDT-HPET.aml` — High Precision Event Timer
- `SSDT-PLUG.aml` — CPU Power Management
- `SSDT-PNLF.aml` — Laptop backlight control

If any are missing, download them from [Dortania's ACPI guide](https://dortania.github.io/OpenCore-Install-Guide/acer.html).

### 4.2 Download Missing Drivers
Some drivers are NOT included in the standard OpenCore download. You need to download them separately:

**Download `apfs_aligned.efi`:**
- This driver lets OpenCore read APFS partitions (macOS uses APFS)
- Download from: https://github.com/acidanthera/OcBinaryData/blob/master/Drivers/apfs_aligned.efi
- Save it to `EFI\OC\Drivers\`

**Check these drivers exist in `EFI\OC\Drivers\`:**
- `HfsPlus.efi` — reads HFS+ partitions (included in OpenCore)
- `OpenRuntime.efi` — runtime services (included in OpenCore)
- `OpenCanopy.efi` — GUI picker (included in OpenCore)
- `apfs_aligned.efi` — reads APFS partitions (**NOT included** — download this!)

### 4.3 Check Kexts
Kexts are macOS kernel extensions. Check these exist in `EFI\OC\Kexts\`:
- `Lilu.kext` — patches macOS on the fly (ALWAYS needed)
- `VirtualSMC.kext` — emulates Apple's SMC chip (ALWAYS needed)
- `WhateverGreen.kext` — graphics patches (for HD 4000)
- `AppleALC.kext` — audio patches (for ALC282)
- `AirportItlwm.kext` — Intel WiFi (Big Sur version)
- `RealtekRTL8100.kext` — Ethernet
- `UTBMap.kext` — USB port mapping
- `VoodooPS2Controller.kext` — keyboard/trackpad
- `VoodooRMI.kext` — trackpad (I2C)
- `BrcmPatchRAM3.kext` + `BrcmFirmwareData.kext` + `BrcmBluetoothInjector.kext` — Bluetooth
- `BrightnessKeys.kext` — brightness hotkeys
- `SMCBatteryManager.kext` — battery status
- `ECEnabler.kext` — embedded controller battery fix

### 4.4 WiFi & Bluetooth
> **⚠️ IMPORTANT:** The Dell 3521 ships with an **Atheros AR9485** (`168C-0036`), NOT Intel WiFi. AirportItlwm.kext and itlwm.kext are Intel-only and will never work with this card. There are no native macOS kexts for Atheros on Big Sur.

**WiFi solution:** Use a **USB WiFi dongle** (any adapter supported by macOS via realtek drivers or a native chipset like MediaTek). See [USB WiFi Setup](#usb-wifi-setup) below.

`AirportItlwm.kext` is kept in the EFI folder in case you later swap the card for an Intel one.

Bluetooth uses `BrcmPatchRAM3.kext` + `BrcmFirmwareData.kext` + `BrcmBluetoothInjector.kext` (already included).

---

## 9. Step 5: Edit config.plist

This is the most important step. You need to edit `config.plist` with specific values for the Dell 3521.

### 5.1 Open ProperTree
1. **Open File Explorer** → navigate to `Desktop\ProperTree-master\`
2. **Double-click `ProperTree.bat`**
3. **A black window opens** — this is ProperTree (a plist editor)
4. **Press `Ctrl + O`** (or File → Open)
5. **Navigate to** `Desktop\MacOS\EFI\OC\config.plist`
6. **Select it** and click "Open"

### 5.2 Run OC Clean Snapshot
Before editing, you need to clean the config.plist and add all your kexts/drivers:

1. **In ProperTree**, press `Ctrl + Shift + R` (or File → OC Clean Snapshot)
2. **A file dialog opens** — navigate to `Desktop\MacOS\EFI\OC\config.plist`
3. **Select it** and click "Open"
4. **This automatically:**
   - Removes outdated entries
   - Adds all kexts from the Kexts folder
   - Adds all drivers from the Drivers folder
   - Adds all SSDTs from the ACPI folder
5. **Press `Ctrl + S`** to save

### 5.3 Make These Exact Changes

Now make each change manually in ProperTree. Navigate the tree by clicking the arrows:

#### Fix 1: Remove Broken Custom Entry (CRITICAL)
1. Navigate to: `Misc` → `Entries`
2. **Delete everything inside `Entries`** — set it to empty array `()`
3. **Why:** A broken custom Entry causes "ocb: loadimage failed" error

#### Fix 2: Set ProcessorType
1. Navigate to: `PlatformInfo` → `Generic`
2. Find `ProcessorType`
3. Change value from `0` to `1795`
4. **Why:** Tells macOS this is an Ivy Bridge i5 CPU (hex 0x0703 = decimal 1795)

#### Fix 3: Set Automatic to False
1. Navigate to: `PlatformInfo`
2. Find `Automatic`
3. Change from `True` to `False`
4. **Why:** Prevents OpenCore from overwriting your SMBIOS settings

#### Fix 4: Set UpdateSMBIOSMode to Custom
1. Navigate to: `PlatformInfo`
2. Find `UpdateSMBIOSMode`
3. Change from `Create` to `Custom`
4. **Why:** Preserves your SMBIOS data instead of recreating it

#### Fix 5: Update boot-args
1. Navigate to: `NVRAM` → `Add` → `7C436110-AB2A-4BBB-A880-FE41995C9F82`
2. Find `boot-args`
3. Change the value to:
   ```
   -v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi
   ```
4. **What each flag does:**
   - `-v` — verbose mode (shows text during boot instead of Apple logo)
   - `debug=0x100` — stops reboot on kernel panic (lets you read the error)
   - `keepsyms=1` — keeps debug symbols in panic reports
   - `alcid=29` — audio layout ID for ALC282
   - `igfxonln=1` — fixes HD 4000 online status
   - `-igfxnohdmi` — disables HDMI output (prevents conflicts)

#### Fix 6: Enable AppleXcpmExtraMsrs
1. Navigate to: `Kernel` → `Quirks`
2. Find `AppleXcpmExtraMsrs`
3. Change from `False` to `True`
4. **Why:** Ivy Bridge needs this for CPU power management

#### Fix 7: Enable AppleCpuPmCfgLock
1. Navigate to: `Kernel` → `Quirks`
2. Find `AppleCpuPmCfgLock`
3. Change from `False` to `True`
4. **Why:** Ivy Bridge laptops have locked MSR registers

#### Fix 8: Enable DummyPowerManagement
1. Navigate to: `Kernel` → `Quirks`
2. Find `DummyPowerManagement`
3. Change from `False` to `True`
4. **Why:** Prevents kernel panics from AppleIntelCPUPowerManagement

#### Fix 9: Set SecureBootModel to Disabled
1. Navigate to: `Misc` → `Security`
2. Find `SecureBootModel`
3. Change from `Default` to `Disabled`
4. **Why:** Disables Apple Secure Boot to allow unsigned recovery images

#### Fix 10: Enable XhciPortLimit
1. Navigate to: `Kernel` → `Quirks`
2. Find `XhciPortLimit`
3. Change from `False` to `True`
4. **Why:** Lifts the 15 USB port limit so all ports work

#### Fix 11: Set IgnoreInvalidFlexRatio
1. Navigate to: `UEFI` → `Quirks`
2. Find `IgnoreInvalidFlexRatio`
3. Change from `False` to `True`
4. **Why:** Fixes a BIOS bug on some Ivy Bridge boards

#### Fix 12: Delete CpuPm and Cpu0Ist Tables
1. Navigate to: `ACPI` → `Delete`
2. Add two entries:
   ```xml
   <dict>
       <key>TableSignature</key>
       <data>Q1BQVA==</data>
   </dict>
   <dict>
       <key>TableSignature</key>
       <data>Q3B1MEk=</data>
   </dict>
   ```
3. **Why:** Removes CPU power tables that conflict with macOS

#### Fix 13: Add HD 4000 Graphics Properties
1. Navigate to: `DeviceProperties` → `Add`
2. Add key: `PciRoot(0x0)/Pci(0x2,0x0)`
3. Add these values inside it:
   - `AAPL,ig-platform-id` = `BwAAEA==` (base64 for 0x03006601)
   - `device-id` = `RBAQAA==` (base64 for 0x01660000)
   - `framebuffer-patch-enable` = `AQAAAA==` (base64 for 0x00000001)
4. **Why:** Enables HD 4000 graphics with correct framebuffer

#### Fix 14: Add IMEI Spoof
1. Navigate to: `DeviceProperties` → `Add`
2. Add key: `PciRoot(0x0)/Pci(0x1F,0x3)`
3. Add value: `device-id` = `CgQAAA==` (base64 for 0x02000000)
4. **Why:** Prevents "Missing Platform EFI" errors

#### Fix 15: Add apfs_aligned.efi Driver
1. Navigate to: `UEFI` → `Drivers`
2. Add a new entry:
   ```xml
   <dict>
       <key>Arguments</key>
       <string></string>
       <key>Comment</key>
       <string></string>
       <key>Enabled</key>
       <true/>
       <key>LoadEarly</key>
       <false/>
       <key>Path</key>
       <string>apfs_aligned.efi</string>
   </dict>
   ```
3. **Why:** Lets OpenCore read APFS partitions

### 5.4 Save and Validate
1. **Press `Ctrl + S`** to save config.plist
2. **Close ProperTree**
3. **Open Command Prompt** and run:
   ```
   Desktop\OpenCore-1.0.5-RELEASE\Utilities\ocvalidate\ocvalidate.exe Desktop\MacOS\EFI\OC\config.plist
   ```
4. **If it says "No issues found"** — your config is correct!
5. **If it reports errors** — go back to ProperTree and fix them

---

## 10. Step 6: Copy Everything to USB

Now you need to copy your built EFI folder and recovery files to the USB drive.

### Option A: Use the PowerShell Script (RECOMMENDED)

1. **Make sure your USB is formatted** (Step 5)
2. **Open File Explorer** → navigate to `Desktop\Hackintosh_Dell_3521\06_Working_Files\`
3. **Right-click `COPY_HAKINTOSH_USB.ps1`** → select "Run with PowerShell"
4. **If Windows asks for permission** → click "Yes"
5. **Wait for the script to finish** — it will:
   - Copy EFI folder to USB
   - Copy BaseSystem.dmg to USB
   - Verify all files are present
6. **When it says "USB READY!"** — you're done!

### Option B: Manual Copy

1. **Plug in your USB drive** (note the drive letter, e.g., F:)
2. **Copy the EFI folder:**
   - Open `Desktop\MacOS\EFI\` → select everything inside
   - Copy to `F:\EFI\`
3. **Copy the recovery files:**
   - Open `Desktop\MacOS\com.apple.recovery.boot\`
   - Copy the entire folder to `F:\`
4. **Verify the final structure:**
   ```
   F:\ (USB Drive)
   ├── EFI\
   │   ├── BOOT\
   │   │   └── BOOTIA32.EFI
   │   └── OC\
   │       ├── ACPI\
   │       ├── Drivers\
   │       ├── Kexts\
   │       ├── Resources\
   │       ├── Tools\
   │       └── config.plist
   └── com.apple.recovery.boot\
       ├── BaseSystem.dmg
       └── BaseSystem.chunklist
   ```

---

## 11. Step 7: Boot & Install macOS

1. **Plug the USB into the Dell 3521**
2. **Restart the laptop**
3. **Press F12 repeatedly** during boot (before Windows loads)
4. **A boot menu appears** — select your USB drive (it may say "UEFI: Kingston..." or similar)
5. **OpenCore picker appears** — you'll see a text-based menu
6. **Press Spacebar** to show hidden entries
7. **Select "macOS Recovery"** (or "macOS Installer")
8. **macOS Recovery loads** — you'll see a Apple logo or text scrolling
9. **Open Disk Utility** (from the Recovery menu)
10. **Select your internal hard drive** → click "Erase"
11. **Name it** (e.g., "Macintosh HD") → Format: **APFS** → Scheme: **GUID Partition Map**
12. **Click "Erase"** → wait for it to finish → click "Done"
13. **Close Disk Utility** → go back to Recovery menu
14. **Select "Reinstall macOS"** → follow the prompts
15. **The installation begins** — the laptop will reboot multiple times (this is normal!)
16. **On each reboot**, press F12 → select USB → OpenCore picker appears → let it auto-select the next stage
17. **After the final reboot**, macOS Setup Assistant appears → follow the setup wizard

### Important Notes During Installation:
- **Do NOT touch the OpenCore picker** on reboots — let it auto-select the next stage
- **The laptop WILL reboot 3-4 times** — this is normal macOS behavior
- **If the screen goes black**, press any key or wait 30 seconds — it's still loading
- **If you see a "prohibited" sign**, your config.plist is wrong — go back to Step 5

---

## 12. Step 8: Post-Install (Copy EFI to Internal Disk)

After macOS is installed and working, you need to copy the EFI to the internal disk so you can boot without the USB.

### 8.1 Mount the Internal EFI Partition
1. **Boot into macOS** from the USB
2. **Open Terminal** (Applications → Utilities → Terminal)
3. **Run this command:**
   ```bash
   sudo diskutil mount /dev/disk0s1
   ```
4. **Enter your password** when prompted
5. **The EFI partition mounts** as `/Volumes/EFI`

### 8.2 Copy EFI to Internal Disk

**Method A: From GitHub (recommended if USB is not visible in macOS)**
1. **Open Terminal**
2. **Run these commands:**
   ```bash
   cd ~/Desktop
   git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
   sudo diskutil mount disk0s1
   sudo cp -R ~/Desktop/Dell-3521-Hackintosh/EFI /Volumes/EFI/
   ```
3. **Verify the copy:**
   ```bash
   ls /Volumes/EFI/EFI/OC/Kexts/
   ```
   You should see all kexts listed.

**Method B: From USB (if USB is visible in Finder)**
1. **Open Finder** → navigate to the USB drive
2. **Copy the entire `EFI` folder** from USB to `/Volumes/EFI/`

### 8.3 Verify EFI Structure
Make sure these files exist:
```
/Volumes/EFI/EFI/BOOT/BOOTIA32.EFI
/Volumes/EFI/EFI/OC/config.plist
/Volumes/EFI/EFI/OC/Kexts/AirportItlwm.kext
```

### 8.4 Remove USB and Test
1. **Restart the laptop** → remove the USB
2. **The laptop should boot from the internal disk** with OpenCore
3. **If it doesn't boot**, plug the USB back in and try again

### 8.5 Remove Debug Boot Flags (After Everything Works)
Once macOS boots and WiFi/audio work, remove the verbose debug flags for a clean Apple-logo boot:

**Terminal commands (run in macOS):**
```bash
# Mount the EFI partition
sudo diskutil mount disk0s1

# Edit config.plist to remove debug flags
sudo sed -i '' 's/-v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi/alcid=29 igfxonln=1 -igfxnohdmi/' /Volumes/EFI/EFI/OC/config.plist

# Reboot
sudo reboot
```

**Before (debug):** `-v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi`
**After (clean):** `alcid=29 igfxonln=1 -igfxnohdmi`

**What was removed:**
- `-v` — verbose text during boot (shows Apple logo instead)
- `debug=0x100` — panic log capture (safe to remove once stable)
- `keepsyms=1` — debug symbols in panic reports (safe to remove once stable)

**To re-add for debugging:**
```bash
sudo sed -i '' 's/alcid=29 igfxonln=1 -igfxnohdmi/-v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi/' /Volumes/EFI/EFI/OC/config.plist
```

---

## 13. ESP Folder Structure

### USB (F:\)
```
F:\
├── EFI\
│   ├── BOOT\
│   │   └── BOOTIA32.EFI          ← 32-bit OpenCore bootloader
│   └── OC\
│       ├── ACPI\
│       │   ├── SSDT-EC.aml       ← Embedded Controller patch
│       │   ├── SSDT-HPET.aml     ← High Precision Event Timer patch
│       │   ├── SSDT-PLUG.aml     ← CPU Power Management patch
│       │   └── SSDT-PNLF.aml     ← Backlight control patch
│       ├── Drivers\
│       │   ├── HfsPlus.efi       ← HFS+ partition support
│       │   ├── OpenCanopy.efi    ← GUI picker (may not render on IA32)
│       │   ├── OpenRuntime.efi   ← Runtime services
│       │   ├── OpenShell.efi     ← EFI Shell
│       │   ├── ResetNvramEntry.efi ← NVRAM reset
│       │   └── apfs_aligned.efi  ← APFS partition support
│       ├── Kexts\
│       │   ├── AirportItlwm.kext   ← Intel WiFi (Big Sur)
│       │   ├── AirportBrcmFixup.kext ← Broadcom WiFi (disabled)
│       │   ├── AppleALC.kext       ← Audio (ALC282)
│       │   ├── BrcmFirmwareData.kext ← Bluetooth firmware
│       │   ├── BrcmPatchRAM3.kext  ← Bluetooth patching
│       │   ├── BrcmBluetoothInjector.kext ← Bluetooth injection
│       │   ├── BrightnessKeys.kext ← Brightness hotkeys
│       │   ├── ECEnabler.kext      ← Battery EC patch
│       │   ├── Lilu.kext           ← Core patching engine
│       │   ├── RealtekRTL8100.kext ← Ethernet
│       │   ├── SMCBatteryManager.kext ← Battery status
│       │   ├── UTBMap.kext         ← USB port map
│       │   ├── VirtualSMC.kext     ← SMC emulation
│       │   ├── VoodooPS2Controller.kext ← Keyboard/trackpad
│       │   ├── VoodooRMI.kext      ← Trackpad (I2C)
│       │   └── WhateverGreen.kext  ← Graphics (HD 4000)
│       ├── Resources\
│       │   ├── Audio\
│       │   ├── Font\
│       │   ├── Image\
│       │   └── Label\
│       ├── Tools\
│       │   └── OpenShell.efi
│       └── config.plist          ← THE CRITICAL FILE
└── com.apple.recovery.boot\
    ├── BaseSystem.dmg            ← macOS recovery image
    └── BaseSystem.chunklist      ← Integrity check file
```

---

## 14. PlatformInfo

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

### How to Generate Your Own Serials:
1. **Download GenSMBIOS:** https://github.com/corpnewt/GenSMBIOS
2. **Extract to Desktop**
3. **Double-click `GenSMBIOS.bat`**
4. **Type `1`** (Generate SMBIOS) → press Enter
5. **Type `MacBookAir6,2`** → press Enter
6. **Copy the values** it generates into your config.plist:
   - `TypeSerial` → `SystemSerialNumber`
   - `TypeMLB` → `MLB`
   - `TypeSmUUID` → `SystemUUID`

---

## 15. Known Issues & Workarounds

### 15.1 OpenCanopy GUI Not Rendering
- **Problem:** PickerMode=Auto does not show the GUI picker despite OpenCanopy.efi being loaded
- **Workaround:** Use CLI picker (it works fine, just less pretty)
- **Possible cause:** IA32 compatibility issue with OpenCanopy rendering

### 15.2 USB Must Be GPT
- The Dell 3521's IA32 EFI reads GPT USBs better than MBR
- Use `diskpart` or Rufus to create GPT FAT32

### 15.3 Recovery vs Install Media
- We used the **recovery method** (BaseSystem.dmg) not a full macOS installer
- Recovery is simpler and works well for first-time installs

---

### USB WiFi Setup

The Atheros AR9485 has no macOS kext — use a USB WiFi dongle instead.

**Steps:**
1. Confirm USB ports work (keyboard/mouse detected)
2. Plug USB WiFi dongle into a **USB 3.0 port** (SS01 or SS02 — the blue ports)
3. macOS will detect it automatically as a network interface (no driver install needed for most Realtek-based dongles)
4. Go to **System Preferences → Network** → click the `+` icon → select your USB WiFi adapter from the dropdown
5. Connect to your network

**Compatible cheap dongles:**
- TP-Link TL-WN725N (Realtek RTL8188EUS) — native macOS support, ~$10
- TP-Link TL-WN722N v1 (Atheros AR9271) — works via USB passthrough
- Any Realtek RTL8812AU/RTL8821CU based adapter

> **Tip:** The USB WiFi dongle does NOT support Bluetooth. For Bluetooth, keep the internal BrcmPatchRAM kexts loaded — they handle the Dell's built-in Bluetooth module separately.

---

## 16. Troubleshooting

### Boot Loop (Returns to Picker)
**Symptoms:** OpenCore picker appears, you select an option, but it just returns to the picker.

**Fixes:**
1. **Check SecureBootModel:** Open `config.plist` in ProperTree → find `Misc → Security` → make sure `SecureBootModel` is set to `Disabled` (not `Default` or `Secure`).
2. **Check USB format:** The USB must be GPT + FAT32. If you're unsure, re-format with diskpart (see Step 1).
3. **Press Spacebar:** In the OpenCore picker, press **Spacebar** — this reveals hidden entries. Sometimes the recovery entry is hidden by default.
4. **Check apfs_aligned.efi:** Open `EFI/OC/Drivers/` — is `apfs_aligned.efi` there? Without it, OpenCore can't read the APFS partition.
5. **Re-download recovery:** The BaseSystem.dmg may be corrupted. Re-run gibMacOS to download a fresh copy.
6. **Run ocvalidate:** Open Command Prompt → navigate to your OpenCore `Utilities/ocvalidate` folder → run `ocvalidate.exe <path-to-config.plist>`. Fix any errors it reports.

### Kernel Panic on Boot
**Symptoms:** Text scrolls on screen, then the laptop reboots or shows a panic message.

**Fixes:**
1. **Take a photo of the panic message** — the top line usually says what went wrong.
2. **Boot with verbose mode** (you already have `-v` in boot-args, so you should see text output). If the panic happens too fast, add `debug=0x100` to boot-args.
3. **To edit boot-args:** On the USB, open `EFI/OC/config.plist` in ProperTree → find `NVRAM → Add → 7C436110-AB2A-4BBB-A880-FE41995C9F82` → find `boot-args` → add `debug=0x100` to the end.
4. **Common causes and fixes:**
   - **Missing Lilu.kext or VirtualSMC.kext** → download them and copy to `EFI/OC/Kexts/`
   - **Wrong ig-platform-id** → check `DeviceProperties → Add → PciRoot(0x0)/Pci(0x2,0x0)` → `AAPL,ig-platform-id` should be `BwAAEA==`
   - **AppleCpuPmCfgLock not set** → check `Kernel → Quirks` → `AppleCpuPmCfgLock` should be `True`
   - **Missing apfs_aligned.efi** → copy it to `EFI/OC/Drivers/`

### Black Screen After Boot
**Symptoms:** Verbose text stops, screen goes black, but laptop stays on.

**Fixes:**
- Verify `AAPL,ig-platform-id` is `0x03006601` (base64: `BwAAEA==`)
- Ensure `WhateverGreen.kext` is loaded
- Add `igfxonln=1` to boot-args
- Add `-igfxnohdmi` to boot-args
- Try connecting an external monitor via VGA

### No WiFi
**Root Cause:** The Dell 3521 has an **Atheros AR9485** (Qualcomm, `168C-0036`). This card has NO macOS support — no kext exists for it. The WiFi card was identified via Windows Device Manager → Network adapters → Qualcomm Atheros AR9485.

**Symptoms:** WiFi icon shows "No Hardware Installed" or `en0` not built in.

**Solution: Use a USB WiFi dongle**
- Any macOS-compatible USB WiFi adapter will work once USB ports are functional
- Plug into USB 3.0 port (SS01 or SS02) for best performance
- macOS will detect it automatically as a network interface
- Common cheap options: TP-Link TL-WN725N (Realtek RTL8188EUS — has macOS driver)

**AirportItlwm.kext is kept for future use** — if you swap the Atheros card for an Intel one, re-enable it in config.plist.

### No Audio
**Symptoms:** No sound from speakers or headphone jack.

**Fixes:**
- Try different `alcid` values: `1`, `2`, `3`, `13`, `27`, `29`
- Ensure `AppleALC.kext` is loaded
- Check System Preferences → Sound → Output

### USB Not Working
**Root Cause:** The Dell 3521 has EHC1 + EHC2 (USB 2.0) + XHC (USB 3.0) controllers — 6+ physical ports. The old UTBMap.kext was missing a dependency (`com.dhinakg.USBToolBox.kext`) and only mapped 4 ports.

**Fix:** `USBMap.kext` is now included — a self-contained port map using Apple's built-in `AppleUSBMergeNub` driver with no external dependencies. Port map:

| Controller | Port | Type | UsbConnector |
|------------|------|------|-------------|
| EHC1 | PRT1 | Internal | 255 |
| EHC1 | PRT2 | External USB 2.0 | 0 |
| EHC2 | PRT1 | Internal (webcam hub) | 255 |
| EHC2 | PRT2 | External USB 2.0 | 0 |
| XHC | HS01 | External USB 2.0 | 0 |
| XHC | HS02 | External USB 2.0 | 0 |
| XHC | SS01 | External USB 3.0 | 3 |
| XHC | SS02 | External USB 3.0 | 3 |

Total: **8 ports** (under macOS 15-port limit). Use USB 3.0 ports (SS01/SS02) for USB WiFi dongle.

### Battery Status Not Showing
**Symptoms:** Battery percentage not shown in menu bar.

**Fixes:**
- Ensure `ECEnabler.kext` and `SMCBatteryManager.kext` are loaded
- Ensure `SSDT-EC.aml` is in ACPI

---

## 17. FAQ

### Q: Can I use a different macOS version?
**A:** Yes, but you'll need to adjust kext versions. This EFI was built for Big Sur 11.7.10. For Monterey or Ventura, you'll need newer versions of Lilu, WhateverGreen, AppleALC, etc. The config.plist fixes remain the same.

### Q: Can I use this EFI on a different Dell laptop?
**A:** The config.plist fixes are specific to the Dell 3521's Ivy Bridge hardware. Other Dell laptops with similar hardware (i5-3337U, HD 4000) may work, but you'll need to adjust SSDTs, USB port maps, and possibly audio layout IDs.

### Q: Why is the USB drive formatted as GPT instead of MBR?
**A:** The Dell 3521's IA32 EFI firmware has better compatibility with GPT partition tables. MBR can cause boot failures or the EFI not being detected.

### Q: What if I don't have BaseSystem.chunklist?
**A:** gibMacOS always downloads both `BaseSystem.dmg` and `BaseSystem.chunklist`. If you're missing the chunklist, re-run gibMacOS MakeInstall.

### Q: Do I need to remove the USB after installation?
**A:** Not immediately. First, copy the EFI to the internal disk's EFI partition. Then test that the laptop can boot from the internal disk without the USB. Once confirmed, you can remove the USB.

### Q: Can I use this with Windows on the same laptop?
**A:** Yes. The EFI partition is separate from the Windows partition. You can dual-boot by having both Windows Boot Manager and OpenCore in the EFI partition, or by using the F12 boot menu to choose which OS to boot.

### Q: What if my USB doesn't show up in the F12 boot menu?
**A:**
- Make sure the USB is GPT + FAT32
- Make sure UEFI boot is enabled in BIOS
- Try a different USB port
- Re-format the USB with diskpart
- Verify `BOOTIA32.EFI` exists at `EFI\BOOT\BOOTIA32.EFI`

### Q: How do I update OpenCore in the future?
**A:**
1. Download the latest OpenCore release
2. Extract the IA32 folder
3. Replace `EFI\BOOT\BOOTIA32.EFI` and `EFI\OC\OpenCore.efi` with the new versions
4. Copy any new kext versions
5. Re-apply config.plist changes (or use your existing config.plist — it should be compatible)
6. Run ocvalidate to check for errors

### Q: Can I update macOS to a newer version (Sonoma, Ventura, Tahoe)?
**A: NO.** macOS Monterey (12) and later dropped support for Intel HD 4000 graphics. Updating will break display/graphics or prevent boot entirely. Stay on **Big Sur (11)** — it's the last macOS version that works on the Dell 3521. If macOS shows an update notification, **ignore it**. You can disable automatic updates in System Preferences → Software Update → uncheck "Automatically keep my Mac up to date".

### Q: What's the difference between Recovery and Full Installer?
**A:**
- **Recovery** (what we used): Downloads macOS from Apple's servers during installation. ~637 MB download. Simpler setup.
- **Full Installer**: Contains the complete macOS installer. ~5 GB download. Can install offline.
- Both work. Recovery is recommended for first-time installs because it's smaller and simpler.

### Q: Why does the installation reboot multiple times?
**A:** macOS installation happens in stages: (1) copy files to disk, (2) configure the system, (3) finalize settings. Each reboot completes a stage. Even real Macs reboot multiple times during installation — this is normal macOS behavior, not a Hackintosh issue.

### Q: Do I need to select "macOS Installer" on each reboot?
**A:** No. The process is automatic. After you boot from USB, OpenCore auto-detects the next stage of installation and selects it. You just need to boot from USB each time (press F12, select USB). Don't touch the OpenCore picker — let it auto-select.

### Q: What does verbose mode look like?
**A:** White text scrolling on a black screen. Lines like `ACPI: Mac...`, `kext done`, `EB:...` will fly by. This is normal — it's macOS loading. If it stops for more than 2 minutes, see Troubleshooting.

### Q: Why can't I just format the USB with Windows File Explorer?
**A:** Windows File Explorer formats as NTFS or exFAT by default. macOS EFI requires FAT32, and the Dell 3521 requires GPT (not MBR). Rufus or diskpart are the only reliable ways to get GPT + FAT32.

### Q: What if my disk doesn't appear in Disk Utility?
**A:** This usually means AHCI mode isn't enabled in BIOS. Go back to BIOS settings and verify SATA Operation = AHCI. If it's set to RAID, macOS cannot see the disk. You may need to reinstall Windows after changing this.

### Q: What if I get "ocb: loadimage failed" error?
**A:** This means OpenCore can't find the boot files. Common causes:
- `Misc.Entries` has hardcoded paths — clear it (set to empty array `()`)
- `BOOTIA32.EFI` is missing from `EFI/BOOT/`
- USB is MBR instead of GPT
- Re-run ocvalidate to check for config errors

### Q: How do I know if my config.plist is correct?
**A:** Run `ocvalidate` — it checks for structural errors. If it says "No issues found", the structure is correct. If macOS still doesn't boot, the issue is likely a value that's technically valid but wrong for your hardware (like wrong ig-platform-id). Check the Troubleshooting section.

### Q: Can I use this EFI on a different Ivy Bridge laptop?
**A:** Possibly, but you'll need to adjust: SSDTs (different laptops need different ACPI patches), USB port map (UTBMap.kext), audio layout ID (alcid boot-arg), and SMBIOS (may need a different Mac model). The core config fixes (CPU power management, HD 4000 graphics) are the same for all Ivy Bridge laptops.

---

## 18. Tools & Resources

### Essential Tools

| Tool | What It Does | Where to Get It |
|------|--------------|-----------------|
| **OpenCore 1.0.5 IA32** | Bootloader | [GitHub](https://github.com/acidanthera/OpenCorePkg/releases) |
| **gibMacOS** | Downloads macOS Recovery | [GitHub](https://github.com/corpnewt/gibMacOS) |
| **ProperTree** | Edits config.plist | [GitHub](https://github.com/corpnewt/ProperTree) |
| **GenSMBIOS** | Generates serial numbers | [GitHub](https://github.com/corpnewt/GenSMBIOS) |
| **diskpart** | Windows disk partitioning | Built into Windows |
| **ocvalidate** | Validates config.plist | Inside OpenCore download |
| **USBToolBox** | USB port mapping | [GitHub](https://github.com/USBToolBox/USBToolBox) |

### Resources

| Resource | URL |
|----------|-----|
| Dortania OpenCore Install Guide | [dortania.github.io/OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/) |
| Dell 3521 Hackintosh Guide | [macOS on Dell Inspiron 3521](https://www.tonymacx86.com/threads/dell-inspiron-3521-macos-big-sur.316107/) |
| OpenCore Documentation | [dortania.github.io/docs](https://dortania.github.io/docs/latest/) |
| USBToolBox | [USBToolBox GitHub](https://github.com/USBToolBox/USBToolBox) |

---

## Appendix: BIOS Settings Reference

| Setting | Value | How to Access |
|---------|-------|---------------|
| SATA Operation | AHCI | BIOS → System Configuration → SATA Operation |
| Secure Boot | Disabled | BIOS → Security → Secure Boot |
| Boot Mode | UEFI | BIOS → Boot Sequence → Boot List Option |
| Legacy Boot | Disabled | BIOS → Boot Sequence → Uncheck "Legacy" |
| VT-d | Disabled | BIOS → Advanced → (if available) |

---

## Appendix: Diskpart Commands Reference

### Quick Format (Recommended)
```
diskpart
list disk
select disk <number>
clean
convert gpt
create partition primary
format fs=fat32 quick
assign letter=F
exit
```

### Format Without Clean (Preserves Data on Other Partitions)
```
diskpart
list disk
select disk <number>
create partition primary
format fs=fat32 quick
assign letter=F
exit
```

> **WARNING:** `clean` destroys ALL data on the selected disk. Double-check the disk number before running it.

---

## Appendix: Apply Config Fixes Script

The Python script `apply_theyronecodes_fixes.py` automates all config.plist fixes. To use it:

1. Install Python 3 if you don't have it
2. Edit the script's `ROOT` variable to point to your EFI directory
3. Run: `python apply_theyronecodes_fixes.py`
4. Verify output says `ocvalidate: CLEAN`

The script applies:
- Removes broken Misc.Entries
- Sets ProcessorType to 1795
- Sets Automatic to False
- Sets UpdateSMBIOSMode to Custom
- Updates boot-args
- Enables AppleXcpmExtraMsrs
- Adds apfs_aligned.efi driver
- Runs ocvalidate

---

*Last updated: July 2026*
*Tested on: Dell Inspiron 3521, i5-3337U, OpenCore 1.0.5, macOS Big Sur 11.7.10*
*Repository: [theyonecodes/Dell-3521-Hackintosh](https://github.com/theyonecodes/Dell-3521-Hackintosh)*
