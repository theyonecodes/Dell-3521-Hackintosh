# macOS Monterey on Dell Inspiron 3521 — EXPERIMENTAL / NOT VERIFIED

> **Status: NOT VERIFIED.** This branch is a work in progress. The EFI and this guide have **not** been confirmed to work on real hardware, and the config is internally inconsistent (see below). For a **verified, working** Big Sur build on this laptop use the **BigSur** branch.

## What's in this branch

This branch contains a Monterey-oriented OpenCore EFI, but with significant gaps:

- **SMBIOS in `config.plist` is `MacPro6,1`** (with stored MLB/SystemSerialNumber/SystemUUID), **not** a laptop SMBIOS. The previous README claimed `MacBookAir5,2` — that does **not** match the config. A `MacPro6,1` SMBIOS is wrong for a laptop and will break battery/power management and likely sleep. This needs to be corrected and the build retested before it can be trusted.
- **OpenCore version is unverifiable from the binary.** The previous README claimed 1.0.7. The `OpenCore.efi` here is 581632 bytes (same size as the 0.8.8 build) but its MD5 does not match 0.8.8 or 1.0.7 — treat the version as unknown until verified with `ocvalidate` from the matching OpenCorePkg release.
- **Hardware claims are unconfirmed.** The previous README asserted a Core i5-3337U CPU and a Broadcom BCM94352Z WiFi/Bluetooth card swap (stock Atheros AR9560 removed). These were not verified. The kext set does require a Broadcom card (see below), so the swap may be real — but confirm before following this branch.
- Internal contradiction in the old guide: it said `XhciPortLimit` is "enabled in this config" and later "already removed in this config". The config currently has **`XhciPortLimit = true`** (with `USBInjectAll.kext`).

## Requirements implied by this EFI

- **WiFi/Bluetooth:** the Broadcom kexts (`AirportBrcmFixup.kext`, `BrcmPatchRAM3.kext`, `BrcmFirmwareData.kext`, `BrcmBluetoothInjector.kext`) mean a Broadcom card (e.g. BCM94352-family, or BCM94360CS2) must be installed. The stock Atheros AR9560 has **no** Monterey driver.
- **Trackpad:** `VoodooRMI.kext` + `VoodooSMBus.kext` are for the PS/2/SMBus touchpad.
- **Monterey GPU:** HD 4000 has no native Monterey driver — this build would require OCLP-based GPU patches to work. **No OCLP patches are present in this branch**, so it will likely fail to get accelerated graphics.

## EFI Inventory (this branch)

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi            ← version unverified (581632 bytes)
    ├── config.plist            ← SMBIOS MacPro6,1, XhciPortLimit on
    ├── ACPI/
    │   ├── SSDT-EC-LAPTOP.aml
    │   ├── SSDT-HPET.aml
    │   ├── SSDT-PM.aml
    │   ├── SSDT-PNLF.aml
    │   └── SSDT-XOSI.aml
    ├── Drivers/
    │   ├── OpenHfsPlus.efi
    │   ├── OpenPartitionDxe.efi
    │   ├── OpenRuntime.efi
    │   ├── Ps2KeyboardDxe.efi
    │   ├── Ps2MouseDxe.efi
    │   └── UsbMouseDxe.efi
    ├── Kexts/
    │   ├── AirportBrcmFixup.kext    ← Broadcom WiFi
    │   ├── AppleALC.kext            ← audio
    │   ├── BrcmBluetoothInjector.kext
    │   ├── BrcmFirmwareData.kext
    │   ├── BrcmFirmwareRepo.kext
    │   ├── BrcmPatchRAM3.kext       ← Broadcom BT firmware patch
    │   ├── Lilu.kext
    │   ├── RealtekRTL8100.kext      ← RTL8101E Ethernet
    │   ├── SMCBatteryManager.kext
    │   ├── SMCDellSensors.kext
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBInjectAll.kext        ← USB injection (XhciPortLimit on)
    │   ├── VirtualSMC.kext
    │   ├── VoodooPS2Controller.kext ← keyboard/trackpad
    │   ├── VoodooRMI.kext           ← touchpad
    │   ├── VoodooSMBus.kext
    │   └── WhateverGreen.kext
    └── Tools/
        ├── CleanNvram.efi
        ├── ControlMsrE2.efi
        └── OpenShell.efi
```

## Configuration summary (as shipped)

| Item | Value |
|------|-------|
| **SMBIOS** | MacPro6,1 (stored MLB/SN/UUID) — likely wrong for a laptop |
| **Boot args** | (none) |
| **SecureBootModel** | Disabled |
| **XhciPortLimit** | true |
| **UpdateSMBIOSMode** | Create |
| **Boot mode** | UEFI only |

## Before this branch can be trusted

1. Confirm the actual hardware (CPU, WiFi/BT card).
2. Replace the `MacPro6,1` SMBIOS with a laptop SMBIOS appropriate for Ivy Bridge (e.g. MacBookPro11,1 as used by the BigSur branch) and regenerate serials.
3. Verify the OpenCore version; run `ocvalidate` from the matching OpenCorePkg release.
4. Address HD 4000 acceleration (OCLP or older-target strategy) — currently missing.
5. Test install end-to-end on real hardware.

Until then, use the **BigSur** branch, which is verified working.
