# Hackintosh macOS Big Sur 11.7.11 on Dell Inspiron 3521 — OpenCore 1.0.7

> **Status: VERIFIED WORKING** on real hardware (July 2026). macOS Big Sur 11.7.11 was installed and booted on this laptop using exactly the files in this branch.

## Repo Branches

| Branch | Status |
|--------|--------|
| **BigSur** (default) | ✅ Verified working build (this branch) |
| **Monterey** | ⚠️ Experimental — not verified, config is not fully consistent (see its README) |
| **Sequoia** | ⚠️ Not a working Sequoia build — still ships OpenCore 0.8.8 (see its README) |

---

## Verified Hardware

| Component | Model | macOS Status |
|-----------|-------|-------------|
| **CPU** | Intel Core i3 3217U (Ivy Bridge, 1.8 GHz) | ✅ Native |
| **GPU** | Intel HD Graphics 4000 | ✅ Native |
| **WiFi** | Atheros AR9560 (`168C:0036`) | ✅ Working (2.4 GHz) |
| **Ethernet** | Realtek RTL8101E (`10EC:8136`) | ✅ Working |
| **Bluetooth** | Atheros AR3011 (`0CF3:3004`) | ❌ No Big Sur driver |
| **Audio** | ALC3221 (mapped to ALC282) | ✅ Working |
| **Battery** | Dell smart battery | ✅ Working |
| **Keyboard / Trackpad** | PS/2 (VoodooPS2) | ✅ Working |
| **Camera** | Built-in 720p | ✅ Working |
| **HDMI** | External display | ✅ Working |
| **Card Reader** | Realtek SD slot | ✅ Working |
| **USB 3.0** | All ports (left-side USB port used for boot) | ✅ Working |

## What Works / What Doesn't

**Works:** internal SSD boot, WiFi 2.4 GHz (~40-50 Mbps, 802.11n), Ethernet 100 Mbps, brightness (Fn+Up/Down), battery %, sleep/wake, audio (speakers + headphone), camera, USB, HDMI, SD card reader, dual-boot with Windows 10 (preserved partition).

**Doesn't work:** Bluetooth (AR3011 has no Big Sur driver — use a USB BT 4.0 dongle), 5 GHz WiFi (AR9560 is 2.4 GHz only), Metal GPU API (HD4000 predates Metal), macOS Monterey and newer (HD4000 too old).

---

## Key Configuration Facts

| Item | Value |
|------|-------|
| **OpenCore** | 1.0.7 (official release) |
| **macOS** | Big Sur 11.7.11 |
| **SMBIOS** | **MacBookPro11,1** — required for 11.7.x (see troubleshooting) |
| **Boot args** | `-v debug=0x100 keepsyms=1` |
| **SecureBootModel** | `Disabled` |
| **Boot mode** | UEFI only |

## Why MacBookPro11,1 SMBIOS?

Big Sur **11.7.10 / 11.7.11** removed 2012-era board IDs from `SupportedDeviceModels`. With the stock `MacBookAir5,2` or `MacBookPro10,2` SMBIOS the installer aborts with:

```
Mac-AFD8A9D944EA4843 is not in the list of SupportedDeviceModels
Unable to install due to unsupported device (BIErrorDomain Code=2)
```

Switching `PlatformInfo.Generic.SystemProductName` to **MacBookPro11,1** (Ivy Bridge-era MacBook Pro) passes the check. In the shipped config `MLB`, `SystemSerialNumber`, and `SystemUUID` are intentionally empty and `SpoofVendor = true` (`UpdateSMBIOSMode = Custom`), so no real Apple serial numbers are published in this repo. Do **not** use `-no_compat_check` — the SMBIOS fix alone is sufficient and safer.

## Why the target disk must be HFS+

If the target partition is an APFS **container**, this machine's installer fails with "The update cannot be installed on this computer":

```
storagekitd: copyDiskForPath (/System/Volumes/Data) returned nil, error: -69790
```

**Fix:** in macOS Recovery → Disk Utility (View → Show All Devices), erase the target partition as **Mac OS Extended (Journaled)** (`MacOS`). The Big Sur installer converts it to APFS automatically during installation. On this machine the target was an empty APFS container left over from a previous install attempt.

---

## Installation

### 1. Prepare the USB installer

Use gibMacOS or the Mac App Store to obtain Big Sur 11.7.11. Build a 16 GB+ USB as **GPT** with a FAT32 EFI partition and put the installer data on the main FAT32 volume.

Copy this branch's `EFI/` folder onto the USB's EFI partition and verify (MD5 of the boot files must match):

```
EFI/BOOT/BOOTx64.efi    c2e80064f0d6e8a588b7c2f278ec6a88
EFI/OC/OpenCore.efi     c171f38a5a047c2803981f3439fd9183
```

> **Note for USB-mapped builds:** the USB map kexts (`USBToolBox.kext`, `UTBDefault.kext`, `UTBMap.kext`) ship **disabled** in `config.plist` so the installer's own USB stack is untouched. Boot the installer from the **left-side USB 3.0 port**.

### 2. BIOS settings

Power on → **F2**:

| Setting | Value |
|---------|-------|
| Secure Boot | Disabled |
| SATA Operation | AHCI |
| Boot List Option | UEFI |
| Fast Boot | Disabled |
| Legacy Option ROMs | Disabled |

Save (F10). Power on → **F12** → select **USB UEFI** → OpenCore picker appears.

### 3. Reset NVRAM

In the picker press **Space** (auxiliary entries — `HideAuxiliary = true`) → **Reset NVRAM** → reboot → boot from USB again.

### 4. Erase the target as HFS+

