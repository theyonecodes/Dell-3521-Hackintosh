# Dell Inspiron 3521 — macOS Big Sur Hackintosh Guide

Complete step-by-step guide based on the standard Hackintosh community workflow. Every step is numbered and detailed.

---

## What You Need Before Starting

**Hardware:**
- Dell Inspiron 3521 laptop
- USB drive (16GB or larger)
- Another working PC (Windows) to prepare the USB
- Internet connection

**Software to Download:**
- Python 3 (from python.org)
- OpenCore Simplify (from GitHub)
- OpenCore PKG (from GitHub)
- USBToolBox (from GitHub)
- OCAuxiliaryTools (from GitHub)
- Rufus (from rufus.ie)

**Time Required:**
- Preparation: 30-60 minutes
- Installation: 30-60 minutes
- Post-install: 15-30 minutes

**Skill Level:**
- Basic computer knowledge
- Comfortable using Command Prompt
- Willing to follow steps exactly

---

## Hardware Specs

| Component | Detail |
|---|---|
| CPU | Intel Core i5-3337U (Ivy Bridge, 2C/4T, 1.8GHz) |
| GPU | Intel HD Graphics 4000 (1366x768 LVDS) |
| RAM | 16GB DDR3 |
| Ethernet | Realtek RTL8136 (PCIe FE) |
| WiFi/BT | Dell Wireless 1705 (Atheros AR9485) |
| Audio | Realtek ALC282 |
| Touchpad | Synaptics SMBus (PS/2) |
| Storage | Kingston SA400S37120G 120GB SSD (SATA AHCI) |
| BIOS | Dell A16 (UEFI, Secure Boot Off) |

---

## Tools & Downloads

| Tool | What It Does | Download Link |
|---|---|---|
| **OpenCore Simplify** | Scans hardware, generates EFI folder automatically | https://github.com/lzhoang2801/OpCore-Simplify |
| **OpenCore PKG** | Contains macrecovery tool to download macOS recovery | https://github.com/acidanthera/OpenCorePkg/releases |
| **USBToolBox** | Maps USB ports so macOS recognizes all ports | https://github.com/USBToolBox/UTBTool |
| **OCAuxiliaryTools (OCAT)** | Edits config.plist, mounts EFI partitions | https://github.com/IC00501/Opencore-Tools |
| **Rufus** | Formats USB drive as GPT FAT32 | https://rufus.ie |
| **Python 3** | Required to run OpenCore Simplify and macrecovery | https://www.python.org/downloads/windows/ |
| **ProperTree** | Alternative config.plist editor (optional) | https://github.com/corpnewt/ProperTree |

---

## Step 1 — Install Python 3

Both OpenCore Simplify and macrecovery require Python.

1. Download Python 3 from https://www.python.org/downloads/windows/
2. Run the installer
3. **IMPORTANT**: Check the box that says **"Add Python to PATH"** at the bottom of the installer
4. Click **Install Now**
5. When done, click **Close**

To verify Python is installed, open Command Prompt and type:
```
python --version
```
It should show something like `Python 3.12.x`.

> **Note**: If you get "Python was not found", reinstall Python and make sure to check "Add to PATH".

---

## Step 2 — Run OpenCore Simplify (Generate EFI)

This tool scans your PC hardware and builds a custom EFI folder for Hackintosh.

1. Download **OpenCore Simplify** from https://github.com/lzhoang2801/OpCore-Simplify
2. Extract the zip file to your desktop
3. Open the extracted folder
4. Double-click **OpCore-Simplify.bat** to run it
5. A command prompt window opens with a numbered menu

### Menu Options Explained

The menu shows these options:

```
1. Select Hardware Report
2. Select macOS Version
3. Customize ACPI Patch
4. Customize Kexts
5. Customize SMBIOS Model
6. Build OpenCore EFI
Q. Quit
```

### What Each Number Does

**Option 1 — Select Hardware Report**
- Press **1** then Enter
- The tool will download and run **Hardware Sniffer** to scan your PC
- It detects: CPU, GPU, Audio codec, Ethernet, WiFi, Bluetooth, USB controllers, etc.
- It generates a `Report.json` file in the `SysReport` folder
- It then automatically runs options 2-5 based on your hardware

**Option 2 — Select macOS Version**
- Press **2** then Enter
- Shows a list of macOS versions your hardware supports
- For Dell Inspiron 3521, select **Big Sur** (enter `20` for Darwin version 20)
- The tool suggests the best version based on your GPU compatibility

**Option 3 — Customize ACPI Patch**
- Press **3** then Enter
- Shows which SSDTs (ACPI tables) will be generated
- For Dell 3521, it auto-selects: SSDT-EC, SSDT-HPET, SSDT-MCHC, SSDT-PNLF, SSDT-XOSI, SSDT-ALS0, SSDT-SBUS
- You can toggle individual patches on/off

