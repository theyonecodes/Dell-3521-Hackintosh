# Linux Installation

## Step 1: Build EFI

```bash
cd ~/Downloads/Dell-3521-Hackintosh
chmod +x scripts/*.sh
./scripts/setup_environment.sh
./scripts/create_hardware_report.sh
./scripts/build_opencore.sh
```

## Step 2: Create USB

**Option A: Script (Easy)**
```bash
./scripts/create_usb_installer.sh
```

**Option B: GNOME Disks (GUI)**
1. Open **GNOME Disks**
2. Select USB → Format → GPT
3. Create FAT32 partition (name: OPENCORE)
4. Mount → Copy `Output/EFI/` to USB

**Option C: dd (Advanced)**
```bash
sudo dd if=macos.img of=/dev/sdX bs=4M status=progress
```

**Option D: BalenaEtcher**
1. Download [BalenaEtcher](https://www.balena.io/etcher/)
2. Select image → USB → Flash

## Step 3: BIOS

Press **F2** on boot:

| Setting | Value |
|---------|-------|
| SATA | **AHCI** |
| Secure Boot | **Disabled** |
| Boot | **UEFI** |
| VT-d | **Disabled** |

Save (F10).

## Step 4: Install

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

## Step 5: Copy EFI (Critical)

Before rebooting, in Recovery Terminal:

```bash
diskutil mount disk0s1
cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/
diskutil unmount disk0s1
```

## Step 6: First Boot

1. Remove USB
2. Press **F12** → Boot internal drive
3. Complete macOS setup

## Next Steps

- **[Post-Install](post-install.md)** - Audio, USB mapping
- **[Troubleshooting](troubleshooting.md)** - Common fixes