In the installer's Disk Utility (View → **Show All Devices**), select the target partition and erase as **Mac OS Extended (Journaled)** named `MacOS` (see "Why the target disk must be HFS+" above). Close Disk Utility.

### 5. Install

Select **Reinstall macOS Big Sur** → choose the erased partition → Install. Takes 20-40 minutes with 2-3 reboots.

> **During reboots keep the USB plugged in** and in the OpenCore picker select the **internal** "macOS Installer" / "macOS" continuation volume (press **Space** to reveal it if hidden). Never re-select the USB's base installer entry.

---

## Post-Install — Move EFI to the Internal SSD

Once Big Sur reaches the desktop, install OpenCore on the internal disk's empty EFI partition (`disk0s1`) so the USB can be removed:

```bash
curl -L -o install_internal_efi.sh \
  https://raw.githubusercontent.com/theyonecodes/Dell-3521-Hackintosh/BigSur/scripts/install_internal_efi.sh
bash install_internal_efi.sh
```

The script copies the exact bootloader that is currently running (from the USB EFI partition), backs up any existing internal EFI as `EFI.orig-<date>`, verifies all files by MD5, and refuses to run if the target is the USB itself. Reboot without the USB and confirm OpenCore starts from the internal SSD.

### Re-enable USB mapping (after first boot)

USB map kexts are disabled for installation. After the first boot from the internal SSD, re-enable `USBToolBox.kext`, `UTBDefault.kext`, and `UTBMap.kext` in `config.plist` (Kernel → Add → Enabled) and sync to the internal EFI.

### Windows dual-boot

Windows 10 lives on a separate NTFS partition and must be preserved — the erase above only touches the macOS partition. The OpenCore picker shows the Windows entry automatically.

---

## EFI Inventory (this branch)

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi
    ├── config.plist            ← MacBookPro11,1, USB map kexts disabled
    ├── ACPI/
    │   ├── SSDT-ALS0.aml       ← ambient light sensor
    │   ├── SSDT-EC.aml         ← embedded controller
    │   ├── SSDT-HPET.aml       ← HPET fix
    │   ├── SSDT-IMEI.aml
    │   ├── SSDT-MCHC.aml
    │   ├── SSDT-PNLF.aml       ← backlight
    │   ├── SSDT-SBUS.aml
    │   └── SSDT-XOSI.aml
    ├── Drivers/
    │   ├── HfsPlus.efi         ← HFS+ read support
    │   ├── OpenRuntime.efi
    │   └── ResetNvramEntry.efi
    ├── Kexts/
    │   ├── AppleALC.kext            ← audio (ALC282)
    │   ├── Ath3kBT.kext             ← AR3011 BT (injector + no driver)
    │   ├── Ath3kBTInjector.kext
    │   ├── BrightnessKeys.kext      ← Fn brightness hotkeys
    │   ├── corecaptureElCap.kext    ← AR9560 WiFi (loads AFTER IO80211ElCap)
    │   ├── ECEnabler.kext
    │   ├── IO80211ElCap.kext        ← legacy WiFi framework (loads FIRST)
    │   ├── Lilu.kext                ← core
    │   ├── RealtekCardReader.kext   ← SD slot
    │   ├── RealtekCardReaderFriend.kext
    │   ├── RealtekRTL8100.kext      ← RTL8101E Ethernet
    │   ├── SMCBatteryManager.kext   ← battery
    │   ├── SMCDellSensors.kext      ← Dell sensors
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBToolBox.kext          ← USB mapping (DISABLED for install)
    │   ├── UTBDefault.kext          ← (DISABLED for install)
    │   ├── UTBMap.kext              ← (DISABLED for install)
    │   ├── VirtualSMC.kext          ← SMC emulation
    │   ├── VoodooPS2Controller.kext ← keyboard / trackpad
    │   └── WhateverGreen.kext       ← GPU patches
    └── Resources/                   ← OpenCanopy assets (unused; picker = Builtin)
```

WiFi kext order is mandatory: `IO80211ElCap.kext` must load **before** `corecaptureElCap.kext`, or WiFi will not appear.

---

## Troubleshooting

### "The update cannot be installed on this computer" (installer)

Check the installer log (`/var/log/install.log`):
- `storagekitd ... error: -69790` → target was an APFS container; erase it as **Mac OS Extended (Journaled)** first.
- `... not in the list of SupportedDeviceModels` / `BIErrorDomain Code=2` → SMBIOS is too old for 11.7.x; switch `SystemProductName` to **MacBookPro11,1**.

### Black screen or hang on boot

- Use verbose mode (`-v` is already set) to see where it stops.
- Reset NVRAM from the picker (Space → Reset NVRAM).
- Boot from the left-side USB 3.0 port only.

### WiFi missing

- Confirm `IO80211ElCap.kext` loads before `corecaptureElCap.kext`.
- Reset NVRAM, then rebuild the kext cache: `sudo kextcache -i /`

### Bluetooth not working

Known hardware limitation: AR3011 has no Big Sur driver. Use a USB Bluetooth 4.0 dongle (CSR8510 recommended).

---

## Version Info

| Item | Value |
|------|-------|
| **OpenCore** | 1.0.7 |
| **macOS** | Big Sur 11.7.11 (final) |
| **SMBIOS** | MacBookPro11,1 |
| **Boot mode** | UEFI only |
| **Build date** | July 2026 |

## Credits

- [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [gibMacOS](https://github.com/corpnewt/gibMacOS)
- OpenCore by Acidanthera
- [Hackintosh Subreddit](https://reddit.com/r/hackintosh)

No Apple services (iMessage/FaceTime/App Store) are configured. To use them, generate fresh SMBIOS serials with GenSMBIOS and update `config.plist` — never publish real serials.
