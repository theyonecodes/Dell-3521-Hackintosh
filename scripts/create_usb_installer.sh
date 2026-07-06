#!/bin/bash
# Dell 3521 Hackintosh - USB Installer Creator

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

EFI_SOURCE="$HOME/Downloads/Dell-3521-Hackintosh/Output/EFI"
RECOVERY_SOURCE="$HOME/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot"

echo "💾 Creating USB Installer for Dell 3521 Hackintosh"

# Check sources exist
if [ ! -d "$EFI_SOURCE" ]; then
    echo -e "${RED}❌ EFI not found at $EFI_SOURCE${NC}"
    echo "Run ./scripts/build_opencore.sh first"
    exit 1
fi

if [ ! -d "$HOME/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot" ]; then
    echo -e "${RED}❌ Recovery image not found${NC}"
    echo "Run macrecovery.py first"
    exit 1
fi

# List disks
echo "Available disks:"
lsblk

echo -e "${YELLOW}⚠️  INSERT YOUR USB DRIVE NOW (≥16GB)${NC}"
echo "Press Enter after inserting USB..."
read -p ""

lsblk

echo -e "${YELLOW}Enter your USB device (e.g., sdc):${NC}"
read -p "Device (e.g., sdc): " USB_DEVICE

if [ -z "$USB_DEVICE" ]; then
    echo -e "${RED}No device specified${NC}"
    exit 1
fi

USB_DEV="/dev/$USB_DEVICE"

# Verify
echo -e "${YELLOW}You selected: $USB_DEV${NC}"
lsblk | grep "^${USB_DEVICE} "
echo -e "${RED}⚠️  THIS WILL ERASE ALL DATA ON $USB_DEV${NC}"
read -p "Type 'YES' to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted"
    exit 1
fi

# Unmount
echo "🔄 Unmounting existing partitions..."
sudo umount ${USB_DEVICE}* 2>/dev/null || true

# Create GPT
echo "📝 Creating GPT partition table..."
sudo sgdisk -Z /dev/${USB_DEVICE}  # Zap
sudo sgdisk -o /dev/sdc  # New GPT

# Create partition
echo "📝 Creating EFI partition..."
sudo sgdisk -n 1:0:0 -t 1:EF00 /dev/sdc

# Format
PARTITION="${USB_DEVICE}1"
if [ ! -e "/dev/$PARTITION" ]; then
    # Wait for partition to appear
    sleep 2
    udevadm settle
fi

sudo mkfs.fat -F32 -s 1 -n "OPENCORE" "/dev/$PARTITION"

# Mount and populate
mkdir -p /mnt/usb_installer
sudo mount "/dev/$PARTITION" /mnt/usb_installer

echo "📂 Copying EFI..."
sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/usb_installer/EFI/

echo "📂 Copying macOS Recovery..."
cp -r ~/Downloads/OpCore/OpenCore-0.7.8-RELEASE/Utilities/macrecovery/com.apple.recovery.boot /mnt/usb_installer/

# Verify
echo "📂 Verifying USB structure..."
ls -la /mnt/usb_installer/
ls -la /mnt/usb_installer/EFI/
ls -la /mnt/usb_installer/com.apple.recovery.boot/

# Sync
sync
sudo umount /mnt/usb_installer
rmdir /mnt/usb_installer

echo -e "${GREEN}✅ USB Installer created successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Plug USB into Dell 3521"
echo "2. Boot with F12, select USB"
echo "3. Follow docs/macos-installation.md"