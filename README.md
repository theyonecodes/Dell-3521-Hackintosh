# Dell 3521 Hackintosh

macOS Big Sur 11.x on Dell Inspiron 3521 (i5-3337U Ivy Bridge, HD 4000, 1366x768)

**SMBIOS**: MacBookPro10,2 | **OpenCore**: 1.0.5+ | **Metal**: Supported | **Big Sur**: 11.x

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

GPU `PciRoot(0x0)/Pci(0x2,0x0)` - framebuffer injected:

| Property | Value | Description |
|----------|-------|-------------|
| AAPL,ig-platform-id | `0x01660004` | HD 4000 mobile (LVDS+VGA+HDMI) |
| framebuffer-portcount | 2 | Dell 3521 has 2 video outputs |
| framebuffer-pipecount | 2 | 2 display pipes |
| framebuffer-memorycount | 2 | 2 memory entries |
| framebuffer-stolenmem | 64 MB | Matches BIOS DVMT allocation |
| framebuffer-unifiedmem | 1536 MB | Reported VRAM |
| framebuffer-con0-alldata | LVDS connector | Internal display patch |
| framebuffer-con1-alldata | VGA connector | External VGA patch |
| enable-hdmi20 | 1 | Enable HDMI 2.0 output |

> **Key fix**: portcount must be 2 (not 3). Dell 3521 has LVDS + VGA only.
> unifiedmem must be 1536 MB (not bytes). stolenmem must be 64 MB for locked DVMT BIOS.

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

## 🍎 Post-Installation (First macOS Session)

**Critical fixes to apply:**

1. **Audio Fix**
   - System Preferences → Sound → Output tab
   - Try different layout-IDs by editing `config.plist`:
   - `<key>layout-id</key><integer>1</integer>` (or 2, 3, 7)

2. **Bluetooth Fix (AR9462)**
   ```bash
   sudo kextcache -i /
   # Reboot
   ```

3. **Brightness Keys**
   - Fn+F5/F6 should work
   - If not: System Preferences → Displays → Brightness slider

4. **USB Mapping (Optional)**
   - If USB 3.0 ports show slow speeds:
   - Use USBToolBox from macOS
   - Create `UTBMap.kext`
   - Replace `UTBDefault.kext` in `EFI/OC/Kexts/`

5. **Sleep/Wake Fix (Optional)**
   - If laptop doesn't sleep properly:
   - Add `SSDT-PTSWAK.aml` or `SSDT-GPRW.aml` to `EFI/OC/ACPI/`

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
| **[Full Installation Guide](docs/full-installation-guide.md)** | **Complete step-by-step guide (recommended)** |
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

## 🔐 iMessage/FaceTime (Post-Install)

**Required before first login:**
```bash
# Generate unique MLB and ROM in config.plist
# SMBIOS → Generic:
# - SystemSerialNumber: [Unique 12-char]
# - SystemUUID: [Unique UUID]
# - MLB: [Unique 18-char]
# - ROM: [Your WiFi MAC or custom]

# Then:
sudo nvram boot-args="-v"
sudo rm -rf /Library/Preferences/com.apple.iCloud*
# Reboot and try signing in
```

## 🔄 System Updates

**Before updating macOS:**
1. Update OpenCore to latest version
2. Backup EFI folder
3. Disable non-Apple kexts in config.plist

**Big Sur Update Notes:**
- Kernel version 20.99.99 requires kext rebuild
- USB mapping may need refresh after major updates

## 📦 Recovery Partition

**Create recovery after installation:**
```bash
# Download Recovery Update from Apple
# Use OpenCore's builtin recovery support
# Or: createinstallmedia method
```

---

**Note**: This is a personal project. Use at your own risk. Backups recommended before installation.