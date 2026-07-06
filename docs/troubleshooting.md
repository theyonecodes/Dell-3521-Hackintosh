# Troubleshooting

## Can't Boot

| Problem | Fix |
|---------|-----|
| Hangs at `apfs_module_start` | Ensure `ApfsDriverLoader.efi` in Drivers |
| Wrong SMBIOS | Use **MacBookAir5,2** |
| Secure Boot | Disable in BIOS |

## No Wi-Fi

| Cause | Fix |
|-------|-----|
| Wrong kext | Use **IO80211ElCap.kext** |
| Device ID wrong | Verify AR9485: `168c:0036` |

**Fix**: Add to boot-args: `airportatheros=1`

## No Bluetooth

| Cause | Fix |
|-------|-----|
| Missing kexts | Use **Ath3kBT.kext** + **Ath3kBTInjector.kext** |

**Fix**: Add to boot-args: `bluetoothio=1`

## No Audio

Try layout-ids: `1, 2, 3, 7, 11, 13, 15`

```bash
# Add to boot-args:
alcid=1
```

## USB Not Working

1. Run USBToolBox mapping
2. Replace `UTBDefault.kext` with `UTBMap.kext`
3. If still issues, enable `XhciPortLimit` in config

## Sleep/Wake Issues

| Issue | Fix |
|-------|-----|
| Won't sleep | Check `pmset -g assertions` |
| Black screen on wake | Add `darkwake=0` to boot-args |

## Battery Not Showing

Ensure `SMCBatteryManager.kext` is loaded and using **MacBookAir5,2** SMBIOS.

## No Brightness Control

Add `BrightnessKeys.kext` and ensure `ECEnabler.kext` is present.

## Diagnostic Commands

```bash
# Check kexts
kextstat | grep -v com.apple

# Check boot args
nvram boot-args

# Check power
pmset -g

# Check battery
pmset -g batt
```

## Still Stuck?

1. Enable verbose boot: Add `-v` to boot-args
2. Check [Dortania Guide](https://dortania.github.io/OpenCore-Install-Guide/)
3. Check [r/hackintosh](https://reddit.com/r/hackintosh/)