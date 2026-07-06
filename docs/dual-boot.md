# 🔄 Dual-Boot Guide

This guide covers setting up dual-boot configurations for your Dell 3521 Hackintosh with Windows or Linux.

---

## 🪟 Windows + macOS Dual-Boot

### Recommended Partition Layout

| Partition | Size | File System | Purpose |
|-----------|------|-------------|---------|
| ESP (EFI) | 500MB | FAT32 | Bootloaders |
| Windows | ≥50GB | NTFS | Windows system |
| macOS | ≥60GB | APFS | macOS Big Sur |
| Data | Remaining | exFAT/FAT32 | Shared data |

### Step 1: Install Windows First

**Important**: Windows MUST be installed before macOS!

1. Boot into Windows installer (USB/DVD)
2. During installation, select "Custom: Advanced"
3. Create partitions:
   - ESP: 500MB
   - Windows: 50GB+ NTFS
   - Data: Remaining (can be formatted later)
4. Complete Windows installation

### Step 2: Install macOS

Follow the [Windows Installation Guide](windows-installation.md)

When partitioning:
1. Use Disk Utility to create macOS partition
2. Do NOT touch Windows partitions
3. macOS installer should detect Windows automatically

### Step 3: Configure Boot Manager

OpenCore will automatically detect Windows if:
- Both use same EFI partition
- ESP is shared between OSes

```
EFI/
├── OC/                    # OpenCore
├── Microsoft/             # Windows bootloader
└── BOOT/
    └── BOOTX64.efi       # Fallback
```

### Step 4: Boot Selection

1. Press **F12** on Dell 3521
2. Select boot device
3. Or use OpenCore picker (default boot device)

---

## 🐧 Linux + macOS Dual-Boot

### Recommended Partition Layout

| Partition | Size | File System | Purpose |
|-----------|------|-------------|---------|
| ESP (EFI) | 500MB | FAT32 | Bootloaders |
| Linux /boot | 1GB | ext4 | Linux boot |
| Linux / | 50GB+ | ext4 | Linux system |
| macOS | 60GB+ | APFS | macOS Big Sur |
| Swap | 8GB | swap | Linux swap |
| Data | Remaining | ext4/exFAT | Shared data |

### Step 1: Install Linux First

1. Boot into Linux live USB
2. During installation:
   - Use "Something Else" for partitioning
   - Create partitions manually
   - Assign mount points
   - Install bootloader to `/dev/sda` (whole disk, not partition)
3. Complete Linux installation

### Step 2: Create macOS Partition

1. Boot into Linux
2. Use `gparted` or `fdisk` to shrink Linux partition
3. Create unallocated space for macOS
4. Reboot to macOS recovery USB

### Step 3: Install macOS

Follow [Linux Installation Guide](linux-installation.md)

In Disk Utility:
1. Select unallocated space
2. Create APFS partition
3. Install macOS to new partition

### Step 4: Restore GRUB

Linux may overwrite EFI during install. To restore:

```bash
# Boot into Linux (may need to use recovery USB)
# Mount EFI
sudo mkdir -p /mnt/efi
sudo mount /dev/sda1 /mnt/efi

# Reinstall GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/efi --bootloader-id=GRUB

# Update GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Copy OpenCore to EFI
sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/efi/EFI/

# Update GRUB to add macOS entry
# Edit /etc/grub.d/40_custom:
menuentry 'macOS Big Sur' {
    search --no-floppy --fs-uuid --set=root $(blkid -s UUID -o value /dev/sda1)
    chainloader /EFI/OC/OpenCore.efi
}
```

### Step 5: Update GRUB

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Step 6: Verify OpenCore

1. Reboot
2. Enter BIOS (F2)
3. Set OpenCore as primary boot option
4. OpenCore picker should show both Linux and macOS

---

## 🔧 Sharing Data Between OSes

### Recommended: exFAT for Shared Partition

Create a data partition formatted as **exFAT**:
- Readable by macOS, Windows, Linux
- No driver installation needed (Linux needs exfat-utils)

### Linux exFAT Support

```bash
# Arch/CachyOS
sudo pacman -S exfatprogs

# Ubuntu/Debian
sudo apt install exfat-fuse exfat-utils
```

### Mount exFAT in Linux

```bash
sudo mkdir -p /mnt/data
sudo mount -t exfat /dev/sdaX /mnt/data
```

---

## ⏱️ Default Boot & Timeout

### Set Default Boot OS

Edit `config.plist` → `Misc` → `Boot`:

```xml
<key>DefaultBootEntry</key>
<integer>0</integer>  <!-- 0 = first entry (macOS) -->
```

### Change Boot Timeout

```xml
<key>Timeout</key>
<integer>10</integer>  <!-- seconds -->
```

---

## 🐛 Troubleshooting

### Windows overwrites EFI

**Problem**: Windows update or reset restores Windows boot manager

**Solution**:
1. Boot into Windows
2. Mount EFI: `mountvol X: /S`
3. Copy OpenCore files if missing
4. Or use BootCamp utility

### Linux overwrites EFI

**Problem**: `grub-install` overwrites EFI

**Solution**:
- Install GRUB to `/boot` not `/` (EFI partition)
- Or use rEFInd instead of GRUB

### OpenCore not showing Windows/Linux

**Problem**: Missing boot entries

**Solution**:
1. Boot into macOS
2. Mount EFI
3. Check EFI/OC/config.plist
4. Ensure `ScanPolicy` allows all loaders

### Can't boot either OS

**Problem**: Corrupted EFI

**Solution**:
1. Use Windows/Linux recovery USB
2. Mount EFI
3. Restore backup of EFI folder

---

## 📋 Quick Reference

| Action | Key/Command |
|--------|-------------|
| Boot menu | F12 |
| BIOS setup | F2 |
| macOS recovery | OpenCore picker |
| Windows recovery | F8 or recovery USB |
| Linux recovery | Live USB |

---

## 📝 Backup EFI

Always backup before making changes:

```bash
# Linux/macOS
cp -r /boot/EFI /path/to/backup/

# Or from Windows
xcopy /E /H /Y X:\EFI\ backup\
```