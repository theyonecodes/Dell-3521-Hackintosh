#!/bin/bash
# Dell Inspiron 3521 Hackintosh: copy the WORKING OpenCore EFI (from the USB)
# onto the internal disk's EFI partition so the USB can be removed.
#
# Run this ON THE DELL from a terminal on the running Big Sur install:
#   curl -L -o install.sh \
#     https://raw.githubusercontent.com/theyonecodes/Dell-3521-Hackintosh/BigSur/scripts/install_internal_efi.sh
#   bash install.sh
set -e

EXPECT_BOOT="c2e80064f0d6e8a588b7c2f278ec6a88"
EXPECT_OC="c171f38a5a047c2803981f3439fd9183"
EXPECT_CONFIG="1ad657775240cd49a4fefc6d5e58126a"
SRCM="/Volumes/EFI-SRC"
TGTM="/Volumes/EFI-TGT"

echo "=== Dell 3521: transfer working OpenCore EFI (USB) to internal disk ==="

physdisks() { # physical whole disks as /dev/diskN
    diskutil list physical 2>/dev/null | grep -oE '/dev/disk[0-9]{1,2}'
    if [ -z "$(diskutil list physical 2>/dev/null)" ]; then
        diskutil list | grep -oE '/dev/disk[0-9]{1,2}'
    fi
}
proto() { # disk protocol, e.g. USB / SATA
    diskutil info "$1" 2>/dev/null | awk -F: '/Protocol/{gsub(/ /,"",$2); print $2}'
}
efi_of() { # EFI partition id of a disk, e.g. disk0s1
    diskutil list "$1" 2>/dev/null | awk '$2=="EFI"{print $NF; exit}'
}
probe_has_opencore() { # mount EFI partition $1 and check for OpenCore.efi
    local m="/Volumes/EFI-PROBE"
    mkdir -p "$m"
    if mount -t msdos "/dev/$1" "$m" 2>/dev/null; then
        if [ -f "$m/EFI/OC/OpenCore.efi" ]; then
            umount "$m" 2>/dev/null
            return 0
        fi
        umount "$m" 2>/dev/null
    fi
    return 1
}

SRCEFI=""
if [ -f /Volumes/EFI/EFI/OC/OpenCore.efi ]; then
    SRCEFI=$(diskutil info /Volumes/EFI 2>/dev/null | awk '/Device Identifier/{print $3}')
    echo "Source: already-mounted EFI at /Volumes/EFI ($SRCEFI)"
else
    echo "Scanning physical disks for the USB EFI with OpenCore.efi..."
    for d in $(physdisks); do
        [ "$(proto "$d")" = "USB" ] || continue
        p=$(efi_of "$d")
        [ -z "$p" ] && continue
        if probe_has_opencore "$p"; then SRCEFI="$p"; echo "Source: USB EFI partition $SRCEFI on $d"; break; fi
    done
    if [ -z "$SRCEFI" ]; then
        echo "No USB disk found with OpenCore.efi; scanning all disks (excluding internal)..."
        for d in $(physdisks); do
            p=$(efi_of "$d")
            [ -z "$p" ] && continue
            if probe_has_opencore "$p"; then SRCEFI="$p"; echo "Source: EFI partition $SRCEFI on $d"; break; fi
        done
    fi
    [ -z "$SRCEFI" ] && { echo "ERROR: no EFI partition containing OpenCore.efi was found on the USB."; echo "Disks visible:"; diskutil list physical; echo "Plug in the working USB and retry."; exit 1; }
fi

TARGETEFI=""
for d in $(physdisks); do
    [ "$(proto "$d")" = "USB" ] && continue
    p=$(efi_of "$d")
    [ -z "$p" ] && continue
    TARGETEFI="$p"
    echo "Target: internal disk $d, EFI partition $TARGETEFI"
    break
done
[ -z "$TARGETEFI" ] && { echo "ERROR: no EFI partition found on a non-USB (internal) disk."; exit 1; }

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

echo "=== Verification (MD5) ==="
BOOT=$(md5 -q "$TGTM/EFI/BOOT/BOOTx64.efi")
OC=$(md5 -q "$TGTM/EFI/OC/OpenCore.efi")
CFG=$(md5 -q "$TGTM/EFI/OC/config.plist")
echo "BOOTx64.efi    $BOOT  (expected $EXPECT_BOOT)"
echo "OpenCore.efi   $OC  (expected $EXPECT_OC)"
echo "config.plist   $CFG  (expected $EXPECT_CONFIG)"
if [ "$BOOT" = "$EXPECT_BOOT" ] && [ "$OC" = "$EXPECT_OC" ] && [ "$CFG" = "$EXPECT_CONFIG" ]; then
    echo "All three files match the verified build."
else
    echo "WARNING: MD5 mismatch — files were modified; the copied EFI may not be the verified build."
fi

echo "Setting internal OpenCore as the boot entry..."
bless --mount "$TGTM" --setBoot --file "$TGTM/EFI/OC/OpenCore.efi" 2>/dev/null \
    && echo "boot entry set." \
    || echo "bless did not set a boot entry (normal on some Dell firmware) — press F12 at boot and select OpenCore on the internal disk."

umount "$SRCM"
umount "$TGTM" 2>/dev/null || diskutil unmount "$TGTM"
echo "DONE - internal EFI installed on $TARGETEFI. USB can be removed."
echo "Next: reboot without the USB and confirm OpenCore starts from the internal SSD."
