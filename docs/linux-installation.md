# 💾 Linux Installation Guide

This guide covers creating the USB installer on Linux (CachyOS/Arch/Ubuntu), BIOS configuration, and installing macOS Big Sur on your Dell 3521.

---

## 💾 Phase 1: Create USB Installer (Linux)

### Prerequisites

- Linux (CachyOS, Arch, Ubuntu, or similar)
- USB drive **≥16GB**
- sudo/root access
- OpCore-Simplify already run (EFI built)

### Step 1.1: Setup Environment

```bash
cd ~/Downloads/Dell-3521-Hackintosh
chmod +x scripts/setup_environment.sh
./scripts/setup_environment.sh
```

### Step 1.2: Build OpenCore EFI

```bash
chmod +x scripts/build_opencore.sh
./scripts/build_opencore.sh
```

Follow the OpCore-Simplify menu:
1. Select Hardware Report → `SysReport/Report.json`
2. Select macOS Big Sur 11
3. Skip ACPI customization (press Enter)
4. Select kexts: `1,2,3,4,6,8,11,12,17,21,22,23,41,42,44,45,64,65,75,76,80,81,82,84,85`
5. Select SMBIOS → `30. MacBookAir5,2`
6. Build EFI

### Step 1.3: Create USB Installer

**Option A: Using the Script (Recommended)**

```bash
chmod +x scripts/create_usb_installer.sh
./scripts/create_usb_installer.sh
```

**WARNING**: This will **ERASE ALL DATA** on the selected USB drive!

The script will:
- Show available disks with `lsblk`
- Prompt for USB device name (e.g., `sdc`)
- Require typing `YES` to confirm
- Zap existing partitions, create GPT
- Format as FAT32
- Copy EFI and recovery files

---

**Option B: Using GNOME Disks (GUI Method)**

For users who prefer a graphical interface:

1. Open **GNOME Disks** (or `gnome-disks`) from your application menu

2. Select your USB drive from the left panel

3. Click the **gear icon** → **Format Drive**
   - Partitioning: `GPT`
   - Click **Format**

4. Click the **+** button to create a partition:
   - Size: Use full capacity
   - Type: `FAT32`
   - Name: `OPENCORE`

5. Click **Create**

6. Mount the partition and copy files:
   ```bash
   # Find the partition (e.g., /dev/sdc1)
   lsblk
   
   # Mount
   mkdir -p /mnt/usb
   sudo mount /dev/sdc1 /mnt/usb
   
   # Copy EFI
   sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/usb/EFI/
   
   # Copy recovery
   sudo cp -r ~/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot /mnt/usb/
   
   # Sync and unmount
   sync
   sudo umount /mnt/usb
   ```

---

**Option C: Using dd Command (Manual)**

For advanced users comfortable with command-line:

```bash
# Identify your USB device
lsblk

# Unmount all partitions on the USB
sudo umount /dev/sdc*

# Create GPT partition table
sudo sgdisk -Z /dev/sdc     # Zap existing
sudo sgdisk -o /dev/sdc     # New GPT

# Create EFI partition (占据全部空间)
sudo sgdisk -n 1:0:0 -t 1:EF00 /dev/sdc

# Wait for partition to be created
sleep 2

# Format as FAT32
sudo mkfs.fat -F32 -s 1 -n "OPENCORE" /dev/sdc1

# Mount
mkdir -p /mnt/usb
sudo mount /dev/sdc1 /mnt/usb

# Copy files
sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/usb/EFI/
sudo cp -r ~/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot /mnt/usb/

# Verify
ls -la /mnt/usb/
ls -la /mnt/usb/EFI/
ls -la /mnt/usb/com.apple.recovery.boot/

# Unmount
sync
sudo umount /mnt/usb
rmdir /mnt/usb
```

---

**Option D: Using balenaEtcher (Cross-Platform GUI)**

If you have an existing macOS recovery image:

