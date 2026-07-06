# Dell 3521 Hackintosh

macOS Big Sur 11.0 on Dell Inspiron 3521 (i5-3337U Ivy Bridge)

**SMBIOS**: MacBookAir5,2 | **OpenCore**: 0.7.8

## Hardware

| Component | Device ID | Kext |
|-----------|-----------|------|
| CPU | i5-3337U | MacBookAir5,2 |
| GPU | HD 4000 (8086-0166) | WhateverGreen |
| Wi-Fi | AR9485 (168C-0036) | IO80211ElCap |
| Bluetooth | AR9462 (0CF3-0036) | Ath3kBT |
| Ethernet | RTL8136 (10EC-8136) | RealtekRTL8111 |
| Audio | HD Audio (8086-1E20) | AppleALC |

## Quick Start

### Linux
```bash
git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
cd Dell-3521-Hackintosh
./scripts/setup_environment.sh
./scripts/create_hardware_report.sh
./scripts/build_opencore.sh
./scripts/create_usb_installer.sh
```

### Windows
```cmd
git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
cd Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
create_hardware_report.bat
build_opencore.bat
create_usb_installer.bat
```

## Installation

1. Create USB (see [macos-installation.md](docs/macos-installation.md))
2. BIOS: F2 → Disable Secure Boot, Set AHCI, UEFI
3. Boot: F12 → Select USB
4. OpenCore picker → macOS Recovery
5. Disk Utility → Erase drive (APFS, GUID)
6. Install macOS (40-60 min)
7. ⚠️ **Before reboot**: Copy EFI to internal drive
8. Boot from internal drive

## Docs

| Guide | Purpose |
|-------|---------|
| [prerequisites](docs/prerequisites.md) | What you need |
| [hardware](docs/hardware-validation.md) | Hardware checklist |
| [EFI](docs/efi-configuration.md) | Build OpenCore EFI |
| [Installation](docs/macos-installation.md) | USB + Install steps |
| [Post-Install](docs/post-install.md) | Audio, USB, tweaks |
| [Troubleshooting](docs/troubleshooting.md) | Common fixes |
| [FAQ](docs/faq.md) | Questions |

## USB Creation Options

| Method | Platform | Tool |
|--------|----------|------|
| Script | Linux/Windows | `create_usb_installer.sh/.bat` |
| Rufus | Windows | [rufus.ie](https://rufus.ie/) |
| GNOME Disks | Linux | GUI app |
| dd | Linux/macOS | Command line |
| BalenaEtcher | All | [balena.io](https://www.balena.io/etcher/) |

## Boot Keys

| Key | Action |
|-----|--------|
| F2 | BIOS |
| F12 | Boot menu |
| OpenCore picker | Select OS |

## What's Working

- CPU, GPU (HD 4000)
- Wi-Fi, Bluetooth
- Ethernet
- Audio (try layout 1,2,3,7)
- Battery, brightness
- Sleep/Wake
- USB (after mapping)

## Support

- [r/hackintosh](https://reddit.com/r/hackintosh/)
- [Dortania Discord](https://discord.gg/Wxam8aH)