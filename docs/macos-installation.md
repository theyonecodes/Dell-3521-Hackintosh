# 💾 macOS Installation Guide

This guide covers creating the USB installer, BIOS configuration, macOS installation, and EFI transfer.

---

## 💾 Phase 1: Create USB Installer

### 1.1 Prepare USB Drive

⚠️ **WARNING**: This will **ERASE ALL DATA** on the USB drive!

```bash
# 1. Identify your USB device
lsblk

# Run BEFORE and AFTER plugging in USB to identify it
# Example: sdc (14.8G) is the USB

# 2. UNMOUNT any auto-mounted partitions
sudo umount /dev/sdc* 2>/dev/null || true

# Create fresh GPT partition table
sudo sgdisk -Z /dev/sdc   # Zap existing partitions
sudo sgdisk -o /dev/sdc   # Create new empty GPT

# Create single EFI partition
sudo sgdisk -n 1:0:0 -t 1:EF00 /dev/sdc

# Format as FAT32
sudo mkfs.fat -F32 -s 1 -n "OPENCORE" /dev/sdc1
```

### 4.2 Populate USB Drive

```bash
# Mount USB
mkdir -p /mnt/usb
sudo mount /dev/sdc1 /mnt/usb

# Create directories
sudo mkdir -p /mnt/usb/EFI

# Copy OpenCore EFI
sudo cp -r Results/EFI/* /mnt/usb/EFI/

# Copy macOS Recovery
sudo cp -r com.apple.recovery.boot /mnt/usb/

# Final structure:
# /mnt/usb/
# ├── EFI/
# │   ├── BOOT/
# │   └── OC/
# └── com.apple.recovery.boot/
#     ├── BaseSystem.chunklist
#     └── BaseSystem.dmg

# Sync and unmount
sync
sudo umount /mnt/usb
rmdir /mnt/usb
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