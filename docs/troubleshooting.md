# 🐞 Troubleshooting

Common issues and solutions for your Dell 3521 Hackintosh.

---

## 🚫 Boot Issues

### Boot Failure: Hangs at `[EB|#LOG:EXITBS:START]`

**Symptoms**: Boot hangs at ExitBootServices

| Cause | Solution |
|-------|----------|
| Wrong SMBIOS | Ensure **MacBookAir5,2** is selected |
| Device ID mismatch | Verify all Device IDs in config.plist match hardware |
| Missing kexts | Ensure Lilu, VirtualSMC, WhateverGreen are loaded |

### Boot Failure: Stuck at `apfs_module_start`

| Cause | Solution |
|-------|----------|
| APFS driver missing | Ensure `ApfsDriverLoader.efi` is in Drivers/ |
| Wrong SMBIOS | Use MacBookAir5,2 for Ivy Bridge ULV |

### Kernel Panic on Boot

| Panic Type | Solution |
|------------|----------|
| `AppleIntelCPUPowerManagement` | Add `AppleIntelCPUPowerManagement.kext` block or use `SSDT-PM` |
| `AppleIntelCPUPowerManagementClient` | Same as above |
| `AppleMCEReporter` | Ensure `AppleMCEReporterDisabler.kext` is loaded |
| `USB` related | Ensure `UTBDefault.kext` or `UTBMap.kext` is present |

### Stuck at `apfs_module_start` / `apfs_module_stop`

| Cause | Solution |
|-------|----------|
| Missing APFS driver | Ensure `ApfsDriverLoader.efi` in `Drivers/` |
| Secure Boot not disabled | Disable Secure Boot in BIOS |

---

## 📶 Wi-Fi Issues

### No Wi-Fi / `en0` Missing

| Cause | Solution |
|-------|----------|
| Wrong kext | Use **IO80211ElCap.kext** (not AirportItlwm) |
| Wrong Device ID | Verify Wi-Fi is **168C:0036** (AR9485) |
| Kext not loading | Check `kextstat \| grep -i airport` |

**Fix**: Add to boot-args: `airportatheros=1`

### Wi-Fi Drops/Unstable

| Cause | Solution |
|-------|----------|
| Power management | Add `airportatheros=1` boot-arg |
| Antenna disconnected | Check internal antenna cables |

---

## 🔊 Audio Issues

### No Audio Output

| Cause | Solution |
|-------|----------|
| Wrong layout-id | Try `alcid=1,2,3,7,11,13,15` in boot-args |
| Wrong Device ID | Verify Audio is `8086-1E20` |
| AppleALC not loading | Check `kextstat \| grep -i appalc` |

**Test layout-ids in order**: `1, 2, 3, 7, 11, 13, 15`

```bash
# Test by adding to boot-args:
alcid=1
```

### Audio Crackling/Distortion

| Cause | Solution |
|-------|----------|
| Wrong layout-id | Try different layout-id |
| Power management | Add `alcid=1` and ensure `AppleALC` is latest |

---

## 📶 Bluetooth Issues

### Bluetooth Not Working

| Cause | Solution |
|-------|----------|
| Wrong kexts | Ensure `Ath3kBT.kext` + `Ath3kBTInjector.kext` |
| Firmware not loading | Add `bluetoothio=1` to boot-args |
| Device ID mismatch | Verify Bluetooth is `0CF3:0036` (AR9462) |

**Fix**: Add to boot-args: `bluetoothio=1`

### Bluetooth Drops/Unstable

| Cause | Solution |
|-------|----------|
| Firmware not persisting | Ensure both `Ath3kBT.kext` + `Ath3kBTInjector.kext` |
| Power management | Add `bluetoothio=1` |

---

## 🎧 Audio Issues

### No Audio Input (Microphone)

| Cause | Solution |
|-------|----------|
| Wrong layout-id | Try layout-id 1, 2, 3, 7 |
| Missing `alcid` | Add `alcid=1` to boot-args |

### Audio Crackling/Popping

