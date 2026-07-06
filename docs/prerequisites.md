# 📋 Prerequisites

Before beginning the Hackintosh process, ensure you have all the required hardware, software, and tools properly set up.

---

## 🖥️ Hardware Requirements

### Essential

| Component            | Requirement                              | Notes                                  |
|---------------------|-------------------------------------------|----------------------------------------|
| **Computer Model**  | Dell Inspiron 3521                       | Or similar Ivy Bridge ULV system       |
| **CPU**            | Intel Core i5-3337U                     | Ivy Bridge, 2C/4T, 17W TDP            |
| **RAM**            | Minimum 4GB (8GB recommended)            | DDR3 1600MHz SODIMM                   |
| **Storage**         | 120GB+ SSD                               | SATA SSD recommended for performance   |
| **USB Drive**       | 16GB+ USB 2.0/3.0 flash drive            | For macOS installer                    |
| **External Mouse**  | USB or Bluetooth mouse                   | Optional, for setup assistance         |

> ⚠️ **Important**: Using an **SSD** is **highly recommended** for acceptable performance in macOS. HDDs will work but feel sluggish.

### Optional Upgrades

| Component            | Model Recommendation                     | Reason                                  |
|---------------------|-------------------------------------------|----------------------------------------|
| **SSD**            | Samsung 870 EVO, Crucial MX500             | Faster boot & application launch       |
| **RAM**            | 8GB DDR3 1600MHz SODIMM (2x4GB)           | Better multitasking performance        |
| **Wi-Fi Card**      | Broadcom BCM94352HMB (DW1550)             | Better compatibility & Continuity      |


---

## 🐧 Software Requirements

### Host System Setup

- **Operating System**: Linux (Ubuntu, CachyOS, Debian, etc.)
- **Internet Connection**: Required for downloading tools & macOS installer
- **Terminal Access**: Basic command-line familiarity

**Required Packages**:
```bash
# For Ubuntu/Debian-based systems
sudo apt update
sudo apt install -y git python3 python3-pip wget curl unzip base-devel gdisk

# For Arch/Manjaro/CachyOS
sudo pacman -S --needed git python wget curl base-devel unzip gdisk
```

### macOS System Requirements

| Component            | Requirement                              |
|---------------------|-------------------------------------------|
| **macOS Version**   | Big Sur 11.0 (20.99.99)                  |
| **Storage Space**   | 30GB+ free space                          |
| **Boot Mode**       | UEFI                                       |
| **Secure Boot**     | Disabled                                   |


---

## 🧰 Tools & Utilities

| Tool                    | Purpose                                      | Download Link                           |
|-------------------------|-----------------------------------------------|----------------------------------------|
| **OpCore-Simplify**    | EFI generation & configuration               | [GitHub](https://github.com/lzhoang2801/OpCore-Simplify) |
| **OpenCorePkg**        | OpenCore files & macrecovery utility         | [GitHub](https://github.com/acidanthera/OpenCorePkg) |
| **ProperTree**         | Config.plist editing                         | [GitHub](https://github.com/corpnewt/ProperTree) |
| **USBToolBox**         | USB port mapping                              | [GitHub](https://github.com/USBToolBox/tool) |
| **IORegistryExplorer** | System debugging (optional)                  | [Mac App Store](#) |

### Convenience Scripts

All required tools will be downloaded automatically by our setup scripts. You can find them in the [`scripts/`](../scripts/) directory:

- [`setup_environment.sh`](../scripts/setup_environment.sh) - Installs required tools
- [`create_hardware_report.sh`](../scripts/create_hardware_report.sh) - Generates hardware report
- [`build_opencore.sh`](../scripts/build_opencore.sh) - Builds OpenCore EFI


---

## 🔐 Safety Precautions

### Data Backup

✅ **Back up all important data** before beginning. **Hackintoshing involves formatting drives, changing BIOS settings, and potential instability.**

> 💡 **Pro Tip**: Create **full disk images** of your existing storage using Clonezilla or similar tools.

### BIOS Settings Backup

1. Enter BIOS (F2 during boot)
2. Navigate to **Settings > Support > BIOS Settings Backup**
3. Save BIOS settings to USB drive
4. Record all current settings (take photos)

### Hardware Inventory

```bash
# Create hardware inventory file
sudo lshw > hardware_inventory.txt
lspci -nn > lspci_info.txt
lsusb > lsusb_info.txt
uname -a > uname_info.txt
```

Store these files in a safe location.


---

## 🚀 Preparation Checklist

- [ ] Dell 3521 with i5-3337U
- [ ] 16GB+ USB flash drive
- [ ] 120GB+ SSD installed
- [ ] Linux environment ready
- [ ] Internet connection available
- [ ] BIOS settings backed up
- [ ] Important data backed up
- [ ] Tools & packages installed


---

## 🔁 Next Steps

After completing the prerequisites, proceed to:

📖 **[Hardware Validation](hardware-validation.md)** → 
Learn how to verify your hardware compatibility and create a validated hardware report.

```mermaid
flowchart LR
    A[📋 Prerequisites] --> B[🔍 Hardware Validation]
    B --> C[⚙️ EFI Configuration]
```