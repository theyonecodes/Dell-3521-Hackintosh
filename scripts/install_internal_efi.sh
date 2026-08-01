#!/bin/bash
# Dell Inspiron 3521 Hackintosh: copy the WORKING OpenCore EFI (from the USB)
# onto the internal disk's EFI partition so the USB can be removed.
#
# Run this ON THE DELL from a terminal on the running Big Sur install:
#   curl -L -o install_internal_efi.sh \
#     https://raw.githubusercontent.com/theyonecodes/Dell-3521-Hackintosh/BigSur/scripts/install_internal_efi.sh
#   bash install_internal_efi.sh
set -e

SRCM="/Volumes/EFI-SRC"
TGTM="/Volumes/EFI-TGT"
EXPECT_BOOT="c2e80064f0d6e8a588b7c2f278ec6a88"
EXPECT_OC="c171f38a5a047c2803981f3439fd9183"
EXPECT_CONFIG="1ad657775240cd49a4fefc6d5e58126a"

echo "=== Dell 3521: transfer working OpenCore EFI (USB) to internal disk ==="

# --- locate the source EFI partition: the one containing OpenCore.efi ---
find_efi_with_opencore() {
    # Prefer EFI partitions on USB (Protocol: USB) disks — the source USB stick.
    # Fall back to any EFI partition containing OpenCore.efi that is NOT the
    # disk macOS runs from (the internal target).
    local disk part m proto boot
    boot=$(df / | tail -1 | awk '{print $1}' | sed -E 's|/dev/disk([0-9]{1,2})s[0-9]+.*|disk\1|')
    for disk in $(diskutil list | sed -n 's/^\(\/dev\/disk[0-9]\{1,2\}\)$/ \1 /p'); do
        part=$(diskutil list "$disk" 2>/dev/null | awk '$2=="EFI"{print $NF; exit}')
        [ -z "$part" ] && continue
        proto=$(diskutil info "$disk" 2>/dev/null | awk -F: '/Protocol/{gsub(/ /,"",$2); print $2}')
        [ "$proto" = "USB" ] || continue
        m="/Volumes/EFI-PROBE"
        mkdir -p "$m"
        mount -t msdos "/dev/$part" "$m" 2>/dev/null || { umount "$m" 2>/dev/null; continue; }
        if [ -f "$m/EFI/OC/OpenCore.efi" ]; then
            echo "$part"
            umount "$m"
            return 0
        fi
        umount "$m" 2>/dev/null
    done
    # fallback: any EFI with OpenCore on a disk other than the boot disk
    for disk in $(diskutil list | sed -n 's/^\(\/dev\/disk[0-9]\{1,2\}\)$/ \1 /p'); do
        [ "$disk" = "/dev/$boot" ] && continue
        part=$(diskutil list "$disk" 2>/dev/null | awk '$2=="EFI"{print $NF; exit}')
        [ -z "$part" ] && continue
        m="/Volumes/EFI-PROBE"
        mkdir -p "$m"
        mount -t msdos "/dev/$part" "$m" 2>/dev/null || { umount "$m" 2>/dev/null; continue; }
        if [ -f "$m/EFI/OC/OpenCore.efi" ]; then
            echo "$part"
            umount "$m"
            return 0
        fi
        umount "$m" 2>/dev/null
    done
    return 1
}

if [ -f /Volumes/EFI/EFI/OC/OpenCore.efi ]; then
    SRCEFI=$(diskutil info /Volumes/EFI 2>/dev/null | awk '/Device Identifier/{print $3}')
    echo "Source: already-mounted EFI at /Volumes/EFI ($SRCEFI)"
else
    SRCEFI=$(find_efi_with_opencore) || { echo "ERROR: no EFI partition containing OpenCore.efi found on the USB. Plug in the working USB and retry."; exit 1; }
    echo "Source: USB EFI partition $SRCEFI"
fi

# --- locate the target: EFI partition on the disk that macOS runs from ---
BOOTDISK=$(df / | tail -1 | awk '{print $1}' | sed -E 's|/dev/disk([0-9]{1,2})s[0-9]+.*|disk\1|')
SRCDISK=$(echo "$SRCEFI" | sed -E 's/^disk([0-9]{1,2})s.*/disk\1/')
if [ "$BOOTDISK" = "$SRCDISK" ]; then
    echo "ERROR: the running macOS volume is on the USB itself ($BOOTDISK)."
    echo "Boot the DELL via the USB OpenCore picker into the INTERNAL Big Sur, then re-run this script."
    exit 1
fi
TARGETEFI=$(diskutil list "$BOOTDISK" | awk '$2=="EFI"{print $NF; exit}')
[ -z "$TARGETEFI" ] && { echo "ERROR: no EFI partition on internal disk $BOOTDISK"; exit 1; }
echo "Target: internal disk $BOOTDISK, EFI partition $TARGETEFI"

# --- copy ---
mkdir -p "$SRCM" "$TGTM"
mount -t msdos "/dev/$SRCEFI" "$SRCM"
mount -t msdos "/dev/$TARGETEFI" "$TGTM"

echo "Backing up current internal EFI as EFI.orig-$(date +%Y%m%d)..."
rm -rf "$TGTM/EFI.orig-"*
[ -d "$TGTM/EFI" ] && ditto "$TGTM/EFI" "$TGTM/EFI.orig-$(date +%Y%m%d)"
rm -rf "$TGTM/EFI"

echo "Copying EFI from $SRCM to $TGTM..."
ditto "$SRCM/EFI" "$TGTM/EFI"
sync

# --- verify ---
echo "=== Verification (MD5) ==="
BOOT=$(md5 -q "$TGTM/EFI/BOOT/BOOTx64.efi")
OC=$(md5 -q "$TGTM/EFI/OC/OpenCore.efi")
CFG=$(md5 -q "$TGTM/EFI/OC/config.plist")
echo "BOOTx64.efi    $BOOT  (expected $EXPECT_BOOT)"
echo "OpenCore.efi   $OC  (expected $EXPECT_OC)"
echo "config.plist   $CFG  (expected $EXPECT_CONFIG)"
[ "$BOOT" = "$EXPECT_BOOT" ] && [ "$OC" = "$EXPECT_OC" ] && [ "$CFG" = "$EXPECT_CONFIG" ] \
    && echo "All three files match the verified build." \
    || echo "WARNING: MD5 mismatch — files were modified; the copied EFI may not be the verified build."

# --- set boot entry (best effort) ---
echo "Setting internal OpenCore as the boot entry..."
bless --mount "$TGTM" --setBoot --file "$TGTM/EFI/OC/OpenCore.efi" 2>/dev/null \
    && echo "boot entry set." \
    || echo "bless did not set a boot entry (normal on some Dell firmware) — press F12 at boot and select OpenCore on the internal disk."

umount "$SRCM"
umount "$TGTM" 2>/dev/null || diskutil unmount "$TGTM"
echo "DONE - internal EFI installed on $TARGETEFI. USB can be removed."
echo "Next: reboot without the USB and confirm OpenCore starts from the internal SSD."
