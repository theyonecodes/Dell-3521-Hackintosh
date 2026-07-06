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
| [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg) | Bootloader + macrecovery |
| [ProperTree](https://github.com/corpnewt/ProperTree) | Edit config.plist |
| [Rufus](https://rufus.ie/) (Windows) | Create USB |
| [BalenaEtcher](https://www.balena.io/etcher/) (Linux) | Create USB |

## Download Tools

**Clone repos to this structure:**

```bash
~/Downloads/Hackintosh/
├── OpCore-Simplify/      # From lzhoang2801/OpCore-Simplify
├── OpenCorePkg/          # From acidanthera/OpenCorePkg
└── Dell-3521-Hackintosh/ # This repo
```

**Commands:**
```bash
mkdir -p ~/Downloads/Hackintosh
cd ~/Downloads/Hackintosh

# Clone OpCore-Simplify
git clone https://github.com/lzhoang2801/OpCore-Simplify.git

# Clone OpenCorePkg (for macrecovery.py)
git clone https://github.com/acidanthera/OpenCorePkg.git
```

**Windows:** Download ZIP from GitHub and extract to `Downloads\Hackintosh\`

## BIOS Settings

Press **F2** on boot:

- **Secure Boot**: Disabled
- **SATA Mode**: AHCI (not RAID)
- **Boot**: UEFI

## Backup

- Back up important data before installing
- Export BIOS settings
- Create bootable recovery USB for your existing OS

## Next Steps

1. **[Hardware Validation](hardware-validation.md)** - Verify hardware
2. **[EFI Configuration](efi-configuration.md)** - Build EFI