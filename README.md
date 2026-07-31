# Dell Inspiron 3521 — Sequoia branch (WORK IN PROGRESS, NOT WORKING)

> **Status: NOT a working Sequoia build.** This branch is a half-finished attempt. Do **not** use it to install macOS Sequoia. For a **verified, working** Big Sur build on this laptop use the **BigSur** branch.

## Why this branch does not work

- The **OpenCore bootloader here is still 0.8.8** (byte-identical to the old Big Sur 0.8.8 build). OpenCore 0.8.8 **cannot boot macOS Sequoia** (Sequoia requires OpenCore ≥ 1.0.0).
- Only the **config.plist** was set up for a newer macOS: it includes `AMFIPass.kext`, `CryptexFixup.kext`, `RestrictEvents.kext`, `AppleIntelCPUPowerManagement*.kext`, the boot arg `ipc_control_port_options=0`, and SMBIOS `MacBookPro10,2`. None of that helps while the bootloader is 0.8.8.
- No test results are recorded — this branch has not been validated on real hardware.

The previous README on this branch was a copy of the old Big Sur 0.8.8 guide and did **not** describe this branch at all. It has been replaced with this honest summary.

## EFI Inventory (this branch)

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi            ← 0.8.8 (cannot boot Sequoia)
    ├── config.plist            ← SMBIOS MacBookPro10,2, newer-macOS kexts
    ├── ACPI/
    │   ├── SSDT-ALS0.aml
    │   ├── SSDT-EC.aml
    │   ├── SSDT-MCHC.aml
    │   ├── SSDT-PNLF.aml
    │   ├── SSDT-SBUS.aml
    │   └── SSDT-XOSI.aml
    ├── Drivers/
    │   ├── HfsPlus.efi
    │   ├── OpenRuntime.efi
    │   └── ResetNvramEntry.efi
    ├── Kexts/
    │   ├── AMFIPass.kext              ← OCLP-style (Sonoma/Sequoia)
    │   ├── AppleALC.kext
    │   ├── AppleIntelCPUPowerManagement.kext
    │   ├── AppleIntelCPUPowerManagementClient.kext
    │   ├── BrightnessKeys.kext
    │   ├── CryptexFixup.kext          ← OCLP-style
    │   ├── ECEnabler.kext
    │   ├── Lilu.kext
    │   ├── RealtekRTL8100.kext
    │   ├── RestrictEvents.kext        ← OCLP-style
    │   ├── SMCBatteryManager.kext
    │   ├── SMCDellSensors.kext
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBToolBox.kext
    │   ├── UTBMap.kext
    │   ├── VirtualSMC.kext
    │   ├── VoodooPS2Controller.kext
    │   └── WhateverGreen.kext
    └── Resources/                     ← OpenCanopy assets
```

## Configuration summary (as shipped)

| Item | Value |
|------|-------|
| **OpenCore** | 0.8.8 |
| **SMBIOS** | MacBookPro10,2 (stored MLB/SN/UUID) |
| **Boot args** | `-v debug=0x100 keepsyms=1 ipc_control_port_options=0` |
| **SecureBootModel** | Disabled |
| **UpdateSMBIOSMode** | Custom |

## What it would take to finish

1. Upgrade OpenCore to 1.0.x (replace `BOOTx64.efi` and `OpenCore.efi`, re-run `ocvalidate`).
2. Add the actual Sequoia GPU strategy for HD 4000 (OCLP-based patches) — not present.
3. Verify AMFIPass/CryptexFixup/RestrictEvents settings against an OCLP-assisted Sequoia guide.
4. Test end-to-end and record results.

Until then, use the **BigSur** branch (verified working).