**Option 4 — Customize Kexts**
- Press **4** then Enter
- Shows which kexts (drivers) will be included
- Auto-selects based on your hardware: Lilu, VirtualSMC, AppleALC, WhateverGreen, VoodooPS2, etc.
- You can toggle individual kexts on/off

**Option 5 — Customize SMBIOS Model**
- Press **5** then Enter
- Shows which Mac model to impersonate
- For Dell 3521 (Ivy Bridge i5), it selects **MacBookPro10,2**
- You can change this if needed

**Option 6 — Build OpenCore EFI**
- Press **6** then Enter
- If tool asks about OpenCore Legacy Patcher, type **yes** and press Enter
- Downloads latest OpenCore bootloader from GitHub
- Downloads latest kexts from GitHub (Lilu, VirtualSMC, AppleALC, etc.)
- Generates all ACPI patches (SSDTs) based on your DSDT
- Builds a complete EFI folder
- Saves output to `Results\EFI\`
- Shows the "Before Using EFI" screen with next steps

### What the Build Process Does

When you press **6**, the tool:
1. Copies the OpenCore base EFI from `OCK_Files\OpenCorePkg\`
2. Applies ACPI patches (SSDT-EC, SSDT-HPET, SSDT-MCHC, etc.)
3. Copies all selected kexts to `EFI\OC\Kexts\`
4. Generates `config.plist` with all your hardware-specific settings
5. Cleans up unused drivers, tools, and resources
6. Opens the `Results\EFI` folder when done

### Recommended Flow

1. Press **1** — the tool runs through everything automatically
2. Wait for it to finish (may take 2-5 minutes)
3. Press **6** to build the EFI
4. Wait for the build to complete
5. The tool shows the "Before Using EFI" screen
6. Press Enter to continue
7. The `Results\EFI` folder opens automatically

> **Note**: If the tool asks about OpenCore Legacy Patcher, type **yes** and press Enter. This is needed for some hardware patches.

---

## Step 3 — Map USB Ports (USBToolBox)

After OpenCore Simplify builds the EFI, it shows a "Before Using EFI" screen with these exact instructions:

```
Please complete the following steps:

* BIOS/UEFI Settings Required:
    - Enable UEFI mode (disable Legacy/CSM)
    - Disable Secure Boot

* USB Mapping:
    - Use USBToolBox tool to map USB ports.
    - Add created UTBMap.kext into the EFI\OC\Kexts folder.
    - Remove UTBDefault.kext in the EFI\OC\Kexts folder.
    - Edit config.plist:
        - Use ProperTree to open your config.plist.
        - Run OC Snapshot by pressing Command/Ctrl + R.
        - If you have more than 15 ports on a single controller, enable the XhciPortLimit patch.
        - Save the file when finished.
