# Windows Installation

Guide for installing macOS Big Sur on Dell 3521 using Windows.

---

## Quick Start

### 1. Build EFI

```cmd
cd %USERPROFILE%\Downloads\Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
create_hardware_report.bat
build_opencore.bat
```

### 2. Create USB

**Option A: Script**
```cmd
create_usb_installer.bat
```

**Option B: Rufus (Recommended)**
1. Download [Rufus](https://rufus.ie/)
2. Select USB, choose macOS image
3. Partition: **GPT**, Target: **UEFI**
4. Click Start
5. Copy `Output\EFI\` to USB's EFI folder
6. Copy `com.apple.recovery.boot\` to USB root

**Option C: Manual**
```
diskmgmt.msc → Delete USB partitions → Create GPT → Format FAT32
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
4. Select drive → **Erase**
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

## Detailed USB Creation (Rufus)

1. Download [Rufus](https://rufus.ie/)
2. Launch Rufus (portable - no install needed)
3. **Device**: Select your USB (≥16GB)
4. **Boot selection**: Click `SELECT` → your macOS .iso or .img
5. **Partition scheme**: `GPT`
6. **Target system**: `UEFI (non-CSM)`
7. **File system**: `FAT32`
8. Click **START**
9. Wait for completion
10. Copy EFI folder to USB:
    ```
    Open File Explorer → USB drive → EFI folder
    Paste your built EFI from Output\EFI\ into here
    ```
11. Copy recovery folder:
    ```
    Copy com.apple.recovery.boot\ to USB root
    ```

### Final USB Structure
```
USB Drive (E:)/
├── EFI/
│   ├── BOOT/
│   └── OC/
└── com.apple.recovery.boot/
    ├── BaseSystem.chunklist
    └── BaseSystem.dmg
```

---

## BIOS Settings (Detailed)

Press **DEL** on boot to enter BIOS:

| Setting | Value | Why |
|---------|-------|-----|
| Secure Boot | **Disabled** | OpenCore won't boot with Secure Boot on |
| SATA Mode | **AHCI** | RAID mode not supported - must be AHCI |
| Boot List | **UEFI** | OpenCore is UEFI bootloader |
| Fast Boot | **Disabled** | Helps with debugging boot issues |

If no AHCI option, your drive may already be in AHCI mode.

---

## What If I Forget to Copy EFI?

Don't panic! Just:
1. Boot from USB again
2. Open Terminal in Recovery
3. Run the copy commands above
4. Reboot without USB

Your installation is NOT lost.

---

## Next Steps

- **[Post-Install](post-install.md)** - Audio, USB mapping
- **[Troubleshooting](troubleshooting.md)** - Common fixes