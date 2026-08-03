#!/bin/bash
# Build macOS Big Sur 11.7.11 installer USB with this repo's EFI
# Run on macOS with the USB plugged in
# Usage: ./create_usb_installer.sh /dev/diskX

set -e

USB_DISK="${1}"
if [ -z "$USB_DISK" ]; then
    echo "Usage: $0 /dev/diskX"
    echo "Find your USB with: diskutil list"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EFI_SOURCE="$REPO_ROOT/EFI"

echo "=== Building macOS Big Sur 11.7.11 Installer USB ==="
echo "USB Disk: $USB_DISK"
echo "EFI Source: $EFI_SOURCE"
echo

# Verify installer app exists
INSTALLER_APP="/Applications/Install macOS Big Sur.app"
if [ ! -d "$INSTALLER_APP" ]; then
    echo "Downloading Big Sur 11.7.11..."
    softwareupdate --fetch-full-installer --full-installer-version 11.7.11
fi

if [ ! -d "$INSTALLER_APP" ]; then
    echo "ERROR: $INSTALLER_APP not found. Download failed?"
    exit 1
fi

# Verify EFI source exists
if [ ! -d "$EFI_SOURCE" ]; then
    echo "ERROR: EFI source not found at $EFI_SOURCE"
    exit 1
fi

# Confirm
echo "⚠️  THIS WILL ERASE $USB_DISK COMPLETELY"
read -p "Continue? [y/N] " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

# Partition USB: GPT, ESP (200MB FAT32) + Installer (HFS+)
echo "Partitioning USB as GPT..."
diskutil partitionDisk "$USB_DISK" GPT \
    "MS-DOS FAT32" "EFI" 200M \
    "JHFS+" "Install macOS Big Sur" R

# Find the new partitions
USB_ESP=$(diskutil list "$USB_DISK" | awk '$3=="EFI"{print $NF; exit}')
USB_INST=$(diskutil list "$USB_DISK" | awk '$3=="Apple_HFS"{print $NF; exit}')

if [ -z "$USB_ESP" ] || [ -z "$USB_INST" ]; then
    echo "ERROR: Could not find new partitions"
    diskutil list "$USB_DISK"
    exit 1
fi

echo "USB ESP: $USB_ESP"
echo "USB Installer: $USB_INST"

# Create installer (takes 15-30 min)
echo "Creating installer on $USB_INST (this takes 15-30 minutes)..."
sudo "$INSTALLER_APP/Contents/Resources/createinstallmedia" \
    --volume "/Volumes/Install macOS Big Sur" --nointeraction

# Copy EFI to USB ESP
echo "Mounting USB ESP ($USB_ESP) and copying EFI..."
ESP_MOUNT="/Volumes/ESP-USB-BUILD"
mkdir -p "$ESP_MOUNT"
sudo mount -t msdos "/dev/$USB_ESP" "$ESP_MOUNT"

echo "Copying EFI from $EFI_SOURCE..."
sudo ditto "$EFI_SOURCE" "$ESP_MOUNT/EFI"
sync

# Verify
echo "Verifying copied EFI..."
MD5_BOOTX64=$(md5 -q "$ESP_MOUNT/EFI/BOOT/BOOTx64.efi")
MD5_OPENCORE=$(md5 -q "$ESP_MOUNT/EFI/OC/OpenCore.efi")
MD5_CONFIG=$(md5 -q "$ESP_MOUNT/EFI/OC/config.plist")

EXPECTED_BOOTX64="c2e80064f0d6e8a588b7c2f278ec6a88"
EXPECTED_OPENCORE="c171f38a5a047c2803981f3439fd9183"
EXPECTED_CONFIG="23353fe0675c2f6ea3a8c2f6cb02b640"

echo "BOOTx64.efi: $MD5_BOOTX64"
echo "OpenCore.efi: $MD5_OPENCORE"
echo "config.plist: $MD5_CONFIG"

if [ "$MD5_BOOTX64" = "$EXPECTED_BOOTX64" ] && \
   [ "$MD5_OPENCORE" = "$EXPECTED_OPENCORE" ] && \
   [ "$MD5_CONFIG" = "$EXPECTED_CONFIG" ]; then
    echo "✅ All MD5s match!"
else
    echo "❌ MD5 mismatch!"
    exit 1
fi

sudo diskutil unmount "$ESP_MOUNT"

echo
echo "✅ USB installer ready!"
echo "Plug into Dell, F12 → UEFI USB → OpenCore picker → Install macOS Big Sur"
