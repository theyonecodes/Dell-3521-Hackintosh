# Hackintosh macOS Big Sur on Dell Inspiron 3521 — Complete Guide

This repository contains the **exact working EFI** and **step-by-step instructions** that successfully installed macOS Big Sur 11.7.10 on a Dell Inspiron 3521 using OpenCore. Everything here was tested, verified, and documented to help you avoid the pitfalls we encountered.

> **This is not a generic guide.** Every line here comes from a real, working installation on this exact hardware. If you have the same laptop, follow this exactly and it will work.

---

## Table of Contents

1. [Hardware Specifications](#1-hardware-specifications)
2. [What You Need — Complete List](#2-what-you-need--complete-list)
3. [BIOS Settings — Do This First](#3-bios-settings--do-this-first)
4. [Step 1: Format the USB Drive](#4-step-1-format-the-usb-drive)
5. [Step 2: Download macOS Recovery](#5-step-2-download-macos-recovery)
6. [Step 3: Build the OpenCore EFI](#6-step-3-build-the-opencore-efi)
7. [Step 4: Apply Critical Config Fixes](#7-step-4-apply-critical-config-fixes)
8. [Step 5: Copy Everything to USB](#8-step-5-copy-everything-to-usb)
9. [Step 6: Boot and Install macOS](#9-step-6-boot-and-install-macos)
10. [Step 7: Post-Install Setup](#10-step-7-post-install-setup)
11. [The Critical Fixes — Why They Work](#11-the-critical-fixes--why-they-work)
12. [PlatformInfo (SMBIOS)](#12-platforminfo-smbios)
13. [ESP Folder Structure](#13-esp-folder-structure)
14. [Known Issues & Workarounds](#14-known-issues--workarounds)
15. [Troubleshooting](#15-troubleshooting)
16. [Tools & Resources Used](#16-tools--resources-used)
17. [FAQ](#17-faq)

---

## 1. Hardware Specifications

| Component | Model |
|-----------|-------|
| Laptop | Dell Inspiron 3521 |
| CPU | Intel Core i5-3337U (Ivy Bridge, 3rd Gen, 1.8 GHz) |
| EFI Firmware | **IA32 (32-bit) — NOT x86_64** |
| Graphics | Intel HD Graphics 4000 (integrated) |
| Audio | Realtek ALC282 |
| WiFi | Qualcomm Atheros AR9485 |
| Ethernet | Realtek RTL8100 |
| Trackpad | Synaptics (PS/2) |
| SMBIOS | MacBookAir6,2 |

### THE Most Important Thing About This Laptop

> **The Dell 3521 uses a 32-bit (IA32) EFI firmware.**
>
> This means:
> - `BOOTx64.EFI` / `OpenCore.efi` will **NOT** work
> - You **MUST** use `BOOTIA32.EFI`
> - The file is identical to `OpenCore.efi`, just renamed
> - This is the #1 reason most people fail on this laptop

If you use the wrong EFI binary, you will get a black screen or the laptop will simply ignore the USB.

---

## 2. What You Need — Complete List

### Software

| Tool | Version | Purpose | Where to Get It |
|------|---------|---------|-----------------|
| OpenCore | **1.0.5-RELEASE** (IA32 build) | Bootloader | [GitHub](https://github.com/acidanthera/OpenCorePkg/releases) — download `OpenCore-1.0.5-RELEASE.zip`, extract the `IA32` folder |
| gibMacOS | Latest | Download macOS Recovery | [GitHub](https://github.com/corpnewt/gibMacOS) — clone or download ZIP |
| ProperTree | Latest | Edit config.plist | [GitHub](https://github.com/corpnewt/ProperTree) — clone or download ZIP |
| GenSMBIOS | Latest | Generate serial numbers | [GitHub](https://github.com/corpnewt/GenSMBIOS) — clone or download ZIP |
| Rufus | Any recent version | Format USB as GPT FAT32 | [rufus.ie](https://rufus.ie) |

### Hardware

| Item | Details |
|------|---------|
| USB Drive | Any USB drive, **16GB or larger** recommended |
| Second USB (optional) | For saving your EFI backup after install |

### Files You Will Create

| File | Where | Size |
|------|-------|------|
| `BaseSystem.dmg` | Downloaded by gibMacOS | ~637 MB |
| `BaseSystem.chunklist` | Downloaded by gibMacOS | ~2.5 KB |
| `BOOTIA32.EFI` | Renamed from OpenCore's `OpenCore.efi` | ~300 KB |
| `config.plist` | Edited with ProperTree | ~15 KB |

---

## 3. BIOS Settings — Do This First

Before doing anything else, enter BIOS on the Dell 3521 and change these settings:

**How to enter BIOS:** Power on → immediately press **F2** repeatedly until BIOS screen appears.

| Setting | Value | Why |
|---------|-------|-----|
| **SATA Operation** | **AHCI** | macOS does NOT support RAID/IDE. If this is set to RAID, you MUST change it. Warning: changing this may require a Windows reinstall. |
| **Secure Boot** | **Disabled** | macOS recovery images are unsigned. Secure Boot blocks them. |
| **Boot Mode** | **UEFI** | OpenCore requires UEFI boot mode. |
| **Legacy Boot** | **Disabled** | Conflicts with UEFI. Disable it. |
| **VT-d** | **Disabled** (if option exists) | VT-d (I/O virtualization) conflicts with macOS. Some BIOS versions don't have this option — that's fine, we disable it in config.plist too. |

> **WARNING about SATA Operation:** If your Windows is currently installed in RAID mode, changing to AHCI will make Windows unbootable. You have two options:
> 1. Back up everything, do a clean Windows install in AHCI mode first, then proceed with Hackintosh
> 2. Boot Windows in Safe Mode first, change to AHCI, let Windows reconfigure itself, then proceed

---

## 4. Step 1: Format the USB Drive

The USB drive must be formatted as **GPT + FAT32**.

> **WHY GPT instead of MBR?** The Dell 3521's IA32 EFI firmware reads GPT USBs much more reliably than MBR. MBR formatting can cause the USB to not appear in the boot menu at all, or the EFI to be invisible to the firmware.

> **WHY 16GB USB for a 637MB file?** The download is small, but macOS Recovery needs a FAT32 partition with enough headroom. Some USB drives report different usable sizes. 16GB is the safe minimum — it works every time.

### Method A: Using Rufus (Easiest)

1. Download and open [Rufus](https://rufus.ie)
2. Insert your USB drive
3. In Rufus:
   - **Device:** Select your USB drive
   - **Boot selection:** Select "Non bootable" (we'll copy EFI manually)
   - **Partition scheme:** **GPT**
   - **Target system:** **UEFI (non CSM)**
   - **File system:** **FAT32**
   - **Cluster size:** Default
4. Click **START**
5. Confirm any warnings

### Method B: Using diskpart (Command Line)

Open Command Prompt as Administrator and run:

```
diskpart
list disk
```

Find your USB drive by size. In our case it was **Disk 3**. **BE VERY CAREFUL — selecting the wrong disk will destroy your data.**

```
select disk 3
clean
convert gpt
create partition primary
format fs=fat32 quick
assign letter=F
exit
```

> **CRITICAL:** Double-check the disk number before running `clean`. If you select your hard drive, you will lose all data. The USB drive is usually the one with the smallest size (8GB, 16GB, 32GB, etc.).

### Verify the Format

After formatting, open File Explorer and confirm:
- The USB drive shows as **FAT32** (not exFAT, not NTFS)
- The drive is empty
- You can create folders on it

---

## 5. Step 2: Download macOS Recovery

We use the **recovery method** (BaseSystem.dmg) rather than a full macOS installer.

> **WHY Recovery instead of Full Installer?** Recovery is ~637 MB vs ~5 GB for the full installer. Recovery downloads macOS from Apple's servers during installation. It's simpler, faster to prepare, and works perfectly for first-time installs. The full installer is only needed if you want to install offline or on multiple machines.

> **WHY gibMacOS?** Apple doesn't provide direct download links for macOS recovery images. gibMacOS queries Apple's software update catalog and extracts the exact recovery files for your chosen macOS version. It's the standard tool in the Hackintosh community for this.

### Download with gibMacOS

1. Open the folder where you extracted `gibMacOS-master`
2. Run `gibMacOS.bat` (Windows) or `gibMacOS.command` (macOS)
3. A list of available macOS versions will appear
4. Look for **Big Sur 11.7.10** (the latest Big Sur release)
5. Note the number next to it (e.g., `18`)
6. Type that number and press Enter
7. The download will start — it downloads multiple small files, not one big DMG
8. Wait for it to finish (may take 10-30 minutes depending on your internet)

### Convert Recovery to BaseSystem.dmg

After gibMacOS finishes downloading:

1. Run `MakeInstall.bat` (Windows) or `MakeInstall.command` (macOS)
2. This converts the downloaded files into `BaseSystem.dmg` and `BaseSystem.chunklist`
3. The files will be created in a folder called `com.apple.recovery.boot` inside the gibMacOS output directory

### What You Should Have

After this step, you should have:

```
com.apple.recovery.boot/
├── BaseSystem.dmg          (~637 MB)
└── BaseSystem.chunklist    (~2.5 KB)
```

> **NOTE:** `BaseSystem.dmg` is a **flat file**, not a folder. If it appears as a folder, something went wrong with the download. Re-run gibMacOS.

---

## 6. Step 3: Build the OpenCore EFI

### 6.1 Extract OpenCore

1. Unzip `OpenCore-1.0.5-RELEASE.zip`
2. Go into the `IA32` folder (NOT x64 — this is critical for the Dell 3521)
3. Copy the `EFI` folder from `IA32/EFI` to your USB root

### 6.2 Copy Kexts

Download the latest versions of these kexts from their GitHub releases and copy them into `EFI/OC/Kexts/`:

| Kext | Purpose | Required? |
|------|---------|-----------|
| **Lilu.kext** | Core patching framework | **YES** — always first |
| **VirtualSMC.kext** | SMC emulation | **YES** — required for macOS to boot |
| **WhateverGreen.kext** | GPU patching | **YES** — for HD 4000 |
| **AppleALC.kext** | Audio patching | **YES** — for ALC282 |
| **VoodooPS2Controller.kext** | Keyboard/trackpad | **YES** — PS/2 input |
| **VoodooRMI.kext** | Trackpad (RMI protocol) | **YES** — trackpad |
| **VoodooSMBus.kext** | Trackpad (SMBus protocol) | **YES** — trackpad |
| **ECEnabler.kext** | Battery status | Recommended |
| **SMCBatteryManager.kext** | Battery monitoring | Recommended |
| **SMCProcessor.kext** | CPU temperature | Recommended |
| **SMCDellSensors.kext** | Dell fan sensors | Recommended |
| **SMCLightSensor.kext** | Ambient light sensor | Optional |
| **SMCSuperIO.kext** | Super I/O monitoring | Optional |
| **BrightnessKeys.kext** | Brightness hotkeys | Recommended |
| **RestrictEvents.kext** | Event restrictions | Optional |
| **AirportBrcmFixup.kext** | Broadcom WiFi | If using Broadcom WiFi |
| **RealtekRTL8100.kext** | Ethernet | **YES** — for wired internet |
| **RealtekCardReader.kext** | SD card reader | Optional |
| **RealtekCardReaderFriend.kext** | SD card reader support | Optional |
| **BrcmBluetoothInjector.kext** | Broadcom Bluetooth | If using Broadcom BT |
| **BrcmFirmwareData.kext** | Broadcom BT firmware | If using Broadcom BT |
| **BrcmPatchRAM3.kext** | Broadcom BT patching | If using Broadcom BT |
| **UTBMap.kext** | USB port map | **YES** — maps correct USB ports |

> **Order matters:** Always put `Lilu.kext` first in the config.plist Load Order, then `VirtualSMC.kext`, then everything else.

### 6.3 Copy Drivers

Copy these `.efi` files into `EFI/OC/Drivers/`:

| Driver | Purpose | Required? |
|--------|---------|-----------|
| **HfsPlus.efi** | Read HFS+ formatted drives | **YES** |
| **OpenRuntime.efi** | Runtime services | **YES** |
| **apfs_aligned.efi** | Read APFS drives | **YES** — critical for Big Sur |
| **ResetNvramEntry.efi** | NVRAM reset option | Recommended |
| **OpenCanopy.efi** | GUI picker (optional) | Optional — doesn't render on this hardware |

> **apfs_aligned.efi** is critical. Big Sur installs to APFS by default. Without this driver, OpenCore cannot read the APFS partition after installation. This driver was **NOT included** in the standard OpenCore 1.0.5 package — you need to download it separately from [Acidanthera's GitHub](https://github.com/acidanthera/OcBinaryData/blob/master/Drivers/apfs_aligned.efi) or find it in community builds.

### 6.4 Copy ACPI (SSDTs)

> **WHY do I need SSDTs?** SSDTs (Secondary System Description Tables) are small ACPI patches that tell macOS about hardware that the Dell 3521's BIOS doesn't expose correctly. Without them, macOS won't know how to manage the battery, backlight, embedded controller, or CPU power states.

> **Where do I get these SSDTs?** These are **pre-compiled .aml files** — you do NOT compile them yourself. Download them from the [Dortania Dell 3521 guide](https://dortania.github.io/OpenCore-Install-Guide/) or use the ones from the reference EFI in this repository. The .aml files are binary — just copy them, don't try to edit them.

Copy these `.aml` files into `EFI/OC/ACPI/`:

| SSDT | Purpose |
|------|---------|
| **SSDT-EC.aml** | Embedded Controller — required for all laptops |
| **SSDT-HPET.aml** | High Precision Timer — fixes IRQ conflicts |
| **SSDT-IMEI.aml** | Intel MEI device — prevents IMEI errors |
| **SSDT-PLUG.aml** | CPU power management |
| **SSDT-PNLF.aml** | Backlight control |
| **SSDT-ALS0.aml** | Ambient light sensor |
| **SSDT-MCHC.aml** | Memory Controller Hub |
| **SSDT-SBUS.aml** | SMBus controller |
| **SSDT-XOSI.aml** | OS simulation — tricks BIOS into exposing all features |

### 6.5 Create config.plist

> **WHY ProperTree and not Notepad++?** config.plist is a binary plist file. Notepad++ and similar editors corrupt binary plist data. ProperTree is designed specifically for OpenCore config files — it preserves binary data, understands the plist format, and has the `OC Clean Snapshot` feature that auto-populates your config with the kexts, drivers, and SSDTs you've placed in the EFI folder.

**Where does config.plist come from?** OpenCore ships with a `Sample.plist` inside the `EFI/OC/` folder. This is your starting point. The file is NOT blank — it's a complete template with all default values.

1. Open `ProperTree`
2. Go to `File → Open` and navigate to `EFI/OC/Sample.plist`
3. Go to `File → Save As` and save it as `config.plist` in the same `EFI/OC/` folder
4. Now go to `File → OC Clean Snapshot` and select the `EFI/OC` folder — this auto-populates kexts, drivers, and SSDTs from what you've placed in the folder

---

## 7. Step 4: Apply Critical Config Fixes

These are the **non-negotiable** config.plist changes that made it boot. Skipping any one of these will cause boot loops, kernel panics, or a black screen.

### Fix 1: CPU Power Management (Ivy Bridge)

Open config.plist in ProperTree and find `Kernel → Quirks`:

| Key | Value | Why |
|-----|-------|-----|
| `AppleCpuPmCfgLock` | **True** | Ivy Bridge laptops have locked MSR 0xE2 registers. This allows macOS to manage CPU without unlocking BIOS. |
| `DummyPowerManagement` | **True** | Prevents kernel panics from AppleIntelCPUPowerManagement on locked firmware. |
| `AppleXcpmExtraMsrs` | **True** | Required for Ivy Bridge CPU power management. |
| `AppleXcpmCfgLock` | **True** | Additional CFG lock bypass for Ivy Bridge. |
| `DisableIoMapper` | **True** | Disables VT-d which conflicts with macOS. |
| `PanicNoKextDump` | **True** | Prevents kext dump on kernel panic — shows useful error instead. |
| `PowerTimeoutKernelPanic` | **True** | Prevents panics from power timeout issues. |
| `XhciPortLimit` | **True** | Temporarily lifts 15 USB port limit during installation. **Remove after install.** |
| `DisableLinkeditJettison` | **True** | Required for Lilu to work properly. |

### Fix 2: IgnoreInvalidFlexRatio

Find `UEFI → Quirks`:

| Key | Value | Why |
|-----|-------|-----|
| `IgnoreInvalidFlexRatio` | **True** | Fixes a BIOS bug on some Ivy Bridge boards where the flex ratio register contains invalid values, causing early boot failures. |

### Fix 3: Remove CPU ACPI Tables

Find `ACPI → Delete` and add these two entries:

```xml
<key>ACPI</key>
<dict>
    <key>Delete</key>
    <array>
        <dict>
            <key>All</key>
            <false/>
            <key>Count</key>
            <integer>0</integer>
            <key>Enabled</key>
            <true/>
            <key>OemTableId</key>
            <data>AAAAAAAAAAA=</data>
            <key>TableLength</key>
            <integer>0</integer>
            <key>TableSignature</key>
            <data>Q1BQVA==</data>
        </dict>
        <dict>
            <key>All</key>
            <false/>
            <key>Count</key>
            <integer>0</integer>
            <key>Enabled</key>
            <true/>
            <key>OemTableId</key>
            <data>AAAAAAAAAAA=</data>
            <key>TableLength</key>
            <integer>0</integer>
            <key>TableSignature</key>
            <data>Q3B1MEk=</data>
        </dict>
    </array>
</dict>
```

**Why:** Removes `CpuPm` (CPUP) and `Cpu0Ist` (Cpu0) ACPI tables that conflict with macOS power management on Ivy Bridge. The base64 values are:
- `Q1BQVA==` = `CPUP` (CpuPm table)
- `Q3B1MEk=` = `Cpu0` (Cpu0Ist table)

### Fix 4: HD 4000 Graphics + IMEI Spoof

Find `DeviceProperties → Add`:

**GPU (PciRoot(0x0)/Pci(0x2,0x0)):**

| Key | Value (Base64) | Hex | Why |
|-----|-----------------|-----|-----|
| `AAPL,ig-platform-id` | `BwAAEA==` | `0x03006601` | Enables HD 4000 with correct framebuffer |
| `device-id` | `RBAQAA==` | `0x01660000` | Spoofs HD 4000 device ID for compatibility |
| `framebuffer-patch-enable` | `AQAAAA==` | `0x01000000` | Activates framebuffer patching |

**IMEI (PciRoot(0x0)/Pci(0x1F,0x3)):**

| Key | Value (Base64) | Hex | Why |
|-----|-----------------|-----|-----|
| `device-id` | `CgQAAA==` | `0x02150000` | Prevents "Missing Platform EFI" errors |

> **How to set these in ProperTree:** Click on the key name, press `Ctrl+Shift+C` to change the value type to `Data`, then enter the base64 value.

### Fix 5: SecureBootModel

Find `Misc → Security`:

| Key | Value | Why |
|-----|-------|-----|
| `SecureBootModel` | **Disabled** | Disables Apple Secure Boot to allow booting unsigned recovery images and older macOS versions. |

### Fix 6: Clear Misc Entries

Find `Misc → Entries` and **delete all entries** (set it to an empty array `()`).

**Why:** Custom entries with hardcoded DevicePaths often cause `ocb: loadimage failed` errors. Letting OpenCore auto-detect `com.apple.recovery.boot` is more reliable.

### Fix 7: PlatformInfo Settings

Find `PlatformInfo`:

| Key | Value | Why |
|-----|-------|-----|
| `Automatic` | **False** | Prevents OpenCore from auto-generating SMBIOS — use your custom values instead. |
| `UpdateSMBIOSMode` | **Custom** | Required for Dell laptops — `Create` mode can corrupt SMBIOS data. |

Find `PlatformInfo → Generic`:

| Key | Value | Why |
|-----|-------|-----|
| `ProcessorType` | **1795** (0x0703) | Tells macOS this is an Ivy Bridge i5 processor. Default (0) may cause incorrect power management. |
| `SystemProductName` | **MacBookAir6,2** | Closest match to i5-3337U with HD 4000. Correct framebuffer and power management profiles. |

### Fix 8: Boot Arguments

Find `NVRAM → Add → 7C436110-AB2A-4BBB-A880-FE41995C9F82` and set `boot-args` to:

```
-v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi
```

| Argument | Purpose |
|----------|---------|
| `-v` | Verbose mode — shows text output during boot (essential for debugging) |
| `debug=0x100` | Prevents automatic reboot on kernel panic — shows panic screen instead |
| `keepsyms=1` | Keeps kernel symbols during panic — shows function names in panic log |
| `alcid=29` | Audio layout ID for ALC282 — if audio doesn't work, try `1`, `2`, `3`, `13`, or `27` |
| `igfxonln=1` | Forces Intel GPU online — fixes black screen after boot |
| `-igfxnohdmi` | Disables HDMI output — prevents conflicts with integrated display |

### Fix 9: Add Drivers to Config

Make sure these drivers are listed in `UEFI → Drivers` and marked as **Enabled**:

| Driver | Enabled | Notes |
|--------|---------|-------|
| `HfsPlus.efi` | True | Must be loaded first |
| `OpenRuntime.efi` | True | Required |
| `apfs_aligned.efi` | True | Required for APFS |
| `ResetNvramEntry.efi` | True | Useful |
| `OpenCanopy.efi` | True (optional) | Doesn't render on this hardware |

### Validate with ocvalidate

After all edits, run OpenCore's validation tool to check for errors:

```
OpenCore-1.0.5-RELEASE\Utilities\ocvalidate\ocvalidate.exe EFI\OC\config.plist
```

If it says `No issues found`, your config is clean. If there are errors, read the error messages carefully — they usually tell you exactly which key is wrong and what the expected value is. Fix them and re-run until clean.

> **WHY validate?** A single typo in config.plist can cause a boot loop or kernel panic. ocvalidate catches structural errors before you try to boot.

---

## 8. Step 5: Copy Everything to USB

### Manual Method

Copy these two items to the **root** of your USB drive:

```
F:\                          ← USB root
├── EFI\                     ← The entire EFI folder you just built
│   ├── BOOT\
│   │   └── BOOTIA32.EFI    ← Renamed from OpenCore.efi (CRITICAL)
│   └── OC\
│       ├── ACPI\            ← 9 SSDTs
│       ├── Drivers\         ← HfsPlus.efi, OpenRuntime.efi, apfs_aligned.efi, etc.
│       ├── Kexts\           ← 22+ kexts
│       ├── Resources\       ← Audio, Font, Image, Label
│       ├── Tools\           ← (empty or with diagnostic tools)
│       └── config.plist     ← Your edited config
└── com.apple.recovery.boot\
    ├── BaseSystem.dmg      ← ~637 MB
    └── BaseSystem.chunklist ← ~2.5 KB
```

### Using COPY_HAKINTOSH_USB.ps1 (Automated)

If you have the PowerShell script, run it as Administrator:

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process
.\COPY_HAKINTOSH_USB.ps1
```

The script will:
1. Check that the USB is FAT32
2. Clean old files from the USB
3. Robocopy the EFI folder (multi-threaded, fast)
4. Copy BaseSystem.dmg and BaseSystem.chunklist
5. Verify all critical files are present

### Rename OpenCore.efi to BOOTIA32.EFI

This is the step most people miss:

```
Copy:  EFI\OC\OpenCore.efi
To:    EFI\BOOT\BOOTIA32.EFI
```

The file content is identical — you're just renaming it. The Dell 3521's 32-bit EFI firmware looks for `BOOTIA32.EFI` specifically.

### Verify Critical Files

Before booting, confirm these files exist on the USB:

```
✅ F:\EFI\BOOT\BOOTIA32.EFI
✅ F:\EFI\OC\config.plist
✅ F:\EFI\OC\OpenCore.efi
✅ F:\EFI\OC\Drivers\HfsPlus.efi
✅ F:\EFI\OC\Drivers\OpenRuntime.efi
✅ F:\EFI\OC\Drivers\apfs_aligned.efi
✅ F:\EFI\OC\Kexts\Lilu.kext
✅ F:\EFI\OC\Kexts\VirtualSMC.kext
✅ F:\com.apple.recovery.boot\BaseSystem.dmg
✅ F:\com.apple.recovery.boot\BaseSystem.chunklist
```

---

## 9. Step 6: Boot and Install macOS

### 9.1 Boot from USB

1. **Plug the USB into the Dell 3521**
2. **Power on** the laptop
3. **Immediately press F12** repeatedly to enter the one-time boot menu
4. Select your USB drive under **UEFI Boot** (it may show as "UEFI: Kingston DataTraveler" or similar)
5. The OpenCore picker should appear — it will be a **text/CLI picker** (not GUI, see [Known Issues](#14-known-issues--workarounds))

### 9.2 Boot into Recovery

1. In the OpenCore picker, you should see **"macOS Recovery"** or **"macOS (external)"**
2. Select it and press Enter
3. **If you don't see any entries:** Press **Spacebar** — this reveals hidden entries. OpenCore sometimes hides entries by default.
4. Wait — verbose text will scroll on screen. This is normal with `-v` in boot-args.

> **What does Verbose mode look like?** You'll see white text scrolling rapidly on a black screen. Lines like `ACPI: Mac...`, `kext done`, `EB:...` will fly by. This is normal — it's macOS loading drivers and initializing hardware. If it stops scrolling and stays black for more than 2 minutes, something went wrong (see Troubleshooting).

5. The macOS Utilities (Recovery) screen should appear — a window with options like "Restore from Time Machine", "Reinstall macOS", "Disk Utility", etc.

### 9.3 Format the Target Disk

1. Open **Disk Utility** from the Recovery menu
2. Click **View → Show All Devices** (this is in the menu bar at the top — critical step, otherwise you only see volumes, not the physical disk)
3. Select the **physical disk** (not a partition) — usually "APPLE HDD" or "Samsung SSD" etc. It's the top-level entry in the left sidebar.
4. Click **Erase**:
   - **Name:** Macintosh HD (or anything you want)
   - **Format:** **APFS** (recommended for Big Sur) or Mac OS Extended (Journaled)
   - **Scheme:** **GUID Partition Map**
5. Click **Erase** and wait
6. Close Disk Utility

> **WHY GUID Partition Map?** macOS requires GPT. The "Scheme" dropdown must be GUID Partition Map, not Master Boot Record. If you don't see this option, you selected a volume instead of the physical disk — go back to step 2.

> **What if my disk doesn't appear?** This usually means AHCI mode isn't enabled in BIOS. Go back to BIOS settings and verify SATA Operation = AHCI. If it's set to RAID, macOS cannot see the disk.

### 9.4 Install macOS

1. Back in the Recovery menu, select **"Reinstall macOS Big Sur"**
2. Agree to the terms
3. Select the disk you just formatted
4. **Wait** — the installation will take 20-60 minutes depending on your disk speed
5. The laptop will **reboot multiple times** — this is normal

### 9.5 Handle Reboots

**This is the part nobody explains clearly.** Here's exactly what happens:

The installation process is **fully automatic**. After you click "Install" and the first progress bar finishes, the laptop will reboot on its own. **You do NOT need to select anything on each reboot.** Here's the full sequence:

1. **You click "Install macOS Big Sur"** → progress bar fills → laptop reboots automatically
2. **First reboot:** Laptop restarts. Press **F12** → select USB again. OpenCore picker appears. **It will automatically select the next boot entry** — you see verbose text scroll, then another progress bar. **Do not touch anything.** Wait.
3. **Second reboot:** Same thing — laptop restarts, you press F12 → select USB. OpenCore picker appears again. Verbose text → progress bar. **Do not touch anything.** Wait.
4. **Third reboot:** Same thing — F12 → USB. This may happen 3-5 times total. Each time, OpenCore automatically detects the correct boot entry and selects it.
5. **Final reboot:** The laptop restarts and boots into **macOS Setup Assistant** (the "Welcome" screen with language selection).

> **Key point:** Each time you boot from USB after a reboot, OpenCore auto-detects the next stage of installation. You do NOT manually select "macOS Installer" — OpenCore handles it. Just boot from USB and let it run.

> **How to know it's done:** When you see the macOS language selection screen (Welcome screen), installation is complete.

> **WHY does it reboot multiple times?** macOS installation happens in stages: first it copies files to the disk, then it configures the system, then it finalizes. Each reboot completes a stage. This is normal macOS behavior — even real Macs reboot multiple times during installation.

### 9.6 Complete Setup

1. Follow the macOS Setup Assistant (language, region, keyboard, etc.)
2. When prompted, create your user account
3. You should land on the macOS desktop

**Congratulations — macOS Big Sur is installed on your Dell 3521!**

---

## 10. Step 7: Post-Install Setup

### 10.1 Copy EFI to Internal Disk

The USB is only needed for booting right now. You need to copy the EFI to your internal disk's EFI partition so you can boot without the USB.

**Step 1: Mount the EFI partition of your internal disk**

In Terminal (macOS):

```bash
# Find your internal disk (usually disk0)
diskutil list

# Mount the EFI partition (usually disk0s1)
sudo diskutil mount /dev/disk0s1
```

> **WHY do I need to mount it?** The EFI partition is a special partition that macOS hides by default. It contains the bootloader. You need to mount it to copy OpenCore's files into it.

**Step 2: Copy EFI from USB to internal disk**

```bash
# Copy the entire EFI folder
sudo cp -R /Volumes/EFI/EFI /Volumes/EFI\ 1/
```

> **Or use Finder:** Open two Finder windows. One showing the USB's EFI partition (already mounted), one showing the internal EFI partition. Drag the `EFI` folder from USB to internal.

**Step 3: Verify the structure**

Make sure the internal EFI partition has this structure:

```
/dev/disk0s1 (EFI)
└── EFI
    ├── BOOT
    │   └── BOOTIA32.EFI
    └── OC
        ├── ACPI/
        ├── Drivers/
        ├── Kexts/
        ├── Resources/
        └── config.plist
```

### 10.2 Test Internal Boot (IMPORTANT — Don't Skip!)

Before removing the USB, test that the laptop can boot from the internal disk:

1. **Shut down** the laptop completely
2. **Remove the USB drive**
3. **Power on** the laptop
4. If it boots into macOS — **success!** The internal EFI is working.
5. If it doesn't boot — plug the USB back in, re-check the EFI copy, and try again.

> **WHY test this?** If you remove the USB and the internal EFI doesn't work, you'll be stuck with an unbootable laptop. Always test first.

### 10.3 Remove XhciPortLimit After USB Mapping

After you've created a proper USB port map, remove the temporary port limit:

```xml
<key>XhciPortLimit</key>
<false/>
```

### 10.4 Audio

If audio doesn't work, try different `alcid` values in boot-args:

| Layout ID | Notes |
|-----------|-------|
| `alcid=1` | Generic ALC282 |
| `alcid=2` | Generic ALC282 |
| `alcid=3` | Generic ALC282 |
| `alcid=13` | Dell-specific |
| `alcid=27` | Dell-specific |
| `alcid=29` | **What we used** — works on this laptop |

Edit boot-args in config.plist at `NVRAM → Add → 7C436110-AB2A-4BBB-A880-FE41995C9F82 → boot-args`.

### 10.5 WiFi

The Qualcomm Atheros AR9485 may need:

- **AirportItlwm.kext** (native WiFi support for Big Sur) — preferred
- **itlwm.kext** + **HeliPort.app** (alternative method)

Note: AR9485 support varies by macOS version. Big Sur should work with the right kext.

### 10.6 Ethernet

The Realtek RTL8100 should work with `RealtekRTL8100.kext` which is already in the EFI.

### 10.7 Brightness Control

Brightness keys should work with `BrightnessKeys.kext` + `SSDT-PNLF.aml` (both already in the EFI).

---

## 11. The Critical Fixes — Why They Work

This section explains **why** each fix is needed. Understanding this helps you debug if something goes wrong.

### 11.1 IA32 EFI (BOOTIA32.EFI)

The Dell 3521's firmware is 32-bit. It can only execute 32-bit EFI binaries. Standard OpenCore builds provide `BOOTx64.EFI` (64-bit) and `BOOTIA32.EFI` (32-bit). You must use the IA32 variant.

### 11.2 CPU Power Management

Ivy Bridge laptops have **locked MSR 0xE2 registers** — the BIOS prevents the OS from writing to them. macOS expects to manage CPU power states directly. These quirks work around the lock:

- `AppleCpuPmCfgLock` — allows macOS to manage CPU without unlocking BIOS
- `DummyPowerManagement` — prevents kernel panics from AppleIntelCPUPowerManagement
- `AppleXcpmExtraMsrs` — provides extra MSRs that Ivy Bridge needs
- `AppleXcpmCfgLock` — additional CFG lock bypass

### 11.3 ACPI Table Deletion

The Dell 3521's BIOS exposes `CpuPm` and `Cpu0Ist` ACPI tables. These conflict with macOS's own CPU power management. Deleting them forces macOS to use its own implementation.

### 11.4 HD 4000 Graphics

Intel HD 4000 requires specific framebuffer configuration:

- `ig-platform-id` `0x03006601` — tells macOS which framebuffer to use for HD 4000
- `device-id` `0x01660000` — spoofs the GPU device ID for compatibility
- `framebuffer-patch-enable` — enables framebuffer patching
- `igfxonln=1` boot arg — forces the GPU online (fixes black screen)
- `-igfxnohdmi` boot arg — disables HDMI to prevent conflicts

### 11.5 IMEI Spoof

The Intel Management Engine Interface (IMEI) device on Ivy Bridge laptops can cause "Missing Platform EFI" errors. Spoofing its device-id prevents this.

### 11.6 SecureBootModel = Disabled

macOS recovery images are not signed with Apple's Secure Boot keys. Disabling SecureBootModel allows OpenCore to load unsigned boot images.

### 11.7 Clear Misc Entries

Hardcoded device paths in `Misc.Entries` are fragile — they depend on exact USB port positions and GUIDs. Clearing entries and letting OpenCore auto-detect `com.apple.recovery.boot` is more reliable.

### 11.8 UpdateSMBIOSMode = Custom

The `Create` mode can corrupt SMBIOS data on Dell laptops. `Custom` mode preserves existing SMBIOS information while updating only what's needed.

---

## 12. PlatformInfo (SMBIOS)

### Why MacBookAir6,2

The MacBookAir6,2 is the closest real Mac to the Dell 3521's hardware:
- CPU: i5-3337U (Ivy Bridge) — matches
- GPU: HD 4000 — matches
- RAM: Up to 8GB DDR3 — matches
- Screen: 1366x768 — matches

### Example Serial Numbers

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
        <key>ProcessorType</key>
        <integer>1795</integer>
    </dict>
</dict>
```

> **IMPORTANT:** These are example serials from our build. **Generate your own** using GenSMBIOS to avoid iCloud conflicts. Never use someone else's serial numbers.

### How to Generate Your Own Serials

1. Open GenSMBIOS
2. Select `MacBookAir6,2`
3. Copy the generated MLB, Serial, and UUID into your config.plist
4. Do NOT use the "Check Coverage" feature — Apple may flag the serial

---

## 13. ESP Folder Structure

Here's the exact structure of our working EFI on the USB:

```
USB (F:\)
├── EFI/
│   ├── BOOT/
│   │   └── BOOTIA32.EFI              ← OpenCore.efi renamed (32-bit!)
│   └── OC/
│       ├── ACPI/
│       │   ├── SSDT-ALS0.aml
│       │   ├── SSDT-EC.aml
│       │   ├── SSDT-HPET.aml
│       │   ├── SSDT-IMEI.aml
│       │   ├── SSDT-MCHC.aml
│       │   ├── SSDT-PLUG.aml
│       │   ├── SSDT-PNLF.aml
│       │   ├── SSDT-SBUS.aml
│       │   └── SSDT-XOSI.aml
│       ├── Drivers/
│       │   ├── HfsPlus.efi
│       │   ├── OpenRuntime.efi
│       │   └── ResetNvramEntry.efi
│       ├── Kexts/
│       │   ├── AirportBrcmFixup.kext/
│       │   ├── AppleALC.kext/
│       │   ├── BrcmBluetoothInjector.kext/
│       │   ├── BrcmFirmwareData.kext/
│       │   ├── BrcmPatchRAM3.kext/
│       │   ├── BrightnessKeys.kext/
│       │   ├── ECEnabler.kext/
│       │   ├── Lilu.kext/
│       │   ├── RealtekCardReader.kext/
│       │   ├── RealtekCardReaderFriend.kext/
│       │   ├── RealtekRTL8100.kext/
│       │   ├── RestrictEvents.kext/
│       │   ├── SMCBatteryManager.kext/
│       │   ├── SMCDellSensors.kext/
│       │   ├── SMCLightSensor.kext/
│       │   ├── SMCProcessor.kext/
│       │   ├── SMCSuperIO.kext/
│       │   ├── UTBMap.kext/
│       │   ├── VirtualSMC.kext/
│       │   ├── VoodooPS2Controller.kext/
│       │   ├── VoodooRMI.kext/
│       │   ├── VoodooSMBus.kext/
│       │   └── WhateverGreen.kext/
│       ├── Resources/
│       │   ├── Audio/
│       │   ├── Font/
│       │   ├── Image/
│       │   └── Label/
│       ├── Tools/
│       └── config.plist
└── com.apple.recovery.boot/
    ├── BaseSystem.dmg                ← ~637 MB (not in git — too large)
    └── BaseSystem.chunklist          ← ~2.5 KB
```

---

## 14. Known Issues & Workarounds

### 14.1 OpenCanopy GUI Not Rendering

- **Problem:** The fancy graphical picker (OpenCanopy.efi) does not render on the Dell 3521's IA32 EFI
- **Symptom:** You see a text/CLI picker instead of icons
- **Workaround:** The CLI picker works fine — it's just less pretty
- **Possible cause:** IA32 compatibility issue with OpenCanopy's rendering engine
- **Status:** Not fixed — cosmetic issue only

### 14.2 USB Must Be GPT

- The Dell 3521's IA32 EFI reads GPT USBs much more reliably than MBR
- Always use GPT + FAT32 when formatting the USB
- Rufus makes this easy — just select "GPT" in the partition scheme

### 14.3 Recovery vs Install Media

- We used the **recovery method** (BaseSystem.dmg), not a full macOS installer
- Recovery is simpler (~637 MB vs ~5 GB) and works perfectly for first-time installs
- The full installer is not necessary for this laptop

### 14.4 BaseSystem.dmg Was a Directory (Not a File)

- **Problem:** During one USB build, `BaseSystem.dmg` was created as a directory instead of a flat file
- **Cause:** Incorrect robocopy source path — pointed to a directory instead of the file
- **Fix:** Verify `BaseSystem.dmg` is a flat file before copying. Check with `Get-Item BaseSystem.dmg | Select-Object PSIsContainer` — should be `False`

### 14.5 Robocopy "Directory Name is Invalid" Error

- **Problem:** `LAST_USB_BUILD.log` showed robocopy errors for BaseSystem.dmg: "The directory name is invalid"
- **Cause:** Same as above — robocopy was treating a file as a directory
- **Fix:** Use flat file copy for BaseSystem.dmg, not robocopy directory mirroring

---

## 15. Troubleshooting

### Boot Loop (Returns to Picker)

**Symptoms:** OpenCore shows the picker, you select "macOS Recovery", screen goes black, then returns to the picker.

**Fixes:**
- Verify `SecureBootModel = Disabled`
- Verify `DmgLoading = Signed` or `Any`
- Check that `BOOTIA32.EFI` exists in `EFI\BOOT\`
- Make sure USB is GPT + FAT32
- Press Spacebar in the picker to show hidden entries
- Try re-downloading the recovery with gibMacOS

### Kernel Panic on Boot

**Symptoms:** Text scrolls on screen, then the laptop reboots or shows a panic message.

**Fixes:**
- Boot with `-v debug=0x100 keepsyms=1` to see verbose output and panic details
- Take a photo of the panic message — the top line usually says what went wrong
- Common causes:
  - Missing `Lilu.kext` or `VirtualSMC.kext`
  - Wrong `ig-platform-id`
  - `AppleCpuPmCfgLock` not set to True
  - Missing `apfs_aligned.efi` driver

### Black Screen After Boot

**Symptoms:** Verbose text stops, screen goes black, but laptop stays on.

**Fixes:**
- Verify `AAPL,ig-platform-id` is `0x03006601` (base64: `BwAAEA==`)
- Ensure `WhateverGreen.kext` is loaded
- Add `igfxonln=1` to boot-args
- Add `-igfxnohdmi` to boot-args
- Try connecting an external monitor via VGA

### No WiFi

**Symptoms:** WiFi icon shows "No Hardware Installed" or similar.

**Fixes:**
- Use `AirportItlwm.kext` (native) or `itlwm.kext` + HeliPort app
- Make sure the kext version matches your macOS version
- AR9485 may need `itlwm` instead of `AirportItlwm` depending on the version

### No Audio

**Symptoms:** No sound from speakers or headphone jack.

**Fixes:**
- Try different `alcid` values: `1`, `2`, `3`, `13`, `27`, `29`
- Ensure `AppleALC.kext` is loaded
- Check System Preferences → Sound → Output

### USB Not Working

**Symptoms:** USB drives or keyboard/mouse not detected.

**Fixes:**
- Ensure `XhciPortLimit = True` during installation
- Create a proper USB port map with USBToolBox after installation
- The Dell 3521 typically has: 2x USB 3.0 (rear), 1x USB 2.0 (right side), 1x USB 2.0 (internal, webcam)

### Battery Status Not Showing

**Symptoms:** Battery percentage not shown in menu bar.

**Fixes:**
- Ensure `ECEnabler.kext` and `SMCBatteryManager.kext` are loaded
- Ensure `SSDT-EC.aml` is in ACPI

---

## 16. Tools & Resources Used

### Essential Tools

| Tool | What It Does | Location |
|------|--------------|----------|
| **OpenCore 1.0.5 IA32** | Bootloader | [GitHub](https://github.com/acidanthera/OpenCorePkg/releases) |
| **gibMacOS** | Downloads macOS Recovery | [GitHub](https://github.com/corpnewt/gibMacOS) |
| **ProperTree** | Edits config.plist | [GitHub](https://github.com/corpnewt/ProperTree) |
| **GenSMBIOS** | Generates serial numbers | [GitHub](https://github.com/corpnewt/GenSMBIOS) |
| **Rufus** | Formats USB as GPT FAT32 | [rufus.ie](https://rufus.ie) |
| **diskpart** | Windows disk partitioning | Built into Windows |
| **ocvalidate** | Validates config.plist | Inside OpenCore download |

### Custom Scripts (This Project)

| Script | What It Does |
|--------|--------------|
| `COPY_HAKINTOSH_USB.ps1` | Copies EFI + recovery to USB (FAT32), verifies files |
| `apply_theyronecodes_fixes.py` | Applies all config.plist fixes automatically |
| `check_gpt.py` | Verifies backup GPT table on disk via raw disk read |
| `format_usb.txt` | diskpart script: select disk 3, clean, convert gpt, format fat32 |
| `format_usb_disk3.txt` | diskpart script variant with letter=U |
| `create_part.txt` | diskpart: create partition + format (no clean) |

### Resources

| Resource | URL |
|----------|-----|
| Dortania OpenCore Install Guide | [dortania.github.io/OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/) |
| Dell 3521 Hackintosh Guide | [macOS on Dell Inspiron 3521](https://www.tonymacx86.com/threads/dell-inspiron-3521-macos-big-sur.316107/) |
| OpenCore Documentation | [dortania.github.io/docs](https://dortania.github.io/docs/latest/) |
| USBToolBox | [USBToolBox GitHub](https://github.com/USBToolBox/USBToolBox) |

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
- Re-format the USB with Rufus
- Verify `BOOTIA32.EFI` exists at `EFI\BOOT\BOOTIA32.EFI`

### Q: How do I update OpenCore in the future?

**A:** 
1. Download the latest OpenCore release
2. Extract the IA32 folder
3. Replace `EFI\BOOT\BOOTIA32.EFI` and `EFI\OC\OpenCore.efi` with the new versions
4. Copy any new kext versions
5. Re-apply config.plist changes (or use your existing config.plist — it should be compatible)
6. Run ocvalidate to check for errors

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

## Appendix: BIOS Settings Reference

| Setting | Value | How to Access |
|---------|-------|---------------|
| SATA Operation | AHCI | BIOS → System Configuration → SATA Operation |
| Secure Boot | Disabled | BIOS → Security → Secure Boot |
| Boot Mode | UEFI | BIOS → Boot Sequence → Boot List Option |
| Legacy Boot | Disabled | BIOS → Boot Sequence → Uncheck "Legacy" |
| VT-d | Disabled | BIOS → Advanced → (if available) |

---

## Appendix: File Checksums

After copying files to USB, verify critical files exist:

```bash
# On macOS/Linux, verify:
ls -la /Volumes/EFI/EFI/BOOT/BOOTIA32.EFI
ls -la /Volumes/EFI/EFI/OC/config.plist
ls -la /Volumes/EFI/com.apple.recovery.boot/BaseSystem.dmg
```

---

## Appendix: Diskpart Commands Reference

### Quick Format (Recommended)

```bash
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

```bash
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
