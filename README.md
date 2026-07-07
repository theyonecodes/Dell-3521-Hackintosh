# Dell 3521 Hackintosh

macOS Big Sur 11.0 on Dell Inspiron 3521 (i5-3337U Ivy Bridge)

**SMBIOS**: MacBookAir5,2 | **OpenCore**: 0.7.8 | **Metal**: Supported

## ⚡ Quick Start

### Prerequisites
- USB drive (16GB+) with FAT32 partition
- macOS recovery download (handled by scripts)
- Admin access on target machine

### Build & Create USB

**Linux:**
```bash
git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
cd Dell-3521-Hackintosh
chmod +x scripts/*.sh
./scripts/setup_environment.sh
./scripts/create_hardware_report.sh
./scripts/build_opencore.sh
./scripts/create_usb_installer.sh --force
```

**Windows:**
```cmd
git clone https://github.com/theyonecodes/Dell-3521-Hackintosh.git
cd Dell-3521-Hackintosh\scripts\windows
setup_environment.bat
create_hardware_report.bat
build_opencore.bat
create_usb_installer.bat
```

## 💻 Hardware Compatibility

| Component | Device ID | Status | Notes |
|-----------|-----------|--------|-------|
| CPU | i5-3337U (2C/4T) | ✅ Working | Ivy Bridge ULV |
| GPU | HD 4000 (8086-0166) | ✅ Working | QE/CI via WhateverGreen |
| Wi-Fi | AR9485 (168C-0036) | ✅ Working | IO80211ElCap |
| Bluetooth | AR9462 (0CF3-0036) | ✅ Working | Ath3kBT |
| Ethernet | RTL8111 (10EC-8136) | ✅ Working | RealtekRTL8111 |
| Audio | HD Audio (8086-1E20) | ✅ Working | Layout 1,2,3,7 |
| Battery | SMART Battery | ✅ Working | SMCBatteryManager |

## 🔧 BIOS Settings (Dell 3521)

1. **Press F2** at boot for BIOS Setup
2. **Disable** these options:
   - Secure Boot
   - Intel Fast Boot
   - Computrace
3. **Enable** these options:
   - SATA Operation → AHCI
   - UEFI Boot → Enabled
4. **Save** and exit (**F10**)

## 🖥️ Boot Process

1. **Insert USB** → Power on
2. **Press F12** for boot menu
3. **Select USB drive** (shows as "OpenCore")
4. **OpenCore Picker** appears → Select "macOS Big Sur Recovery"
5. **macOS Utilities** → Select utilities menu
6. **Disk Utility** → Erase internal drive:
   - Name: "Macintosh HD"
   - Format: "APFS"
   - Scheme: "GUID Partition Map"
7. **Install macOS** → Follow installer (40-60 min)
8. **Before first reboot**: Copy EFI from USB to internal drive

## 📁 EFI Structure

```
EFI/
├── BOOT/
│   └── BOOTx64.efi        # Bootloader entry point
└── OC/
    ├── config.plist       # Configuration (has recovery entry)
    ├── OpenCore.efi       # OpenCore bootloader
    ├── Kexts/             # Lilu, WhateverGreen, AppleALC, etc.
    ├── Drivers/           # HfsPlus, OpenRuntime, ResetNvramEntry
    ├── ACPI/              # SSDT-SBUS.aml, SSDT-EC.aml, SSDT-PLUG.aml
    └── Resources/         # Fonts, icons, labels
```

## ⚙️ Device Properties

GPU `PciRoot(0x0)/Pci(0x00,0x02)` - framebuffer injected:
```xml
<key>AAPL,ig-platform-id</key>
<data>CgBmAQ==</data>  <!-- 0x01660006 -->
```

## 🔁 First Boot Setup

After installation, install bootloader to internal drive:

```bash
# Mount EFI partition
sudo diskutil mount disk0s1

# Copy EFI from USB to internal drive
sudo cp -r /Volumes/NO\ NAME/EFI /Volumes/EFI/

# Unmount
sudo diskutil unmount disk0s1
```

## 🛠️ Post-Install

See [Post-Install Guide](docs/post-install.md) for:
- Audio configuration (layout IDs: 1, 2, 3, 7)
- USB port mapping
- Brightness keys
- Battery optimization

## 🆘 Troubleshooting

**"NO NAME" in OpenCore** → Add recovery entry to config.plist:
```xml
<key>Entries</key>
<array>
    <dict>
        <key>Path</key>
        <string>com.apple.recovery.boot/BaseSystem.dmg</string>
        <key>Enabled</key><true/>
        <key>FullTitle</key>
        <string>macOS Big Sur Recovery</string>
    </dict>
</array>
```

See [Troubleshooting Guide](docs/troubleshooting.md) for more fixes.

## 📚 Documentation

| Guide | Purpose |
|-------|---------|
| [Prerequisites](docs/prerequisites.md) | Tools & requirements |
| [Installation](docs/macos-installation.md) | USB creation & install |
| [Post-Install](docs/post-install.md) | Fixes after macOS |
| [UEFI Config](docs/efi-configuration.md) | config.plist options |
| [Troubleshooting](docs/troubleshooting.md) | Common issues |
| [FAQ](docs/faq.md) | Questions & answers |

## 🤝 Support

- [r/hackintosh](https://reddit.com/r/hackintosh/)
- [Dortania Discord](https://discord.gg/Wxam8aH)
- [Acidanthera GitHub](https://github.com/acidanthera)

---

**Note**: This is a personal project. Use at your own risk. Backups recommended before installation.