```

**Follow these steps exactly:**

### 3A — Download and Run USBToolBox

1. Download **USBToolBox** from https://github.com/USBToolBox/UTBTool
2. Run the tool (Windows version available)
3. Click **"Discover Ports"** or **"Start Discovery"**
4. Plug a USB device into each port one by one
5. The tool will detect which ports are active and map them
6. Click **"Build Kext"** to generate:
   - `USBToolBox.kext`
   - `UTBMap.kext`
7. Copy both kexts to your EFI folder:
   ```
   Results\EFI\OC\Kexts\USBToolBox.kext
   Results\EFI\OC\Kexts\UTBMap.kext
   ```
8. Delete the old `UTBDefault.kext` from the Kexts folder

> **Note**: The UTBDefault.kext that OpenCore Simplify includes is a placeholder. You must replace it with your custom UTBMap.kext.

---

## Step 4 — Edit config.plist (OCAuxiliaryTools)

1. Download **OCAuxiliaryTools** from https://github.com/IC00501/Opencore-Tools
2. Install and open OCAT
3. Open your config.plist: `Results\EFI\OC\config.plist`

### 4A — Add USB Kexts to Config

1. In OCAT, go to **Kernel > Add** section
2. Click the **+** button
3. Add `USBToolBox.kext`
4. Add `UTBMap.kext`
5. Make sure `UTBDefault.kext` is removed or disabled

### 4B — Run OC Snapshot

This auto-detects all kexts and drivers in your EFI folder:

1. Press **Ctrl + R** (or Command + R on Mac)
2. OCAT will scan your EFI folder and update the config automatically
3. All kexts in the Kexts folder will be added to Kernel > Add
4. All drivers in the Drivers folder will be added to UEFI > Drivers

### 4C — GPU Patches (Fix Black Screen)

Go to **DeviceProperties > Add > PciRoot(0x0)/Pci(0x2,0x0)** and add these properties:

| Key | Type | Value (Hex) | What It Does |
|---|---|---|---|
| AAPL,ig-platform-id | Data | `04006601` | HD 4000 mobile LVDS+VGA+HDMI |
| framebuffer-patch-enable | Data | `01000000` | Enable framebuffer patching |
| framebuffer-con0-enable | Data | `01000000` | Enable connector 0 |
| framebuffer-con0-type | Data | `02000000` | Connector 0 = LVDS (internal display) |
| framebuffer-con1-enable | Data | `01000000` | Enable connector 1 |
| framebuffer-con1-type | Data | `10000000` | Connector 1 = VGA |
| framebuffer-con2-enable | Data | `01000000` | Enable connector 2 |
| framebuffer-con2-type | Data | `00080000` | Connector 2 = HDMI |
| framebuffer-stolenmem | Data | `00003001` | 19MB stolen memory |
| framebuffer-fbmem | Data | `00009000` | 9MB framebuffer memory |
| framebuffer-unifiedmem | Data | `00060000` | 1536MB unified memory |

### 4D — Boot Arguments

Go to **NVRAM > Add > 7C436110-AB2A-4BBB-A880-FE41995C9F82**:

| Key | Type | Value |
|---|---|---|
| boot-args | String | `-v debug=0x100 keepsyms=1 alcid=29 igfxonln=1 -igfxnohdmi` |
| prev-lang:kbd | String | `en:US` |

**Boot args explained:**
- `-v` — Verbose mode (shows text during boot for debugging)
- `debug=0x100` — Prevents auto-reboot on kernel panic
- `keepsyms=1` — Keeps symbol names for panic logs
- `alcid=29` — Audio layout-id for ALC282
- `igfxonln=1` — Forces all GPU connectors online (fixes black screen)
- `-igfxnohdmi` — Disables HDMI to prevent conflicts with LVDS

### 4E — Kernel Quirks

Go to **Kernel > Quirks** and set these to **True**:

| Key | Value | Why |
|---|---|---|
| AppleXcpmCfgLock | True | BIOS CFG Lock is locked on Dell |
| AppleXcpmExtraMsrs | True | Required for Ivy Bridge XCPM |
| XhciPortLimit | True | Needed for USB mapping during install |
| DisableIoMapper | True | Avoids VT-d conflicts |
| PanicNoKextDump | True | Better panic logging |

### 4F — Remove Conflicting Kexts

Go to **Kernel > Add** and remove these entries (keep the files in Kexts-Disabled folder):
- AppleIntelCPUPowerManagement.kext
- AppleIntelCPUPowerManagementClient.kext

### 4G — Add SSDT-PLUG

Go to **ACPI > Add** and add:
- SSDT-PLUG.aml (CPU XCPM plugin)

### 4H — Misc Settings

**Misc > Boot:**
| Key | Value |
|---|---|
| PickerMode | External |
| PickerVariant | Acidanthera\GoldenGate |
| HideAuxiliary | False |
| PollAppleHotKeys | True |
| ShowPicker | True |
| Timeout | 5 |

**Misc > Security:**
| Key | Value |
|---|---|
| ScanPolicy | 0 |
| SecureBootModel | Disabled |
| AllowSetDefault | True |

**Misc > Debug:**
| Key | Value |
|---|---|
| AppleDebug | True |
| ApplePanic | True |
| Target | 67 |

### 4I — UEFI Drivers

Go to **UEFI > Drivers** and ensure these are present and enabled:
- OpenRuntime.efi
- ResetNvramEntry.efi
- OpenHfsPlus.efi (or HfsPlus.efi)
- OpenCanopy.efi

### 4J — UEFI Quirks

Set these to **True**:
- UnblockFsConnect
- ReleaseUsbOwnership
- RequestBootVarRouting
- IgnoreInvalidFlexRatio

### 4K — PlatformInfo

Go to **PlatformInfo > Generic**:
| Key | Value |
|---|---|
| Automatic | False |
| SystemProductName | MacBookPro10,2 |
| ProcessorType | 1795 (0x0703) |
| SystemSerialNumber | (generated — do not share online) |
| MLB | (generated — do not share online) |
| SystemUUID | (generated — do not share online) |

5. **Save** the config.plist in OCAT

---

## Step 5 — Download macOS Recovery (macrecovery)

This downloads the macOS recovery files from Apple's servers using the OpenCore PKG tool.

1. Download **OpenCore PKG** from https://github.com/acidanthera/OpenCorePkg/releases
   - Download the latest release zip file
2. Extract the zip to your desktop
3. Open the extracted folder and navigate to:
   ```
   OpenCore-Pkg-master\Utilities\macrecovery\
   ```
4. Open a **Command Prompt** in this folder:
   - Hold **Shift** and **Right-click** in the empty space of the folder
   - Select **"Open PowerShell window here"** or **"Open command window here"**
5. Run the following command for **Big Sur**:
   ```
   macrecovery.bat -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
   ```
   Or if using Python directly:
   ```
   python macrecovery.py -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
   ```
6. Wait for the download to complete (it will download `BaseSystem.dmg` and `BaseSystem.chunklist`)
7. The files will be saved in the `macrecovery` folder

**Other macOS versions (for reference):**
| macOS | Command |
|---|---|
| Catalina | `macrecovery.bat -b Mac-CFF7D910A743CAAF -m 00000000000PHCD00 download` |
| Big Sur | `macrecovery.bat -b Mac-2BD1B31983FE1663 -m 00000000000000000 download` |
| Monterey | `macrecovery.bat -b Mac-E43C1C25D4880AD6 -m 00000000000000000 download` |
| Ventura | `macrecovery.bat -b Mac-B4831CEBD52A0C4C -m 00000000000000000 download` |
| Sonoma | `macrecovery.bat -b Mac-827FAC58A8FDFA22 -m 00000000000000000 download` |

---

## Step 5B — Pre-Partition Your SSD (Optional but Recommended)

Some users create a partition in Windows BEFORE booting into macOS installer. This avoids the "GUID Partition Table required" error in Disk Utility.

1. Right-click **Start Menu** → select **Disk Management**
2. Find your **Kingston SA400S37120G** SSD
3. Right-click on the largest partition (your Windows C: drive)
4. Select **Shrink Volume**
5. Enter the amount to shrink in MB (at least 50000 for 50GB)
6. Click **Shrink**
7. You now have **Unallocated space** — leave it unallocated
8. Close Disk Management

> **Note**: This step is optional. If you skip it, you'll need to use Terminal in macOS to format the disk (see Troubleshooting section).

---

## Step 5C — Hyper-V Warning

Your BIOS has Hyper-V enabled. This can sometimes conflict with macOS. If you encounter issues:

1. Boot into Windows
2. Open **Command Prompt as Administrator**
3. Run:
   ```
   bcdedit /set hypervisorlaunchtype off
   ```
4. Restart and try again

To re-enable Hyper-V later:
```
bcdedit /set hypervisorlaunchtype auto
```

---

## Step 6 — Format USB Drive (Rufus)

1. Download **Rufus** from https://rufus.ie
2. Insert your USB drive (16GB or larger)
3. Open Rufus
4. Select your USB drive from the dropdown
5. Set these options:
   - **Boot selection**: Non bootable
   - **Partition scheme**: GPT
   - **Target system**: UEFI (non CSM)
   - **File system**: FAT32
   - **Cluster size**: Default
6. Click **START**
7. Wait for formatting to complete

---

## Step 7 — Copy Files to USB

1. After Rufus formats the USB, open it in File Explorer
2. Copy your **EFI** folder from `Results\EFI\` to the root of the USB:
   ```
   E:\EFI\
   ```
3. Create a folder called `com.apple.recovery.boot` on the root of the USB:
   ```
   E:\com.apple.recovery.boot\
   ```
4. Copy the downloaded recovery files into that folder:
   ```
   E:\com.apple.recovery.boot\BaseSystem.dmg
   E:\com.apple.recovery.boot\BaseSystem.chunklist
   ```
5. Verify the final USB structure:

```
USB Drive (E:)
├── EFI\
│   ├── BOOT\
│   │   └── BOOTx64.efi
│   └── OC\
│       ├── OpenCore.efi
│       ├── config.plist
│       ├── ACPI\        (7-8 SSDTs)
│       ├── Drivers\     (3-4 EFI drivers)
│       ├── Kexts\       (19-22 kexts)
│       └── Resources\   (boot picker images/fonts)
└── com.apple.recovery.boot\
    ├── BaseSystem.dmg
    └── BaseSystem.chunklist
