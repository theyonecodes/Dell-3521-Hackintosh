# macOS Installation Guide

Quick start guide for installing macOS Big Sur on Dell 3521.

---

## Step 1: Build EFI

**Linux:**
```bash
cd ~/Downloads/Dell-3521-Hackintosh
./scripts/setup_environment.sh
./scripts/create_hardware_report.sh
./scripts/build_opencore.sh
./scripts/create_usb_installer.sh
```

**Windows:**
```cmd
cd %USERPROFILE%\Downloads\Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
create_hardware_report.bat
build_opencore.bat
create_usb_installer.bat
```

---

## Step 2: Create USB (Pick One)

| Method | Platform | Steps |
|--------|----------|-------|
| **Script** | Linux/Windows | Run `create_usb_installer.sh` or `create_usb_installer.bat` |
| **Rufus** | Windows | Download Rufus → Select USB → Select macOS image → GPT/UEFI → Start |
| **GNOME Disks** | Linux | Format drive GPT → Create FAT32 partition → Copy EFI files |
| **dd** | Linux | `sudo dd if=image.img of=/dev/sdX bs=4M status=progress` |

After creating USB, copy `Output/EFI/` and `com.apple.recovery.boot/` to USB root.

---

## Step 3: BIOS Settings

Press **F2** on boot:

| Setting | Value |
|---------|-------|
| SATA Mode | **AHCI** |
| Secure Boot | **Disabled** |
| Boot List | **UEFI** |
| Fast Boot | **Disabled** |
| VT-d | **Disabled** |

Save (F10) and reboot.

---

## Step 4: Boot from USB

1. Press **F12** on boot
2. Select USB drive
3. OpenCore picker appears → Select **macOS Recovery**

---

## Step 5: Install macOS

1. **Disk Utility** → View → Show All Devices
2. Select your drive → **Erase**
   - Name: `Macintosh`
   - Format: **APFS**
   - Scheme: **GUID**
3. **Reinstall macOS Big Sur**
4. Wait 40-60 minutes
5. ⚠️ **DO NOT REBOOT yet!**

---

## Step 6: Copy EFI (CRITICAL!)

Before rebooting, in macOS Recovery Terminal:

```bash
diskutil mount disk0s1
cp -R /Volumes/OPENCORE/EFI /Volumes/EFI/
diskutil unmount disk0s1
```

---

## Step 7: First Boot

1. Remove USB
2. Press **F12** → Boot from internal drive
3. Complete macOS setup

---

## What's Next?

- **[Post-Install](post-install.md)** - Audio, USB mapping, optimizations
- **[Troubleshooting](troubleshooting.md)** - Common fixes