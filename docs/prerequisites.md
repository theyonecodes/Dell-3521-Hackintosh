# Prerequisites

## Hardware Needed

| Item | Requirement |
|------|-------------|
| Laptop | Dell Inspiron 3521 (or similar Ivy Bridge) |
| CPU | Intel i5-3337U (Ivy Bridge) |
| RAM | 4GB minimum, 8GB recommended |
| Storage | 120GB+ SSD |
| USB | 16GB+ flash drive |

## Software Needed

| Tool | Purpose |
|------|---------|
| [OpCore-Simplify](https://github.com/lzhoang2801/OpCore-Simplify) | Build EFI |
| [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) | Bootloader |
| [ProperTree](https://github.com/corpnewt/ProperTree) | Edit config.plist |
| [Rufus](https://rufus.ie/) (Windows) | Create USB |
| [BalenaEtcher](https://www.balena.io/etcher/) (Linux) | Create USB |

## Quick Setup

**Linux:**
```bash
git clone https://github.com/lzhoang2801/OpCore-Simplify.git ~/Hackintosh/OpCore-Simplify
cd ~/Hackintosh/OpCore-Simplify
./OpCore-Simplify.py
```

**Windows:**
1. Download OpCore-Simplify from GitHub
2. Extract to `Downloads\Hackintosh\`
3. Run `OpCore-Simplify.bat`

## BIOS Settings

Press **F2** on boot:

| Setting | Value |
|---------|-------|
| Secure Boot | **Disabled** |
| SATA Mode | **AHCI** |
| Boot List | **UEFI** |

## Backup

- Back up important data before installing
- Export BIOS settings
- Create bootable recovery USB for your existing OS

## Next Steps

1. **[Hardware Validation](hardware-validation.md)** - Verify hardware
2. **[EFI Configuration](efi-configuration.md)** - Build EFI