```

---

## Step 8 — BIOS Settings

Before booting, verify these BIOS settings:

1. Restart laptop → press **F2** repeatedly to enter BIOS
2. **General > Boot Sequence:**
   - Boot List Option: **UEFI**
   - Uncheck **Legacy** if checked
   - Set **USB first** in boot priority
3. **Security > Secure Boot:**
   - Secure Boot Enable: **Disabled**
   - If grayed out and OS Type shows "Other OS", it's already off
4. **System Configuration > SATA Operation:**
   - SATA Operation: **AHCI**
5. **Video > Advanced** (if available):
   - DVMT Pre-Allocated: **128MB** or **64MB**
6. Press **F10** to save and exit

---

## Step 9 — Boot from USB

1. Plug USB into laptop (use a USB 2.0 port — black port, not blue)
2. Restart laptop
3. Press **F12** repeatedly during boot (Dell logo screen)
4. Boot menu will appear
5. Select your **USB drive** (may show as "UEFI: Kingston DataTraveler" or similar)
6. OpenCore boot picker will appear with graphical interface

**What you should see:**
- A graphical boot picker with icons
- "Install macOS Big Sur" option
- "Reset NVRAM" option (after pressing Space)
- Your internal SSD name (after first install phase)

**If you see a black screen instead:**
- Wait 30 seconds — GPU may be slow to initialize
- If still black, force shutdown and try a different USB port
- Make sure Secure Boot is disabled in BIOS

---

## Step 10 — Reset NVRAM (First Boot Only)

This clears any old settings that might conflict. You must do this on the first boot.

1. In OpenCore picker, press **Space** on keyboard
2. Additional options will appear below the main entries
3. Select **"Reset NVRAM"** using arrow keys
4. Press Enter
5. Laptop will reboot automatically
6. Boot from USB again (F12 → select USB)

**What Reset NVRAM does:**
- Clears old boot settings
- Resets BIOS variables
- Clears any previous OpenCore configuration
- Ensures a clean first boot

> **Note**: You only need to do this once. After the first successful boot, you don't need to reset NVRAM again unless you encounter issues.

---

## Step 11 — Install macOS Big Sur

### 11A — Boot into macOS Installer

1. In OpenCore picker, select **"Install macOS Big Sur"**
2. Press Enter
3. You will see verbose text scrolling on screen (this is normal with `-v` boot arg)
4. Wait 2-5 minutes — the text will stop and Apple logo will appear
5. macOS Recovery screen will appear

**What you should see:**
- Apple logo with progress bar
- Then the macOS Recovery window
- Menu bar at top with Utilities menu

### 11B — Format the SSD

1. Go to **Utilities > Disk Utility**
2. **IMPORTANT**: Click **View > Show All Devices** (this is critical!)
3. In left sidebar, select **Kingston SA400S37120G** (the top-level entry, NOT a partition)
4. Click **Erase** at top of window
5. Set these options:
   - **Name**: Macintosh SSD (or any name you prefer)
   - **Format**: APFS
   - **Scheme**: GUID Partition Map
6. Click **Erase**
7. Wait for completion (may take 1-2 minutes)
8. Click **Done**
9. Close Disk Utility (click red X in top left)

> **Note**: If you get an error about "GUID Partition Table required," see the Common Errors section below.

### 11C — Begin Installation

1. Back at Recovery screen, click **"Install macOS Big Sur"**
2. Click **Continue**
3. Agree to the software license terms
4. Select **"Macintosh SSD"** as destination
5. Click **Install**
6. The installation begins — you'll see a progress bar

### 11D — Handle Restarts (Critical!)

**The laptop will restart several times during installation. Each time you MUST:**

1. Press **F12** to open boot menu
2. Select your **USB drive** (not the internal SSD yet)
3. In OpenCore picker, select **"Macintosh SSD"** (or whatever you named it)
4. Press Enter

**Do NOT select the USB's "Install macOS Big Sur" option again after the first restart — select the internal SSD.**

### 11E — Installation Timeline

| Phase | What Happens | Duration | Your Action |
|---|---|---|---|
| Phase 1 | Files copied to SSD | 5-10 min | Wait |
| Phase 1 restart | Laptop restarts | — | F12 → USB → select SSD |
| Phase 2 | Apple logo + progress bar | 10-15 min | Wait |
| Phase 2 restart | Laptop restarts | — | F12 → USB → select SSD |
| Phase 3 | Apple logo + progress bar | 10-15 min | Wait |
| Phase 3 restart | Laptop restarts | — | F12 → USB → select SSD |
| Phase 4 | Setup Assistant appears | — | Follow on-screen steps |

**Total time**: 30-60 minutes

> **Important**: If the screen goes black for 10-30 seconds during boot, this is normal. The GPU is initializing. Wait patiently. Do NOT force shutdown unless it's been black for more than 2 minutes.

---

## Step 12 — macOS Setup Assistant

After installation completes, you'll see the Setup Assistant. Follow these steps:

1. **Country/Region**: Select your country → Continue
2. **Language**: Select **English** → Continue
3. **Keyboard**: Select your keyboard layout → Continue
4. **WiFi**: Connect if available (your AR9485 may not work — use Ethernet if available)
5. **Data & Privacy**: Click Continue
6. **Apple ID**: Sign in or click "Set Up Later" → Skip
7. **Terms & Conditions**: Agree
8. **Computer Account**: Create your username and password
9. **Express Set Up**: Continue or customize
10. **Appearance**: Choose Light or Dark mode → Continue

You should now be at the macOS desktop.

**First things to do:**
- Turn off automatic updates: System Preferences > Software Update > Uncheck "Automatically keep my Mac up to date"
- Turn off screen saver: System Preferences > Desktop & Screen Saver > Screen Saver > Set to "Never"

---

## Step 13 — Post-Install: Copy EFI to Internal SSD

Right now macOS only boots from USB. Copy EFI to internal SSD.

### Method A — OCAuxiliaryTools (Recommended)

1. Open **OCAuxiliaryTools** on macOS
2. Click **Tools > Mount EFI** (or the mount button)
3. Find your **Kingston SSD** (disk0) — click **Mount** next to its EFI partition
4. Find your **USB drive** — click **Mount** next to its EFI partition
5. Both EFI partitions will appear in Finder
6. Delete the contents of the **SSD's EFI partition**
7. Copy the entire `EFI` folder from **USB's EFI** to **SSD's EFI**
8. **Do NOT remove USB yet** — test boot first

### Method B — Terminal

```bash
# Find disk numbers
diskutil list

