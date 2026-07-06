# EFI Configuration

## Quick Build

1. Launch OpCore-Simplify
2. Select Hardware Report
3. Select macOS Big Sur 11
4. Skip ACPI
5. Select Kexts: `1,2,3,4,6,8,11,12,17,21,22,23,41,42,44,45,64,65,75,76,80,81,82,84,85`
6. Select SMBIOS: **30. MacBookAir5,2**
7. Build EFI

## Kexts Required

| # | Kext | Purpose |
|---|------|---------|
| 1 | Lilu | Core framework |
| 2 | VirtualSMC | SMC emulator |
| 3 | SMCBatteryManager | Battery |
| 6 | SMCProcessor | CPU temps |
| 8 | SMCSuperIO | Fan/sensors |
| 11 | WhateverGreen | GPU |
| 12 | AppleALC | Audio |
| 17 | IO80211ElCap | Wi-Fi (Atheros) |
| 21 | Ath3kBT | Bluetooth |
| 22 | Ath3kBTInjector | Bluetooth |
| 41 | RealtekRTL8111 | Ethernet |
| 44 | USBToolBox | USB mapping |
| 45 | UTBDefault | USB temp fix |
| 64 | RealtekCardReader | SD card |
| 65 | RealtekCardReaderFriend | SD card |
| 75 | AppleMCEReporterDisabler | Fix panics |
| 76 | BrightnessKeys | Brightness |
| 80 | ECEnabler | Dell EC |
| 82 | HibernationFixup | Sleep fix |

## After Build

```
Output/EFI/
├── BOOT/
└── OC/
    ├── config.plist
    ├── Kexts/
    ├── Drivers/
    └── Tools/
```

## Post-Build

1. Copy EFI to `Output/EFI/`
2. Download macOS recovery via OpCore-Simplify
3. Create USB installer

## Next Steps

**[macOS Installation](macos-installation.md)** - Install macOS