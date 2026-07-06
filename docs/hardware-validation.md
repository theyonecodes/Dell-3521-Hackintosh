# Hardware Validation

## Dell 3521 Expected Hardware

| Component | Device ID | Status |
|-----------|-----------|--------|
| CPU | i5-3337U | ✅ Ivy Bridge |
| GPU | Intel HD 4000 | ✅ 8086-0166 |
| Wi-Fi | Atheros AR9485 | ✅ 168C-0036 |
| Bluetooth | Atheros AR9462 | ✅ 0CF3-0036 |
| Ethernet | Realtek RTL8136 | ✅ 10EC-8136 |
| Audio | Intel HD Audio | ✅ 8086-1E20 |

## Quick Check

**Linux:**
```bash
# Check CPU
lscpu | grep -i "model name"
# Expected: Intel(R) Core(TM) i5-3337U

# Check GPU
lspci -nn | grep -i vga
# Expected: 8086:0166

# Check Wi-Fi
lspci -nn | grep -i network
# Expected: 168c:0036

# Check Bluetooth
lsusb | grep -i bluetooth
# Expected: 0cf3:0036
```

**Windows:**
```powershell
# Check all in Device Manager or run:
Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceID -like "*8086*"} | Select-Object DeviceID, FriendlyName
```

## What Works Out of the Box

| Feature | Kext Needed | Status |
|---------|-------------|--------|
| CPU | MacBookAir5,2 SMBIOS | ✅ |
| GPU | WhateverGreen | ✅ |
| Wi-Fi | IO80211ElCap | ✅ |
| Bluetooth | Ath3kBT | ✅ |
| Ethernet | RealtekRTL8111 | ✅ |
| Audio | AppleALC (try 1,2,3,7) | ✅ |
| Battery | SMCBatteryManager | ✅ |
| Brightness | BrightnessKeys | ✅ |

## Next Steps

**[EFI Configuration](efi-configuration.md)** - Build your EFI