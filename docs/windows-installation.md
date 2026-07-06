# Windows Installation

## Step 1: Build EFI

```cmd
cd %USERPROFILE%\Downloads\Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
create_hardware_report.bat
build_opencore.bat
```

## Step 2: Create USB

**Option A: Script (Easy)**
```cmd
create_usb_installer.bat
```

**Option B: Rufus (Recommended)**
1. Download [Rufus](https://rufus.ie/)
2. Select USB, choose macOS image
3. Partition: **GPT**, Target: **UEFI**
4. Click Start
5. Copy `Output/EFI/` to USB's EFI folder
6. Copy `com.apple.recovery.boot/` to USB root

**Option C: Manual**
1. Open `diskmgmt.msc`
2. Delete USB partitions, create GPT
3. Format FAT32, label "OPENCORE"
4. Copy files manually

## Step 3: BIOS

Press **F2** on boot:

- **Secure Boot**: Disabled
- **SATA**: AHCI (not RAID)
- **Boot**: UEFI

Save (F10).

## Step 4: Install

1. Press **F12** → Select USB
2. OpenCore picker → **macOS Recovery**
3. **Disk Utility** → View → Show All Devices
4. Select drive → **Erase**
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