# Mount SSD EFI (usually disk0s1)
sudo diskutil mount /dev/disk0s1

# Mount USB EFI (find correct disk number)
sudo diskutil mount /dev/disk2s1

# Copy EFI
sudo cp -R /Volumes/EFI_USB/EFI /Volumes/EFI_SSD/

# Verify
ls /Volumes/EFI_SSD/EFI/OC/
```

---

## Step 14 — Test Boot Without USB

1. Save all work
2. Shut down laptop completely
3. Remove USB drive
4. Press power button
5. Laptop should boot directly into macOS from SSD

If it boots successfully, installation is complete.

---

## Step 15 — Remove Verbose Mode

Once everything is working, remove the `-v` flag:

1. Open OCAuxiliaryTools
2. Open config.plist from your SSD's EFI
3. Go to **NVRAM > Add > 7C436110-AB2A-4BBB-A880-FE41995C9F82**
4. Edit boot-args: remove `-v` from the string
5. Save and reboot

---

## Step 16 — Post-Install Tools (Optional)

These tools are mentioned in the community workflow for post-install fixes.

### OpenCore Legacy Patcher (OCLP)

If you need to patch GPU or WiFi support on newer macOS versions:

1. Download from https://github.com/dortania/OpenCore-Legacy-Patcher
2. Install and run on macOS
3. Follow the on-screen instructions to patch your system
4. Reboot after patching

> **Note**: OCLP is mainly needed for macOS Monterey and newer. For Big Sur, it's usually not required.

### Hackintool

If you need to fix drivers or check hardware status:

1. Download from https://github.com/benbaker76/Hackintool
2. Install and run on macOS
3. Use it to:
   - Check USB port mapping
   - Verify audio/layout-id
   - Check GPU status
   - Fix driver issues

### Homebrew (Package Manager)

Homebrew makes installing software easier on macOS:

1. Open **Terminal** (Applications > Utilities)
2. Install Homebrew:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Follow the on-screen instructions
4. After install, run the commands it shows to add Homebrew to PATH
5. Install common tools:
   ```
   brew install wget git curl
   ```

---

## Step 17 — Post-Install Optimizations

### Enable Boot Chime

To hear the Mac startup sound:

1. Open OCAuxiliaryTools
2. Open config.plist
3. Go to **UEFI > Audio**
4. Set **AudioSupport** to **True**
5. Set **PlayChime** to **Auto**
6. Save and reboot

### Disable Sleep (If Issues)

If your laptop doesn't wake from sleep:

1. Open **System Preferences > Battery**
2. Set **"Turn display off after"** to **Never**
3. Or run in Terminal:
   ```
   sudo pmset -a sleep 0
   sudo pmset -a hibernatemode 0
   ```

### Enable FileVault (Optional)

For disk encryption:

1. Open **System Preferences > Security & Privacy > FileVault**
2. Click the lock icon and enter your password
3. Click **Turn On FileVault**

> **Note**: FileVault may not work properly on Hackintosh. Test before enabling.

---

## Common Errors During Installation

### "Load image failed" Error

**Cause**: Corrupted or incomplete macOS recovery download.

**Fix**:
1. Boot back into Windows
2. Delete the `com.apple.recovery.boot` folder from the USB
3. Re-run macrecovery to download the recovery files again:
   ```
   macrecovery.bat -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
   ```
4. Copy the new files to the USB
5. Try booting again

### "A GUID Partition Table (GPT) partition scheme is required" Error

**Cause**: Disk Utility can't format the disk because it's not using GPT.

**Fix 1 — Use Terminal**:
1. In macOS Recovery, go to **Utilities > Terminal**
2. Run:
   ```
   diskutil list
   ```
3. Find your Kingston SSD (look for `disk0`)
4. Erase and format it:
   ```
   diskutil eraseDisk APFS "Macintosh SSD" GPT /dev/disk0
   ```
5. Close Terminal
6. Go back to Disk Utility — the disk should now be formatted as APFS with GPT

**Fix 2 — Pre-partition in Windows**:
1. Boot back into Windows
2. Open Disk Management
3. Shrink your Windows partition to create unallocated space
4. Boot back into macOS installer
5. Use Disk Utility to format the unallocated space

### USB Drive Not Showing in Boot Menu

**Fix**:
1. Make sure USB is plugged into a USB 2.0 port (black port, not blue)
2. Restart and press F12 repeatedly
3. If USB doesn't appear, try a different USB port
4. Make sure BIOS boot priority has USB first

### OpenCore Picker Not Appearing

**Fix**:
1. Make sure Secure Boot is disabled in BIOS
2. Make sure UEFI mode is enabled (not Legacy/CSM)
3. Try pressing **Esc** or **F8** during boot instead of F12

### Kernel Panic During Boot

**Fix**:
1. Boot from USB
2. In OpenCore picker, select your SSD
3. Press **Space** → select **Reset NVRAM**
4. Reboot

If panic persists, note the error message and search for it on https://dortania.github.io

### Stuck at "Still waiting for root device"

**Cause**: macOS can't find the boot disk.

**Fix**:
1. Boot from USB
2. In OpenCore picker, press **Space** → select **Reset NVRAM**
3. Reboot
4. If still stuck, the SATA controller may need a different kext

### Screen Goes Black and Stays Black

**Cause**: GPU not initializing properly.

**Fix**:
1. Wait 30 seconds — GPU may be slow
2. If still black, force shutdown (hold power 5 seconds)
3. Boot from USB → select SSD in picker
4. Press Space → Reset NVRAM
5. Reboot

If still black:
- Check BIOS DVMT setting (set to 128MB if available)
- Verify GPU patches in config.plist (ig-platform-id, con types, igfxonln=1)

---

## Troubleshooting

### Black Screen After Verbose Text

**Fix**:
1. Wait 30 seconds — GPU may be slow to initialize
2. If still black, force shutdown (hold power 5 seconds)
3. Boot from USB → select SSD in picker
4. Press Space → Reset NVRAM
5. Reboot and try again

If still black:
- Check BIOS DVMT setting (set to 128MB if available)
- Verify GPU patches in config.plist (ig-platform-id, con types, igfxonln=1)

### Kernel Panic

**Fix**:
1. Boot from USB
2. Select SSD in picker
3. Press Space → Reset NVRAM
4. Reboot

If panic persists:
- Boot with `-v` flag to see panic message
- Check kext compatibility
- Verify SSDT-PLUG.aml is in ACPI folder

### Stuck at Apple Logo

**Fix**:
1. Boot from USB with verbose mode
2. Select SSD in picker
3. Press Space → Reset NVRAM
4. Reboot

### WiFi Not Working

**Cause**: Dell Wireless 1705 (Atheros AR9485) is not supported on Big Sur.

**Solutions**:
1. **Use Ethernet** — Realtek RTL8136 works perfectly
2. **USB WiFi adapter** — Get one that works with macOS
3. **Replace Mini PCIe WiFi card** — Intel WiFi cards work with itlwm kext

### Bluetooth Not Working

Same as WiFi — AR9485 Bluetooth is capped. Use USB Bluetooth adapter if needed.

### Audio Not Working

```bash
sudo nvram boot-args="alcid=29"
```
Reboot.

### Sleep/Wake Issues

Dell Inspiron 3521 may not wake from sleep properly.

**Fix**:
- System Preferences > Battery > Turn display off after: Never
- Or disable sleep entirely

### iCloud/iMessage Not Working

The serial numbers in your config.plist are unique to your system. If iCloud/iMessage don't work:

1. Generate new serial numbers using **GenSMBIOS** tool
2. Update config.plist with new values
3. Reset NVRAM and reboot

**Never share your serial numbers online.**

---

## What Works / What Doesn't

| Feature | Status | Notes |
|---|---|---|
| CPU Power Management | ✅ | XCPM with SSDT-PLUG |
| GPU (HD 4000) | ✅ | Full acceleration, WhateverGreen |
| Internal Display (LVDS) | ✅ | 1366x768 |
| VGA Output | ✅ | Via con1 patch |
| HDMI Output | ✅ | Via con2 patch |
| Audio (ALC282) | ✅ | Layout-id 29 |
| Ethernet (RTL8136) | ✅ | RealtekRTL8100.kext |
| Keyboard (PS/2) | ✅ | VoodooPS2 |
| Touchpad (Synaptics) | ✅ | VoodooPS2 |
| Brightness Control | ✅ | SSDT-PNLF + BrightnessKeys |
| Battery Status | ✅ | ECEnabler + SMCBatteryManager |
| USB 2.0 | ✅ | XhciPortLimit enabled |
| USB 3.0 | ✅ | Intel xHCI |
| SD Card Reader | ✅ | RealtekCardReader |
| Fan/Temp Monitoring | ✅ | SMCDellSensors |
| WiFi (AR9485) | ❌ | Not supported on Big Sur |
| Bluetooth (AR9485) | ❌ | Not supported on Big Sur |
| Sleep/Wake | ⚠️ | May not wake properly |
| iCloud/iMessage | ⚠️ | May need serial regeneration |

---

## Quick Reference — What OpenCore Simplify Generates vs What Needs Fixing

The tool generates a good base but has some issues for the Dell Inspiron 3521. Here's what to fix:

| Setting | Tool Generates | What to Fix | Why |
|---|---|---|---|
| ig-platform-id | `03006601` | `04006601` | 0004 is correct for LVDS+VGA+HDMI layout |
| GPU framebuffer patches | None | Add con0/con1/con2 types | Fixes black screen |
| boot-args | `-v debug=0x100 keepsyms=1` | Add `alcid=29 igfxonln=1 -igfxnohdmi` | Audio + GPU fixes |
| AppleXcpmCfgLock | False | True | Dell BIOS CFG Lock is locked |
| AppleXcpmExtraMsrs | False | True | Required for Ivy Bridge |
| XhciPortLimit | False | True | Needed for USB mapping |
| SecureBootModel | Default | Disabled | Dell BIOS doesn't support it |
| PickerMode | Builtin | External | Needed for OpenCanopy GUI |
| HideAuxiliary | True | False | Need to see recovery options |
| AppleIntelCPUPowerManagement | Enabled | Remove from config | Conflicts with XCPM |
| SSDT-PLUG.aml | Not included | Add to ACPI | CPU power management |
| OpenCanopy.efi | Not included | Add to Drivers | GUI boot picker |
| HfsPlus.efi | Included | Replace with OpenHfsPlus.efi | Open source equivalent |

---

## Quick Reference — Boot Process

| Step | Action | Key |
|---|---|---|
| Enter BIOS | Restart → spam key | F2 |
| Boot Menu | Restart → spam key | F12 |
| Reset NVRAM | In OpenCore picker | Space → Reset NVRAM |
| Select USB | In boot menu | Arrow keys → Enter |
| Select SSD | In OpenCore picker | Arrow keys → Enter |

---

## Quick Reference — Common Fixes

| Problem | Fix |
|---|---|
| Black screen after verbose | Wait 30s → if still black → Reset NVRAM |
| Kernel panic | Boot from USB → Reset NVRAM |
| WiFi not working | Use Ethernet (AR9485 not supported) |
| Audio not working | `sudo nvram boot-args="alcid=29"` |
| Sleep issues | System Preferences > Battery > Never sleep |
| USB not working | Re-run USBToolBox, rebuild UTBMap.kext |
| iCloud not working | Generate new serial with GenSMBIOS |
| Stuck at Apple logo | Boot from USB → Reset NVRAM |
| "GUID required" error | Use Terminal: `diskutil eraseDisk APFS "Name" GPT /dev/disk0` |
| "Load image failed" | Re-download recovery with macrecovery |

---

## File Locations

| File | Location |
|---|---|
| Fixed EFI (source) | `C:\Users\SHINDA\Desktop\EFI\` |
| USB EFI (bootable) | `E:\EFI\` |
| Config backup | `C:\Users\SHINDA\Desktop\EFI\OC\config.plist.backup` |
| Hardware info | `C:\Users\SHINDA\Desktop\system-info-dell-3521-inspiron.txt` |
| OpCore Simplify output | `C:\Users\SHINDA\Desktop\OpCore-Simplify-main\Results\EFI\` |

---

## Community References

- [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [Dortania GPU Patching — HD 4000](https://dortania.github.io/GPU-Patching/Intel/HD4000.html)
- [AppleALC Audio Layouts](https://github.com/acidanthera/AppleALC/wiki/Supported-codecs)
- [OpenCore Configuration Reference](https://dortania.github.io/docs/latest/Configuration.html)
- [OpenCore PKG (macrecovery)](https://github.com/acidanthera/OpenCorePkg)
- [USBToolBox — USB Port Mapping](https://github.com/USBToolBox/UTBTool)
- [OpenCore Simplify — EFI Generator](https://github.com/lzhoang2801/OpCore-Simplify)
- [OCAuxiliaryTools](https://github.com/IC00501/Opencore-Tools)
- [ProperTree — Config Editor](https://github.com/corpnewt/ProperTree)

---

*Generated for Dell Inspiron 3521 — i5-3337U — macOS Big Sur*
*Based on standard Hackintosh community workflow*