| Cause | Solution |
|-------|----------|
| Power management | Disable `AppleIntelCPUPowerManagement` if causing issues |
| Sample rate mismatch | Check Audio MIDI Setup → Format: 44.1kHz/48kHz |

---

## 📶 Ethernet Issues

### No Ethernet / Not Detected

| Cause | Solution |
|-------|----------|
| Wrong kext | Use **RealtekRTL8111.kext** (not RTL8100) |
| Wrong Device ID | Verify Ethernet is `10EC:8136` |
| Driver not loading | Check `kextstat \| grep -i realtek` |

**Fix**: Use `RealtekRTL8111.kext` (option 42) instead of `RealtekRTL8100.kext`

---

## 🔌 USB Issues

### Some USB Ports Not Working

| Cause | Solution |
|-------|----------|
| Port limit exceeded | Run USBToolBox mapping |
| UTBDefault still present | Replace with `UTBMap.kext` |
| Port limit exceeded | Enable `XhciPortLimit` in Kernel → Quirks |

### USB 3.0 Not Working

| Cause | Solution |
|-------|----------|
| xHCI not enabled | Ensure `USBToolBox.kext` is loaded |
| Wrong mapping | Re-run USBToolBox mapping |

### USB Devices Disconnect on Sleep

| Cause | Solution |
|-------|----------|
| Power management | Disable `XhciPortLimit` after mapping |
| Power settings | Check `pmset -g` for aggressive sleep settings |

---

## 💤 Sleep/Wake Issues

### System Won't Sleep

| Cause | Solution |
|-------|----------|
| USB devices preventing sleep | Check `pmset -g assertions` |
| Bluetooth preventing sleep | Disable Bluetooth or add `bluetoothio=1` |
| Network activity | Disable "Wake for network access" in Energy Saver |

### System Won't Wake / Black Screen on Wake

| Cause | Solution |
|-------|----------|
| Wrong SMBIOS | Ensure MacBookAir5,2 |
| Graphics | Ensure ECEnabler missing | Enable `ECEnabler.kext` |
| `HibernationFixup.kext` missing | Add `HibernationFixup.kext` |

### Sleep Works but Wake Fails

| Cause | Solution |
|-------|----------|
| Darkwake issues | Add `darkwake=0` to boot-args |
| USB devices | Unplug all USB devices before sleep |

---

## 🔋 Battery Issues

### Battery Not Showing / Wrong Percentage

| Cause | Solution |
|-------|----------|
| Missing SMCBatteryManager | Ensure `SMCBatteryManager.kext` is loaded |
| Wrong SMBIOS | Use `MacBookAir5,2` |

### Battery Draining Fast

| Cause | Solution |
|-------|----------|
| Wrong power management | Verify `MacBookAir5,2` SMBIOS |
| Discrete GPU active | Verify iGPU only (no dGPU) |
| Background processes | Check Activity Monitor |

---

## 🖥️ Display Issues

### No Brightness Control

| Cause | Solution |
|-------|----------|
| Missing BrightnessKeys.kext | Add `BrightnessKeys.kext` |
| Wrong SMBIOS | Use `MacBookAir5,2` |
| Missing `PNLF` patch | Add SSDT-PNLF.aml to ACPI |

### Wrong Resolution / Scaling

| Cause | Solution |
|-------|----------|
| Missing display properties | Add display properties in config.plist |
| Missing `AAPL,ig-platform-id` | Ensure correct ig-platform-id in DeviceProperties |

### External Monitor Not Working

| Cause | Solution |
|-------|----------|
| HDMI/DP not configured | Add display properties in config.plist |
| Wrong connector type | Set correct connector type in DeviceProperties |

---

## 🖱️ Trackpad/Keyboard Issues

### Trackpad Not Working

| Cause | Solution |
|-------|----------|
| Missing VoodooPS2Controller | Add `VoodooPS2Controller.kext` |
| Missing VoodooI2C | Add `VoodooI2C.kext` + satellite kexts |

### Keyboard Shortcuts Not Working

