# Post-Install Setup

Run these after first successful boot.

## Audio

No sound? Try layout-ids:

```bash
# Edit boot-args with ProperTree or in recovery:
alcid=1  # try 1, 2, 3, 7, 11, 13, 15
```

Test each layout-id until audio works.

## USB Mapping

### Using USBToolBox
1. Mount EFI: `diskutil mount disk0s1`
2. Open `/Volumes/EFI/OC/Tools/USBToolBox.app`
3. Click **Scan** → **Save** (UTBMap.kext to Desktop)
4. Replace `UTBDefault.kext` with `UTBMap.kext`

### If >15 Ports
Enable `XhciPortLimit` in Kernel → Quirks (via ProperTree)

## Enable TRIM

```bash
sudo trimforce enable
```

## Battery Calibration

```bash
# Full charge, then full discharge once
```

## Power Settings

```bash
sudo pmset -a sleep 10
sudo pmset -a disksleep 10
```

## Useful Apps

| App | Purpose |
|-----|---------|
| [MountEFI](https://github.com/corpnewt/MountEFI) | Mount EFI |
| [ProperTree](https://github.com/corpnewt/ProperTree) | Edit config |
| [Hackintool](https://github.com/headkaze/Hackintool) | System info |

## Final Checklist

- [ ] Audio works
- [ ] Wi-Fi connected
- [ ] Bluetooth works
- [ ] USB ports mapped
- [ ] Battery shows percentage
- [ ] Sleep/wake works
- [ ] TRIM enabled

## Next Steps

- **[Troubleshooting](troubleshooting.md)** - Common fixes