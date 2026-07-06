# Linux Installation

Guide for installing macOS Big Sur on Dell 3521 using Linux.

---

## Quick Start

### 1. Build EFI

```bash
cd ~/Downloads/Dell-3521-Hackintosh
chmod +x scripts/*.sh
./scripts/setup_environment.sh
./scripts/create_hardware_report.sh
./scripts/build_opencore.sh
```

### 2. Create USB

**Option A: Script (Easiest)**
```bash
./scripts/create_usb_installer.sh
```

**Option B: GNOME Disks**
1. Open **GNOME Disks**
2. Select USB → Format → GPT
3. Create FAT32 partition (name: OPENCORE)
4. Mount → Copy `Output/EFI/` to USB

**Option C: dd**
```bash
sudo dd if=macos.img of=/dev/sdX bs=4M status=progress
```

### 3. BIOS

Press **DEL** on boot:

- **Secure Boot**: Disabled
- **SATA**: AHCI (not RAID)
- **Boot**: UEFI

### 4. Install

1. Press **F12** → Select USB
2. OpenCore → **macOS Recovery**
3. **Disk Utility** → View → Show All Devices
4. Drive → **Erase**
   - Name: `Macintosh`
   - Format: **APFS**
   - Scheme: **GUID**
5. **Reinstall macOS Big Sur**
6. Wait 40-60 minutes
7. ⚠️ **DO NOT REBOOT**

### 5. Copy EFI (Critical!)

Recovery Terminal:
```bash
diskutil mount disk0s1
cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/
diskutil unmount disk0s1
```

### 6. First Boot

1. Remove USB
2. Press **F12** → Boot internal drive
3. Complete macOS setup

---

## Detailed USB Creation

### Script Method

```bash
chmod +x scripts/create_usb_installer.sh
./scripts/create_usb_installer.sh
```

The script will:
1. List available disks (`lsblk`)
2. Ask for USB device name (e.g., `sdc`)
3. Require typing `YES` to confirm
4. Zap existing partitions
5. Create GPT partition table
6. Format as FAT32
7. Copy EFI and recovery files

### GNOME Disks Method

1. Open **GNOME Disks** (search "disks" in apps)
2. Select your USB from left panel
3. Click **gear icon** → **Format Drive**
4. Partitioning: **GPT** → Click **Format**
5. Click **+** to create partition:
   - Size: Use full capacity
   - Type: **FAT32**
   - Name: `OPENCORE`
6. Click **Create**
7. Mount the partition:
   ```bash
   sudo mount /dev/sdc1 /mnt/usb
   ```
8. Copy files:
   ```bash
   sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/usb/EFI/
   sudo cp -r ~/Downloads/Hackintosh/OpenCorePkg/Utilities/macrecovery/com.apple.recovery.boot /mnt/usb/
   ```
9. Unmount:
   ```bash
   sync
   sudo umount /mnt/usb
   ```

### dd Method

```bash
# Identify your USB
lsblk

# Unmount all partitions
sudo umount /dev/sdc*

# Write image (careful with device name!)
sudo dd if=macos-image.img of=/dev/sdc bs=4M status=progress
```

---

## Expected USB Structure

```
/dev/sdc (USB Drive)
└── sdc1 (FAT32, labeled "OPENCORE")
    ├── EFI/
    │   ├── BOOT/
    │   │   └── BOOTX64.efi
    │   └── OC/
    │       ├── OpenCore.efi
    │       ├── config.plist
    │       └── ...
    └── com.apple.recovery.boot/
        ├── BaseSystem.chunklist
        └── BaseSystem.dmg
```

---

## BIOS Settings (Detailed)

Press **DEL** on boot:

| Setting | Value | Why |
|---------|-------|-----|
| Secure Boot | **Disabled** | Required for OpenCore |
| SATA Mode | **AHCI** | RAID not supported |
| Boot | **UEFI** | OpenCore is UEFI only |
| VT-d | **Disabled** | Can cause boot issues |

---

## What If I Forget to Copy EFI?

Just boot from USB again → Open Terminal → Run copy commands → Reboot.

Your installation is safe.

---

## Next Steps

- **[Post-Install](post-install.md)** - Audio, USB mapping
- **[Troubleshooting](troubleshooting.md)** - Common fixes