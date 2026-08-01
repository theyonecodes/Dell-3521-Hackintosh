# Hackintosh macOS Big Sur 11.7.11 on Dell Inspiron 3521 — OpenCore 1.0.7

> **Status: VERIFIED WORKING** on real hardware (August 2026). macOS Big Sur 11.7.11 installed and booted on this laptop using exactly the files in this branch, including **working Wi-Fi** on the internal Atheros AR9565 card.

## Repo Branches

| Branch | Status |
|--------|--------|
| **BigSur** (default) | ✅ Verified working build (this branch) — Wi-Fi included |
| **Monterey** | ⚠️ Experimental — not verified, config is not fully consistent (see its README) |
| **Sequoia** | ⚠️ Not a working Sequoia build — still ships OpenCore 0.8.8 (see its README) |

---

## Verified Hardware

| Component | Model | macOS Status |
|-----------|-------|-------------|
| **CPU** | Intel Core i3 3217U (Ivy Bridge, 1.8 GHz) | ✅ Native |
| **GPU** | Intel HD Graphics 4000 | ✅ Native |
| **WiFi** | Atheros AR9565 (`168C:0036`) | ✅ Working (2.4 GHz) |
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

**Works:** internal SSD boot, Wi-Fi 2.4 GHz (802.11n, ~35–45 Mbps — see speed note), Ethernet 100 Mbps, brightness (Fn+Up/Down), battery %, sleep/wake, audio (speakers + headphone), camera, USB, HDMI, SD card reader, dual-boot with Windows 10 (preserved partition).

**Doesn't work:** Bluetooth (AR3011 has no Big Sur driver — use a USB BT 4.0 dongle), 5 GHz Wi-Fi (AR9565 is 2.4 GHz only), Metal GPU API (HD4000 predates Metal), macOS Monterey and newer (HD4000 too old).

### About the Wi-Fi speed

The AR9565 is a **2.4 GHz-only, 1×1 (single spatial stream) 802.11n** card. Its PHY ceiling is 72 Mbps at 20 MHz channels, so ~35–45 Mbps real-world throughput is **normal and hardware-limited** — no kext or config change raises it. If the router's 2.4 GHz channel width is set to 20 MHz, switching it to **40 MHz** lifts the PHY to 150 Mbps (~60–75 real-world), if the signal allows it.

---

## Wi-Fi: what is actually in the working build (important)

The Wi-Fi stack is the **High Sierra-era** Apple framework injected via OpenCore:

```
HS80211Family.kext                                    ← com.apple.iokit.HS80211Family (10.13 framework, v1200.12.2)
AirPortAtheros40.kext                                 ← com.apple.driver.AirPort.Atheros40 (v700.74.5, AR9565 device ID patched in)
WifiLocFix.kext                                       ← com.pj.Software.driver.WifiInjection (binary-less property injector)
```

### Gotcha 1 — `ExecutablePath` must be set (this caused a kernel panic)

Both `HS80211Family.kext` and `AirPortAtheros40.kext` **must** have their `ExecutablePath` filled in:

```xml
<key>ExecutablePath</key><string>Contents/MacOS/HS80211Family</string>
```

If `ExecutablePath` is empty, the kext is added to the in-memory kext collection **without its Mach-O binary**, and boot panics in the kext collection builder:

```
can't perform kext scan: no kext summary
SKext::setVMAttributes → initWithPrelinkedInfoDict → addKextsFromKextCollection → InitIOKit
```

This is a config bug, not a driver problem — the exact same kext binaries boot fine with `ExecutablePath` set.

### Gotcha 2 — the legacy ElCap stack does NOT work on Big Sur

The older 10.11 stack (`IO80211ElCap.kext` + `corecaptureElCap.kext` + its bundled `AirPortAtheros40`) **boots but never produces a Wi-Fi interface**. The driver matches the card (`IONameMatched = pci168c,36`) but never starts — visible in `ioreg` as:

```
+-o AirPort_AtherosNewma40 <... !registered, !matched, active, busy 0 (0 ms)>
```

No `IO80211Interface` is ever created. Do not use that stack. The 10.13 `HS80211Family` + `AirPortAtheros40` pair is required.

### Gotcha 3 — WifiLocFix (country-code fix)

`WifiLocFix.kext` is a binary-less IOKit personality (`AppleUSBMergeNub` over `AtherosNewma40Interface`) that merges `IO80211CountryCode=ID` / `IO80211Locale=ETSI` onto the AirPort interface. It prevents the country-code/locale teardown that leaves the card attached with no usable network. Keep it enabled.