1. Download [balenaEtcher](https://www.balena.io/etcher/)
2. Select your macOS .img or .iso file
3. Select your USB drive
4. Click **Flash**
5. After flashing, mount the USB and update the EFI folder as shown in Option B/C above

---

## 🖥️ Phase 2: BIOS Configuration

### Enter BIOS
During boot, press **F2** to enter BIOS setup.

### Critical Settings

| Section | Setting | Value |
|---------|---------|-------|
| **System Configuration** | SATA Mode | **AHCI** (not RAID/Legacy) |
| **Security** | Secure Boot | **Disabled** ⚠️ CRITICAL |
| **Boot** | Boot List Option | **UEFI** |
| **Boot** | Fast Boot | **Disabled** |
| **Advanced** | Virtualization | Your preference |
| **Advanced** | VT-d | **Disabled** |
| **Advanced** | CFG Lock | **Disabled** (if available) |

**Save & Exit**: Press `F10` to save and reboot

---

## 🍎 Phase 3: Install macOS Big Sur

### Step 3.1: Boot from USB

1. Insert USB and boot Dell 3521
2. Press **F12** for boot menu
3. Select USB drive (UEFI: OPENCORE)
4. OpenCore picker appears

### Step 3.2: Boot macOS Recovery

1. Select **"macOS Recovery"** from OpenCore
2. Wait 2-5 minutes for recovery to load

### Step 3.3: Format Target Drive

1. Open **Disk Utility** from Utilities menu
2. View → Show All Devices
3. Select **internal drive** (NOT USB)
4. Click **Erase**:
   - **Name**: `Macintosh`
   - **Format**: **APFS**
   - **Scheme**: **GUID Partition Map**
5. Click Erase

### Step 3.4: Install macOS

1. Close Disk Utility
2. Select **Reinstall macOS Big Sur**
3. Choose formatted drive
4. Continue through installation
5. **Wait 40-60 minutes**
6. ⚠️ **DO NOT REBOOT** after completion!

---

## 💾 Phase 4: Transfer EFI to Internal Drive

**CRITICAL - Do this BEFORE rebooting!**

In macOS Recovery Terminal:

```bash
# View all disks
diskutil list

# Mount internal EFI (disk0s1 typically)
diskutil mount disk0s1

# Check mounted volumes
ls /Volumes/

# Copy EFI from USB to internal drive
# (USB is at /Volumes/OPENCORE/)
cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/

# Verify
ls /Volumes/EFI/EFI/

# Unmount
diskutil unmount disk0s1
```

Close Terminal and proceed.

---

## 🖥️ Phase 5: First Boot (Linux)

### Remove USB Drive

### Boot from Internal Drive

1. Press **F12** during boot
2. Select internal drive
3. OpenCore picker should show **"macOS"**
4. Select to boot

### Initial macOS Setup

Complete the setup wizard:
- Region and Language
- Keyboard Layout
- Apple ID (can skip)
- Privacy settings
- Create account

---

## 📋 Next Steps

After successful boot:

1. **[Post-Install Setup](post-install.md)** - Audio, USB, optimizations
2. **[Performance Tuning](performance.md)** - Benchmarks
3. **[Troubleshooting](troubleshooting.md)** - Common fixes

---

## 🔧 Linux-Specific Notes

### Disk Partitioning (Dual-Boot)

If dual-booting with Linux:

1. Install Linux first on separate partition
2. Linux will likely overwrite the EFI
3. After Linux install, mount EFI and re-copy OpenCore

### Accessing EFI from Linux

```bash
# Find EFI partition
sudo fdisk -l

# Mount EFI
sudo mkdir -p /mnt/efi
sudo mount /dev/sda1 /mnt/efi  # adjust device

# Edit EFI
sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/efi/EFI/
```

### GRUB Configuration

Add macOS to GRUB menu:

```bash
# Add to /etc/grub.d/40_custom
menuentry 'macOS Big Sur' {
    search --no-floppy --fs-uuid --set=root XXXX-XXXX
    chainloader /EFI/OC/OpenCore.efi
}
```

Then update GRUB:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## ⚠️ Common Issues on Linux

| Issue | Solution |
|-------|----------|
| USB not detected | Check USB 3.0 vs 2.0 port |
| Installation freeze | Disable VT-d in BIOS |
| No audio | Try AppleALC layout-id 1,2,3,7 |
| Wi-Fi not working | AR9485 needs IO80211ElCap.kext |
| EFI not persisting | Check Linux didn't overwrite EFI |