| Cause | Solution |
|-------|----------|
| Missing keyboard mapping | Check Karabiner-Elements |

---

## 🌡️ Thermal/Overheating

### High Temperatures

| Cause | Solution |
|-------|----------|
| Wrong SMBIOS | Use `MacBookAir5,2` for ULV CPU |
| Missing CPU power management | Verify `SSDT-PM.aml` or `CPUFriend` |
| Fan not spinning | Add `SMCDellSensors.kext` + `SMCSuperIO.kext` |

### Fan Running Constantly

| Cause | Solution |
|-------|----------|
| Wrong thermal profile | Check `SMCDellSensors.kext` |
| Missing EC control | Add `ECEnabler.kext` |

---

## 🔄 Update Issues

### macOS Update Breaks Boot

| Prevention | Solution |
|------------|----------|
| Use `Update` not `Upgrade` | Use System Preferences → Software Update |
| Keep EFI backup | Always backup EFI before updates |
| Check kext compatibility | Update kexts before macOS update |

### After Update: No Boot

| Recovery | Steps |
|----------|-------|
| Boot from USB | Use backup USB installer |
| Rebuild kextcache | `sudo kextcache -i /` in Terminal |
| Restore EFI | Copy backup EFI to internal drive |

---

## 🛠️ Diagnostic Commands

```bash
# Check loaded kexts
kextstat | grep -v com.apple

# Check boot arguments
nvram boot-args

# Check NVRAM variables
nvram -p

# Check power management
pmset -g

# Check disk health
diskutil list
diskutil verifyVolume /

# Check boot logs
log show --predicate 'eventMessage contains "kernel"' --last 1h

# Check kext loading
kextstat | grep -v com.apple | sort

# Check specific hardware
system_profiler SPHardwareDataType
system_profiler SPBluetoothDataType
system_profiler SPAudioDataType
system_profiler SPNetworkDataType
system_profiler SPPowerDataType
system_profiler SPUSBDataType
```

---

## 🆘 Still Stuck?

### Before Asking for Help:

1. **Read the [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)**
2. **Search existing issues** on GitHub
3. **Gather diagnostic info**:
   - `EFI/OC/config.plist` (sanitized)
   - `kextstat | grep -v com.apple`
   - `bdmesg` output (from OpenCore boot)
   - `system_profiler SPHardwareDataType`

### Where to Get Help

- [r/hackintosh](https://www.reddit.com/r/hackintosh/)
- [Dortania Discord](https://discord.gg/Wxam8aH)
- [OpenCore GitHub Discussions](https://github.com/acidanthera/OpenCorePkg/discussions)
- [TonyMacx86](https://www.tonymacx86.com/)

---

## 📋 Quick Diagnostic Checklist

```bash
# Run this diagnostic script
cat > diagnose.sh << 'EOF'
#!/bin/bash
echo "=== System Info ==="
uname -a
sysctl -n machdep.cpu.brand_string
system_profiler SPHardwareDataType | grep -E "Model|Processor|Memory"

echo -e "\n=== Boot Args ==="
nvram boot-args

echo -e "\n=== Loaded Kexts ==="
kextstat | grep -v com.apple | sort

echo -e "\n=== Boot Args ==="
nvram boot-args

echo -e "\n=== Network ==="
networksetup -listallhardwareports

echo -e "\n=== Battery ==="
pmset -g batt

echo -e "\n=== USB ==="
system_profiler SPUSBDataType | grep -E "Device|Product|Speed"

echo -e "\n=== Audio ==="
system_profiler SPAudioDataType | grep -A5 "Output Device\|Input Device"

echo -e "\n=== Bluetooth ==="
system_profiler SPBluetoothDataType | grep -A5 "Apple Bluetooth"
EOF
chmod +x diagnose.sh
./diagnose.sh
```

---

## 🚀 Next Steps

📖 **[FAQ](faq.md)** → 
Common questions and answers about your Hackintosh.

```mermaid
flowchart LR
    A[🐞 Troubleshooting] --> B[❓ FAQ]
    B --> C[Enjoy macOS]
```