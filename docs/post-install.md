# ✨ Post-Installation Setup

Complete these steps after your first successful boot into macOS to finalize your Hackintosh.

---

## 🔊 Step 1: Audio Configuration

### Fix Audio (if not working)

```bash
# Test current audio
system_profiler SPAudioDataType

# If no sound, try different layout-ids:
# Edit config.plist using ProperTree (see below)
# Add to boot-args: alcid=1
# Try: 1, 2, 3, 7, 11, 13, 15
```

### Install ProperTree for Config Editing

```bash
# Download and install ProperTree
git clone https://github.com/corpnewt/ProperTree.git
cd ProperTree
python3 ProperTree.command
```

**Audio Layout-ids to Try:**
| Layout-ID | Best For |
|-----------|----------|
| `1` | Most common (try first) |
| `2` | Alternative |
| `3` | Laptop speakers |
| `7` | External speakers/headphones |
| `11` | Some Dells |
| `13` | Alternative |
| `15` | Alternative |

---

## 🔌 Step 2: USB Port Mapping (CRITICAL)

### 9.1 Run USBToolBox

```bash
# Mount EFI partition
diskutil mount disk0s1

# Run USBToolBox
open /Volumes/EFI/OC/Tools/USBToolBox.app
```

1. Click **Scan** and wait for completion
2. Click **Save** → Save `UTBMap.kext` to Desktop
3. Quit USBToolBox

### 9.2 Install Custom USB Map

```bash
# Mount EFI partition
diskutil mount disk0s1

# Replace UTBDefault.kext with your custom map
sudo rm -rf /Volumes/EFI/OC/Kexts/UTBDefault.kext
sudo cp -rf ~/Desktop/UTBMap.kext /Volumes/EFI/OC/Kexts/
```

### 9.3 Update config.plist with ProperTree

```bash
# Open with ProperTree
git clone https://github.com/corpnewt/ProperTree.git
cd ProperTree
python3 ProperTree.command
```

1. Open `/Volumes/EFI/OC/config.plist`
2. Press **Ctrl/Cmd + R** to **OC Snapshot** (refreshes kext list)
3. **If >15 USB ports**: Enable `XhciPortLimit` in Kernel → Quirks
3. **Save** and close

---

## 🔋 Step 3: Battery & Power Management

### Verify Battery Status
```bash
# Check battery status
system_profiler SPPowerDataType
pmset -g batt
```

### Verify Sleep/Wake
```bash
# Test sleep
pmset sleepnow

# Check wake
pmset -g log | grep -i "sleep\|wake" | head -20
```

### Enable Power Management
```bash
# Enable power management
sudo pmset -a sleep 10
sudo pmset -a displaysleep 5
sudo pmset -a disksleep 10
sudo pmset -a hibernatemode 3
sudo pmset -a autopoweroff 1
sudo pmset -a powernap 1
```

---

## 🔧 Step 3: System Optimizations

### Enable TRIM for SSD
```bash
sudo trimforce enable
```

### Disable Hibernation (Optional - for faster sleep/wake)
```bash
# Disable deep hibernation (faster wake)
sudo pmset -a hibernatemode 0
sudo pmset -a standby 0
sudo pmset -a autopoweroff 0

# Or keep safe sleep but faster
sudo pmset -a hibernatemode 3
sudo pmset -a standby 1
sudo pmset -a autopoweroff 1
```

### Disable Spotlight Indexing (Optional - for older SSDs)
```bash
sudo mdutil -i off /
```

### Disable Spotlight for External Drives
```bash
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
```

---

## 🔧 Step 4: System Tweaks

### Disable Window Animations (Optional)
```bash
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
```

### Disable Window Resize Animation
```bash
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
```

### Show Hidden Files in Finder
```bash
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder
```

### Show Path Bar in Finder
```bash
defaults write com.apple.finder ShowPathbar -bool true
```

### Show Status Bar in Finder
```bash
defaults write com.apple.finder ShowStatusBar -bool true
```

### Disable Auto-Correct (Optional)
```bash
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
```

### Disable Smart Quotes/Dashes
```bash
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
```

---

## 🔒 Security & Privacy

### Enable FileVault (Optional)
```bash
sudo fdesetup enable
```

### Configure Firewall
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
```

### Disable Guest Account
```bash
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
```

---

## 🔧 System Maintenance

### Reset NVRAM/PRAM (if needed)
```bash
# Boot with: Option + Command + P + R
# Hold for 20 seconds
```

### Reset SMC (System Management Controller)
```bash
# Shut down, then:
# Shift + Control + Option + Power (hold 10 seconds)
```

### Repair Disk Permissions
```bash
diskutil repairPermissions /
```

### Rebuild Spotlight Index
```bash
sudo mdutil -E /
```

---

## 📦 Recommended Additional Apps

| App | Purpose | Install Method |
|-----|---------|----------------|
| **MountEFI** | Mount EFI partition easily | `brew install --cask mountefi` or [GitHub](https://github.com/corpnewt/MountEFI) |
| **ProperTree** | Edit config.plist | `git clone https://github.com/corpnewt/ProperTree` |
| **USBToolBox** | USB port mapping | Already in EFI/OC/Tools/ |
| **ProperTree** | config.plist editor | Already in EFI/OC/Tools/ |
| **Hackintool** | System info & patching | [GitHub](https://github.com/headkaze/Hackintool) |
| **IORegistryExplorer** | System debugging | Mac App Store |
| **HWiNFO** | Hardware monitoring | [Website](https://www.hwinfo.com/) |
| **Karibiner-Elements** | Keyboard remapping | [Website](https://karabiner-elements.pqrs.org/) |
| **Rectangle** | Window management | `brew install --cask rectangle` |
| **Stats** | Menu bar system monitor | [GitHub](https://github.com/exelban/stats) |

---

## 📋 Final Verification Checklist

- [ ] Audio working (test with layout-ids)
- [ ] Wi-Fi connected and stable
- [ ] Bluetooth working (pair devices)
- [ ] Ethernet working (if applicable)
- [ ] All USB ports mapped and working
- [ ] Battery status shows percentage
- [ ] Sleep/wake working correctly
- [ ] Display brightness controls work
- [ ] Audio input/output working
- [ ] Wi-Fi/Bluetooth persistence after sleep
- [ ] TRIM enabled on SSD
- [ ] No kernel panics after 24h usage

---

## 📋 Next Steps

📖 **[Troubleshooting](troubleshooting.md)** → 
Common issues and solutions.

```mermaid
flowchart LR
    A[✨ Post-Install] --> B[🐞 Troubleshooting]
    B --> C[Enjoy macOS]
```