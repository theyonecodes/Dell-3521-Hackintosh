#!/bin/bash
# Dell 3521 Hackintosh - USB Installer Creator
# Usage: sudo ./create_usb_installer.sh sdc --force

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
USB_DEVICE=""
FORCE=false
for arg in "$@"; do
    case $arg in
        --force|-f) FORCE=true ;;
        *) USB_DEVICE="$arg" ;;
    esac
done

EFI_SOURCE="/home/shinda/Downloads/Dell-3521-Hackintosh/Output/EFI"

# Find recovery image - check all possible locations
RECOVERY_LOCATIONS=(
    "/home/shinda/Downloads/Hackintosh/OpCore-Simplify/com.apple.recovery.boot"
    "/home/shinda/Downloads/Hackintosh/OpenCorePkg/Utilities/macrecovery/com.apple.recovery.boot"
    "/home/shinda/Downloads/Hackintosh/OpCore-Simplify/Results/com.apple.recovery.boot"
    "/home/shinda/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot"
    "/home/shinda/Downloads/OpCore/OpenCore-*/Utilities/macrecovery/com.apple.recovery.boot"
)

RECOVERY_SOURCE=""
for loc in "${RECOVERY_LOCATIONS[@]}"; do
    if [ -d "$loc" ]; then
        RECOVERY_SOURCE="$loc"
        break
    fi
done

echo "💾 Creating USB Installer for Dell 3521 Hackintosh"

# Check sources exist
if [ ! -d "$EFI_SOURCE" ]; then
    echo -e "${RED}❌ EFI not found at $EFI_SOURCE${NC}"
    echo "Run: ./scripts/build_opencore.sh first"
    exit 1
fi

if [ -z "$RECOVERY_SOURCE" ]; then
    echo -e "${RED}❌ Recovery image not found${NC}"
    echo "Download macOS recovery using OpCore-Simplify"
    exit 1
fi

echo "✅ Found EFI: $EFI_SOURCE"
echo "✅ Found Recovery: $RECOVERY_SOURCE"

# List disks
echo ""
lsblk

# Get USB device
if [ -z "$USB_DEVICE" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Plug your USB drive now, then enter device (e.g., sdc):${NC}"
    read -p "Device: " USB_DEVICE
fi

if [ -z "$USB_DEVICE" ]; then
    echo -e "${RED}❌ No device specified${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}You selected: /dev/$USB_DEVICE${NC}"

# Verify device exists
lsblk | grep -q "^${USB_DEVICE} " || { echo "❌ Device not found"; exit 1; }

# Unmount
echo "🔄 Unmounting..."
sudo umount /dev/${USB_DEVICE}* 2>/dev/null || true

# Create GPT
echo "📝 Creating GPT..."
sudo sgdisk -Z /dev/${USB_DEVICE}
sudo sgdisk -o /dev/${USB_DEVICE}

# Create EFI partition
echo "📝 Creating EFI partition..."
sudo sgdisk -n 1:0:0 -t 1:EF00 /dev/${USB_DEVICE}

# Wait for device
sleep 2

# Format
PARTITION="/dev/${USB_DEVICE}1"
sudo mkfs.fat -F32 -s 1 -n "OPENCORE" "$PARTITION"

# Mount
mkdir -p /mnt/usb_installer
sudo mount "$PARTITION" /mnt/usb_installer

echo ""
echo "📂 Copying EFI..."
sudo rsync -av --progress "$EFI_SOURCE/" /mnt/usb_installer/EFI/

echo ""
echo "📂 Copying Recovery..."
sudo rsync -av --progress "$RECOVERY_SOURCE/" /mnt/usb_installer/com.apple.recovery.boot/

# Verify
echo ""
echo "📂 Final structure:"
ls -la /mnt/usb_installer/
ls -la /mnt/usb_installer/EFI/
ls -la /mnt/usb_installer/com.apple.recovery.boot/ | head -5

# Sync and unmount
sync
sudo umount /mnt/usb_installer

echo ""
echo -e "${GREEN}✅ USB Installer created successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Plug USB into Dell 3521"
echo "2. Boot with F12, select USB"
echo "3. Follow docs/macos-installation.md"