> Note: the shipped `config.plist` lists `WifiLocFix.kext` twice under `Kernel → Add`. OpenCore deduplicates kexts by bundle path, so this is harmless — it is a leftover from verification and intentionally left untouched because the build is boot-proven.

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
| **Misc.Debug** | `Target=99`, `DisplayLevel=0x80000004`, `ApplePanic=True` (panic capture on) |

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
EFI/OC/config.plist     1ad657775240cd49a4fefc6d5e58126a
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

Once Big Sur reaches the desktop (and Wi-Fi is confirmed), install OpenCore on the internal disk's EFI partition so the USB can be removed.

> **Do this manually.** Disk numbers change between machines and boots, and a wrong guess during an automated copy can touch the wrong EFI partition. There is no auto-detection here — you pick the partitions yourself.

### 1. Mount the two EFI partitions

Use **MountEFI** (GUI — mount the USB's `EFI` partition and the internal disk's `EFI` partition), or do it in the terminal. First check the disk IDs:

> **Paste one line at a time.** In an interactive zsh shell, `#` is **not** a comment — zsh tries to glob-expand it and the command never runs (you'll see `zsh: unknown sort specifier` / `zsh: number expected`). Only the `### 2` backup line uses `#`, and it is a `$(...)` substitution, not a comment.

First check the disk IDs:

```bash
diskutil list
```

Note the ~200 MB `EFI` partitions — one on the USB stick (source) and one on the internal disk (target). Then mount both, adjusting `disk3s1`/`disk0s1` to what you see:

```bash
sudo mkdir -p /Volumes/EFI-SRC /Volumes/EFI-TGT
sudo mount -t msdos /dev/disk3s1 /Volumes/EFI-SRC
sudo mount -t msdos /dev/disk0s1 /Volumes/EFI-TGT
```

Both mounts must succeed. `ditto` failing with `Cannot get the real path for source` means the source was never mounted — stop there, don't continue.

### 2. Back up the current internal EFI (rename, never delete)

```bash
sudo mv /Volumes/EFI-TGT/EFI /Volumes/EFI-TGT/EFI.orig-$(date +%Y%m%d)
```

Only run this if `EFI` actually exists on the target; `usage: mv` means it doesn't.

### 3. Copy the working EFI

```bash
sudo ditto /Volumes/EFI-SRC/EFI /Volumes/EFI-TGT/EFI
```

### 4. Verify

```bash
md5 /Volumes/EFI-TGT/EFI/BOOT/BOOTx64.efi /Volumes/EFI-TGT/EFI/OC/OpenCore.efi /Volumes/EFI-TGT/EFI/OC/config.plist
```

Expected (the verified build):

```
BOOTx64.efi    c2e80064f0d6e8a588b7c2f278ec6a88
OpenCore.efi   c171f38a5a047c2803981f3439fd9183
config.plist   1ad657775240cd49a4fefc6d5e58126a
```

### 5. Set the boot entry and unmount

```bash
sudo bless --mount /Volumes/EFI-TGT --setBoot --file /Volumes/EFI-TGT/EFI/OC/OpenCore.efi
sudo umount /Volumes/EFI-SRC /Volumes/EFI-TGT
```

Reboot **without the USB**. If the firmware does not auto-boot OpenCore, press **F12** and select the OpenCore / "Windows Boot Manager"-style entry on the internal disk.

### Interactive script (alternative)

`scripts/install_internal_efi.sh` automates exactly the steps above **without any auto-detection**: it lists every disk that has an EFI partition, asks you to pick the SOURCE and the TARGET by number, shows both MD5s before touching anything, renames (never deletes) the old internal EFI, and only copies after a final confirmation:

```bash
curl -L -o install.sh \
  https://raw.githubusercontent.com/theyonecodes/Dell-3521-Hackintosh/BigSur/scripts/install_internal_efi.sh
bash install.sh           # or: bash install.sh --list to preview disks only
```

### Re-enable USB mapping (after first boot)

USB map kexts are disabled for installation. After the first boot from the internal SSD, re-enable `USBToolBox.kext`, `UTBDefault.kext`, and `UTBMap.kext` in `config.plist` (Kernel → Add → Enabled) and sync to the internal EFI.

### Windows dual-boot

Windows 10 lives on a separate NTFS partition and must be preserved — the erase above only touches the macOS partition. The OpenCore picker shows the Windows entry automatically.

---

## Diagnostics

`scripts/DIAGNOSE.sh` collects the Wi-Fi/kernel state needed to debug the Atheros stack on the Dell (run it from the EFI volume, which macOS does not auto-mount):

```bash
sudo diskutil list            # find the ~200 MB EFI partition
sudo diskutil mount disk1s1   # mount the USB's EFI partition
sudo /Volumes/EFI/DIAGNOSE.sh # writes /Volumes/EFI/DIAGNOSE-output.txt
```

Key things it reports: `kextstat` of the Wi-Fi stack, kernel log lines, the `IO80211Plane`, and whether `AirPort_AtherosNewma40` is `registered`/`busy` — which distinguishes "driver never starts" (ElCap stack) from "country-code teardown" (WifiLocFix case).

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
    │   ├── AirPortAtheros40.kext      ← AR9565 Wi-Fi driver (10.13, patched) — REQUIRED
    │   ├── HS80211Family.kext         ← AR9565 Wi-Fi framework (10.13) — REQUIRED, loads FIRST
    │   ├── WifiLocFix.kext            ← country-code/locale fix (binary-less)
    │   ├── AppleALC.kext              ← audio (ALC282)
    │   ├── Ath3kBT.kext               ← AR3011 BT (injector + no driver)
    │   ├── Ath3kBTInjector.kext
    │   ├── BrightnessKeys.kext        ← Fn brightness hotkeys
    │   ├── ECEnabler.kext
    │   ├── Lilu.kext                  ← core
    │   ├── RealtekCardReader.kext     ← SD slot
    │   ├── RealtekCardReaderFriend.kext
    │   ├── RealtekRTL8100.kext        ← RTL8101E Ethernet
    │   ├── SMCBatteryManager.kext     ← battery
    │   ├── SMCDellSensors.kext        ← Dell sensors
    │   ├── SMCLightSensor.kext
    │   ├── SMCProcessor.kext
    │   ├── SMCSuperIO.kext
    │   ├── USBToolBox.kext            ← USB mapping (DISABLED for install)
    │   ├── UTBDefault.kext            ← (DISABLED for install)
    │   ├── UTBMap.kext                ← (DISABLED for install)
    │   ├── VirtualSMC.kext            ← SMC emulation
    │   ├── VoodooPS2Controller.kext   ← keyboard / trackpad
    │   └── WhateverGreen.kext         ← GPU patches
    └── Resources/                     ← OpenCanopy assets (unused; picker = Builtin)
```

Wi-Fi kext order in `config.plist → Kernel → Add` is mandatory: `HS80211Family.kext` **first**, then `AirPortAtheros40.kext`, then `WifiLocFix.kext` — and all three `ExecutablePath` values must be populated (see the Wi-Fi section).

---

## Troubleshooting

### Kernel panic: `can't perform kext scan: no kext summary` / `SKext::setVMAttributes`

Cause: a kext in `Kernel → Add` is missing its `ExecutablePath` (this repo previously shipped `HS80211Family.kext` / `AirPortAtheros40.kext` with empty paths). Fix: set `ExecutablePath` to `Contents/MacOS/HS80211Family` (and `Contents/MacOS/AirPortAtheros40`).

### Wi-Fi card detected but no interface / "No Hardware Installed"

- Confirm all three Wi-Fi kexts are enabled and in the right order (see above).
- Check `ioreg -p IO80211Plane -l -w0`: if `AirPort_AtherosNewma40` is `!registered` / `busy 0 (0 ms)`, the driver never started — you are on the wrong (ElCap) stack; use `HS80211Family` + `AirPortAtheros40`.
- Confirm `WifiLocFix.kext` is enabled — it cures the country-code teardown.
- `sudo kextcache -i /` after changes.

### "The update cannot be installed on this computer" (installer)

Check the installer log (`/var/log/install.log`):
- `storagekitd ... error: -69790` → target was an APFS container; erase it as **Mac OS Extended (Journaled)** first.
- `... not in the list of SupportedDeviceModels` / `BIErrorDomain Code=2` → SMBIOS is too old for 11.7.x; switch `SystemProductName` to **MacBookPro11,1**.

### Black screen or hang on boot

- Use verbose mode (`-v` is already set) to see where it stops.
- Reset NVRAM from the picker (Space → Reset NVRAM).
- Boot from the left-side USB 3.0 port only.

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
| **Build date** | August 2026 |

## Credits

- [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [gibMacOS](https://github.com/corpnewt/gibMacOS)
- OpenCore by Acidanthera
- [Hackintosh Subreddit](https://reddit.com/r/hackintosh)
- `WifiLocFix.kext` — fake AirPort location interface (InsanelyMac community)

No Apple services (iMessage/FaceTime/App Store) are configured. To use them, generate fresh SMBIOS serials with GenSMBIOS and update `config.plist` — never publish real serials.
