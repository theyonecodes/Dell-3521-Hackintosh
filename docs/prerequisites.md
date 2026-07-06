# Prerequisites

What you need before starting.

---

## Hardware

| Item | Requirement |
|------|-------------|
| Laptop | Dell Inspiron 3521 (i5-3337U) |
| RAM | 4GB minimum, 8GB recommended |
| Storage | 120GB+ SSD |
| USB | 16GB+ flash drive |

---

## Tools to Download

| Tool | Download | Purpose |
|------|----------|---------|
| OpCore-Simplify | [GitHub](https://github.com/lzhoang2801/OpCore-Simplify) | Build EFI |
| OpenCorePkg | [GitHub](https://github.com/acidanthera/OpenCorePkg) | macrecovery |
| ProperTree | [GitHub](https://github.com/corpnewt/ProperTree) | Edit config.plist |
| Rufus | [rufus.ie](https://rufus.ie/) | Create USB (Windows) |

### Folder Structure

```
~/Downloads/Hackintosh/
├── OpCore-Simplify/      # From lzhoang2801/OpCore-Simplify
├── OpenCorePkg/          # From acidanthera/OpenCorePkg
└── Dell-3521-Hackintosh/ # This repo
```

### Clone Commands

```bash
mkdir -p ~/Downloads/Hackintosh
cd ~/Downloads/Hackintosh

git clone https://github.com/lzhoang2801/OpCore-Simplify.git
git clone https://github.com/acidanthera/OpenCorePkg.git
git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
```

Windows: Download ZIP files from GitHub and extract to `Downloads\Hackintosh\`

---

## BIOS Settings

Press **DEL** on boot:

- **Secure Boot**: Disabled
- **SATA Mode**: AHCI (not RAID)
- **Boot**: UEFI

---

## What Gets Installed

| Component | Works with |
|-----------|-----------|
| CPU i5-3337U | MacBookAir5,2 SMBIOS |
| HD 4000 GPU | WhateverGreen |
| AR9485 Wi-Fi | IO80211ElCap |
| AR9462 Bluetooth | Ath3kBT |
| RTL8136 Ethernet | RealtekRTL8111 |
| Intel HD Audio | AppleALC |

---

## Before You Start

1. **Backup** important data
2. **BIOS settings** exported (if possible)
3. **Recovery USB** for existing OS (in case needed)
4. **60-90 minutes** for installation

---

## Next Steps

1. **[Hardware Validation](hardware-validation.md)** - Check your hardware
2. **[EFI Configuration](efi-configuration.md)** - Build EFI