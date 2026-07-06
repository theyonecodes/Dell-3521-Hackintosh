# 💾 macOS Installation Guide

This guide covers creating the USB installer, BIOS configuration, macOS installation, and EFI transfer.

---

## 💾 Phase 1: Create USB Installer

You have multiple options to create the USB installer. Choose the one that works best for you.

---

### Option A: Using the Script (Linux/macOS)

**Recommended for Linux users with the build environment set up:**

```bash
cd ~/Downloads/Dell-3521-Hackintosh
chmod +x scripts/create_usb_installer.sh
./scripts/create_usb_installer.sh
```

⚠️ **WARNING**: This will **ERASE ALL DATA** on the USB drive!

The script will:
- Show available disks with `lsblk`
- Prompt for USB device name (e.g., `sdc`)
- Require typing `YES` to confirm
- Zap existing partitions, create GPT
- Format as FAT32
- Copy EFI and recovery files

---

### Option B: Using Rufus (Windows)

[Rufus](https://rufus.ie/) is a fast, free USB formatter for Windows.

1. Download Rufus from https://rufus.ie/
2. Launch Rufus (portable - no install needed)
3. Configure:
   - **Device**: Select your USB (≥16GB)
   - **Boot selection**: Select your macOS .iso or .img file
   - **Partition scheme**: `GPT`
   - **Target system**: `UEFI (non-CSM)`
   - **File system**: `FAT32`
4. Click **START**
5. After completion, copy your OpenCore EFI to the USB's `EFI/` folder
6. Copy `com.apple.recovery.boot` to USB root

---

### Option C: Using GNOME Disks (Linux GUI)

1. Open **GNOME Disks** from your app menu
2. Select your USB drive
3. Click the gear icon → **Format Drive** (GPT)
4. Click **+** to create a partition (FAT32, name: OPENCORE)
5. Mount and copy files:
```bash
sudo mount /dev/sdc1 /mnt/usb
sudo cp -r Output/EFI/* /mnt/usb/EFI/
sudo cp -r com.apple.recovery.boot /mnt/usb/
sync && sudo umount /mnt/usb
```

---

### Option D: Manual Command Line (All Platforms)

**Linux:**
```bash
# Identify USB
lsblk

# Unmount
sudo umount /dev/sdc*

# Create GPT and partition
sudo sgdisk -Z /dev/sdc
sudo sgdisk -o /dev/sdc
sudo sgdisk -n 1:0:0 -t 1:EF00 /dev/sdc

# Format
sudo mkfs.fat -F32 -s 1 -n "OPENCORE" /dev/sdc1

# Mount and copy
mkdir -p /mnt/usb
sudo mount /dev/sdc1 /mnt/usb
sudo cp -r Output/EFI/* /mnt/usb/EFI/
sudo cp -r com.apple.recovery.boot /mnt/usb/
sync && sudo umount /mnt/usb
```

**Windows (Command Prompt as Admin):**
```cmd
diskpart
list disk
select disk X
clean
convert gpt
create partition primary size=500
format fs=fat32 quick label=OPENCORE
assign letter=Z
exit

xcopy /E /H /Y "Output\EFI\*" Z:\EFI\
xcopy /E /H /Y "com.apple.recovery.boot\" Z:\
```

**macOS:**
```bash
# Use Disk Utility or command line
diskutil list
diskutil eraseDisk FAT32 OPENCORE /dev/diskX
sudo mkdir -p /Volumes/OPENCORE
sudo mount -t msdos /dev/diskXs1 /Volumes/OPENCORE
cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /Volumes/OPENCORE/EFI/
cp -r ~/Downloads/OpCore/OpenCore-*/Utilities/macrecovery/com.apple.recovery.boot /Volumes/OPENCORE/
```

---

## 🖥️ BIOS Configuration

### Enter BIOS
During boot, press **F2** to enter BIOS setup.

### Critical Settings

| Section | Setting | Value |
|---------|---------|-------|
| **System Configuration** | SATA Mode | **AHCI** (not RAID/Legacy) |
| **Security** | Secure Boot | **Disabled** ⚠️ CRITICAL |
| **Boot** | Boot List Option | **UEFI** |
| **Boot** | Fast Boot | **Disabled** |
| **Advanced** | Virtualization | Enabled/Disabled |
| **Advanced** | VT-d | **Disabled** (may cause issues) |
| **Advanced** | CFG Lock | **Disabled** (if available) |

**Save & Exit**: Press `F10` to save changes and reboot

---

## 🖥️ Phase 2: Install macOS Big Sur

### 7.1 Boot from USB
1. Boot the system and press `F12` for boot menu
2. Select **USB drive** (UEFI: OPENCORE)
3. At OpenCore picker, select **"macOS Recovery"**

```mermaid
graph LR
    A[Power On] --> B[Press F12]
    B --> C[Select USB]
    C --> D[OpenCore Picker]
    D --> E[Boot macOS Recovery]
```

### 7.2 Format Target Drive
1. In macOS Utilities → **Disk Utility**
2. View → **Show All Devices**
3. Select your **internal drive** (NOT the USB)
4. Click **Erase**:
   - Name: `Macintosh`
   - Format: **APFS**
   - Scheme: **GUID Partition Map**

### 7.3 Install macOS
1. Exit Disk Utility
2. Select **Reinstall macOS Big Sur**
3. Select your formatted drive and continue
4. **Estimated time**: 40-60 minutes
5. **DO NOT REBOOT** when installation completes!

---

## Phase 3: Transfer EFI to Internal Drive (CRITICAL!)

**While still in macOS Recovery (before rebooting):**

```bash
# Open Terminal from Utilities menu

# List disks
diskutil list

# Mount internal EFI partition
# Typically disk0s1 (first internal drive's EFI)
diskutil mount disk0s1

# Verify
ls /Volumes/EFI

# Copy EFI from USB to internal
sudo cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/

# Unmount
diskutil unmount disk0s1
```

> ⚠️ **CRITICAL**: Do NOT reboot until EFI is copied to internal drive!

---

## 💾 Phase 4: First Boot & Initial Setup

1. Remove the USB drive
2. Boot normally (F12 → Select internal drive)
3. Complete macOS setup:
   - Region/Language
   - Keyboard layout
   - Apple ID (optional)
   - Privacy settings

---

## 🖥️ Post-Install Initial Configuration

```bash
# Check system info
uname -a
sysctl -n machdep.cpu.brand_string
kextstat | grep -E "Lilu|WhateverGreen|VirtualSMC"

# Check audio
# Try different AppleALC layout-ids if no sound:
# Add to boot-args: alcid=1 (try 1,2,3,7)
```

---

## 📋 Next Steps

📖 **[Post-Install Setup](post-install.md)** → 
Audio configuration, USB mapping, TRIM enablement, and final optimizations

```mermaid
flowchart LR
    A[💾 macOS Install] --> B[✨ Post-Install]
    B --> C[USB Mapping]
    C --> D[Final Optimization]
```