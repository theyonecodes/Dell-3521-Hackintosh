#!/bin/bash
set -e

echo "=== Dell 3521: transfer OpenCore EFI from USB to internal Kingston disk0s1 ==="

VOL=$(diskutil info "/Volumes/Install macOS Big Sur" 2>/dev/null | awk '/Part of Whole/{print $4}')
[ -z "$VOL" ] && { echo "ERROR: USB installer volume not found"; exit 1; }
SRCEFI=$(diskutil list "$VOL" | awk '$2=="EFI"{print $NF; exit}')
[ -z "$SRCEFI" ] && { echo "ERROR: USB EFI partition not found"; exit 1; }
echo "Source USB EFI: $SRCEFI (on $VOL)"

BOOTVOL=$(diskutil info / | awk '/Part of Whole/{print $4}')
[ -z "$BOOTVOL" ] && BOOTVOL=$(df / | tail -1 | awk '{print $1}' | sed -E 's|/dev/||;s|s[0-9]+$||')
echo "Boot container: $BOOTVOL"
CONTLINE=$(diskutil list | grep "Container $BOOTVOL" | head -1)
TARGETDISK=$(echo "$CONTLINE" | awk '{print $NF}' | sed -E 's/disk([0-9]+)s.*/disk\1/')
[ -z "$TARGETDISK" ] && { echo "ERROR: could not resolve physical disk for boot container"; exit 1; }
[ "$TARGETDISK" = "$VOL" ] && { echo "ERROR: refusing - target disk is the USB"; exit 1; }
TARGETEFI=$(diskutil list "$TARGETDISK" | awk '$2=="EFI"{print $NF; exit}')
[ -z "$TARGETEFI" ] && { echo "ERROR: no EFI partition on internal disk $TARGETDISK"; exit 1; }
echo "Target internal disk: $TARGETDISK, EFI partition: $TARGETEFI"

SRCM="/Volumes/EFI-SRC"; TGTM="/Volumes/EFI-TGT"
mkdir -p "$SRCM" "$TGTM"
mount -t msdos "/dev/$SRCEFI" "$SRCM"
mount -t msdos "/dev/$TARGETEFI" "$TGTM"

echo "Backing up current internal EFI..."
rm -rf "$TGTM/EFI.orig-"*
[ -d "$TGTM/EFI" ] && ditto "$TGTM/EFI" "$TGTM/EFI.orig-$(date +%Y%m%d)"
rm -rf "$TGTM/EFI"

echo "Copying EFI from USB..."
ditto "$SRCM/EFI" "$TGTM/EFI"
sync

echo "=== Verification ==="
md5 "$TGTM/EFI/BOOT/BOOTx64.efi" "$TGTM/EFI/OC/OpenCore.efi" "$TGTM/EFI/OC/config.plist"
echo "Expected: BOOTx64 c2e80064f0d6e8a588b7c2f278ec6a88 / OpenCore c171f38a5a047c2803981f3439fd9183 / config 14d07f539f88e8a66630868b53643cab"
ls "$TGTM/EFI/OC/Drivers" "$TGTM/EFI/OC/Kexts" >/dev/null

umount "$SRCM"
umount "$TGTM" 2>/dev/null || diskutil unmount "$TGTM"
echo "DONE - internal EFI installed on $TARGETEFI. USB can be removed."
