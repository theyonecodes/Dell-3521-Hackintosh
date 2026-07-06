# 💾 Windows Installation Guide

This guide covers creating the USB installer on Windows, BIOS configuration, and installing macOS Big Sur on your Dell 3521.

---

## 💾 Phase 1: Create USB Installer (Windows)

### Prerequisites

- Windows 10/11 installed
- USB drive **≥16GB**
- Administrator rights
- OpCore-Simplify already run (EFI built)

### Step 1.1: Run Environment Setup

```cmd
cd %USERPROFILE%\Downloads\Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
```

### Step 1.2: Build OpenCore EFI

```cmd
build_opencore.bat
```

Follow the on-screen instructions in OpCore-Simplify:
1. Select Hardware Report
2. Select macOS Big Sur 11
3. Skip ACPI customization
4. Select kexts (pre-configured list provided)
5. Select MacBookAir5,2 SMBIOS
6. Build EFI

### Step 1.3: Create USB Installer

```cmd
create_usb_installer.bat
```

**WARNING**: This will **ERASE ALL DATA** on the selected USB drive!

1. When prompted, select your USB drive letter
2. Confirm with `YES` when warned about data loss
3. Wait for diskpart to format and copy files

The script will:
- Clean and format USB as GPT with FAT32 EFI partition
- Copy OpenCore EFI files
- Copy macOS recovery image

---

## 🖥️ Phase 2: BIOS Configuration

### Enter BIOS
During boot, press **F2** to enter BIOS setup.

### Critical Settings

| Section | Setting | Value |
|---------|---------|-------|
| **System Configuration** | SATA Operation | **AHCI** (not RAID/Legacy) |
| **Security** | Secure Boot | **Disabled** ⚠️ CRITICAL |
| **Boot** | Boot List Option | **UEFI** |
| **Boot** | Fast Boot | **Disabled** |
| **Advanced** | Virtualization | Your preference |
| **Advanced** | VT-d | **Disabled** |

**Save & Exit**: Press `F10` to save changes and reboot

---

## 🍎 Phase 3: Install macOS Big Sur

### Step 3.1: Boot from USB

1. Power on the Dell 3521
2. Press **F12** for the boot menu
3. Select your USB drive (labeled "OPENCORE")
4. OpenCore picker will appear

### Step 3.2: Boot macOS Recovery

1. In OpenCore picker, select **"macOS Recovery"**
2. Wait for macOS Recovery to load (2-5 minutes)

### Step 3.3: Format Target Drive

1. From macOS Utilities, open **Disk Utility**
2. Click **View** → **Show All Devices**
3. Select your **internal SSD/HDD** (NOT the USB)
4. Click **Erase**:
   - **Name**: `Macintosh`
   - **Format**: **APFS**
   - **Scheme**: **GUID Partition Map**
5. Click **Erase** to confirm

### Step 3.4: Install macOS

1. Close Disk Utility
2. Select **Reinstall macOS Big Sur**
3. Choose your formatted drive
4. Click **Continue** and follow prompts
5. **Installation time**: 40-60 minutes
6. ⚠️ **DO NOT REBOOT** when installation completes!

---

## 💾 Phase 4: Transfer EFI to Internal Drive

**CRITICAL - Do this BEFORE rebooting!**

While still in macOS Recovery:

1. From the Utilities menu, open **Terminal**
2. Run these commands:

```bash
# List all disks
diskutil list

# Mount the internal EFI partition
# (usually disk0s1 for the main drive)
diskutil mount disk0s1

# Verify EFI mounted
ls /Volumes/EFI

# Copy OpenCore EFI from USB to internal drive
# (USB EFI is at /Volumes/OPENCORE/)
cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/

# Verify copy
ls /Volumes/EFI/EFI/

# Unmount internal EFI
diskutil unmount disk0s1
```

3. Close Terminal

---

## 🖥️ Phase 5: First Boot

1. **Remove the USB drive**
2. Press **F12** and boot from the internal drive
3. OpenCore picker should now show **"macOS"**
4. Select it and let macOS boot

### Initial Setup

Complete the macOS setup wizard:
- Region and Language
- Keyboard Layout
- Apple ID (optional - can skip)
- Privacy settings
- Create computer account

---

## 📋 Next Steps

After successful first boot:

1. **[Post-Install Setup](post-install.md)** - Audio, USB mapping, optimizations
2. **[Performance Tuning](performance.md)** - Benchmarks and optimization
3. **[Troubleshooting](troubleshooting.md)** - Common issues and solutions

---

## ⚠️ Common Issues on Windows

| Issue | Solution |
|-------|----------|
| USB not booting | Check BIOS boot order, ensure UEFI enabled |
| Disk not showing | Set SATA to AHCI in BIOS |
| Installation freezes | Disable VT-d in BIOS, add `-v` boot arg |
| No audio | Try layout-id 1,2,3, or 7 in config.plist |
| Wi-Fi not detected | AR9485 needs IO80211ElCap.kext |

---

## 📝 Alternative: Manual USB Creation

If the script fails, you can manually create the USB:

1. Open **Disk Management** (diskmgmt.msc)
2. Find your USB, delete all partitions
3. Create new GPT partition
4. Format as FAT32
5. Extract EFI files to the USB's EFI folder
6. Copy com.apple.recovery.boot folder