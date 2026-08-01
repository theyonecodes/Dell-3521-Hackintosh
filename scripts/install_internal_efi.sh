#!/bin/bash
# Dell Inspiron 3521 Hackintosh — INTERACTIVE OpenCore EFI installer.
#
# Nothing is auto-detected. You pick the SOURCE (the EFI partition that holds
# the working OpenCore, usually on the USB) and the TARGET (the internal disk's
# EFI partition) from a numbered menu. This tool NEVER deletes anything: any
# existing target EFI is renamed to EFI.orig-<date> instead.
#
# Usage:
#   bash install_internal_efi.sh          interactive install
#   bash install_internal_efi.sh --list   just list disks, change nothing

set -e

if [ "$(id -u)" != "0" ]; then
    exec sudo bash "$0" "$@"
fi

LIST_ONLY=0
[ "$1" = "--list" ] && LIST_ONLY=1

physdisks() { diskutil list physical 2>/dev/null | grep -oE '/dev/disk[0-9]{1,2}'; }
proto()  { diskutil info "$1" 2>/dev/null | awk -F: '/Protocol/{gsub(/ /,"",$2); print $2}'; }
efi_of() { diskutil list "$1" 2>/dev/null | awk '$2=="EFI"{print $NF; exit}'; }
dsize()  { diskutil info "$1" 2>/dev/null | awk -F: '/Disk Size/{gsub(/^ +/,"",$2); print $2}'; }
dname()  { diskutil info "$1" 2>/dev/null | awk -F: '/Media Name/{gsub(/^ +/,"",$2); print $2}'; }

DISKS=(); PARTS=(); ROWS=()
for d in $(physdisks); do
    p=$(efi_of "$d")
    [ -z "$p" ] && continue
    DISKS+=("$d"); PARTS+=("$p")
    ROWS+=("$d  ($(proto "$d"), $(dsize "$d"), $(dname "$d"))  -> EFI partition $p")
done
[ ${#DISKS[@]} -eq 0 ] && { echo "No physical disks with an EFI partition found."; exit 1; }

echo
echo "=== Disks with an EFI partition ==="
for i in "${!ROWS[@]}"; do
    echo "  [$i] ${ROWS[$i]}"
done
echo
echo "  SOURCE should be the disk with the WORKING OpenCore (the USB stick)."
echo "  TARGET should be the INTERNAL disk whose macOS you booted."

[ "$LIST_ONLY" = 1 ] && { echo "List-only mode: nothing was changed."; exit 0; }

pick() {
    local n
    while true; do
        read -r -p "$1 " n
        [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -lt ${#DISKS[@]} ] && { REPLY="$n"; return; }
        echo "Invalid — enter a number from the list above."
    done
}

echo
pick "Select SOURCE disk number (working OpenCore, usually the USB):"
SRC=${DISKS[$REPLY]}; SRCP=${PARTS[$REPLY]}
pick "Select TARGET disk number (internal disk, macOS boot disk):"
TGT=${DISKS[$REPLY]}; TGTP=${PARTS[$REPLY]}

[ "$SRC" = "$TGT" ] && { echo "ERROR: source and target are the same disk."; exit 1; }

SM="/Volumes/EFI-SRC"; TM="/Volumes/EFI-TGT"
prep_mountpoint() {
    local mp="$1"
    if mount | grep -q " on $mp ("; then
        echo "ERROR: $mp is already an active mountpoint. Unmount it first, then retry."; exit 1
    fi
    rm -rf "$mp" 2>/dev/null || true
    mkdir -p "$mp"
}
prep_mountpoint "$SM"; prep_mountpoint "$TM"

mount -t msdos "/dev/$SRCP" "$SM" 2>/dev/null || { echo "ERROR: could not mount $SRCP (source)."; exit 1; }
mount | grep -q " on $SM (" || { echo "ERROR: mount of $SRCP did not take effect."; exit 1; }
if [ ! -f "$SM/EFI/OC/OpenCore.efi" ]; then
    echo "ERROR: $SRCP does not contain EFI/OC/OpenCore.efi — not the working OpenCore EFI."
    umount "$SM" 2>/dev/null; exit 1
fi
echo
echo "SOURCE  $SRCP  (mounted at $SM)"
ls "$SM/EFI/OC" | sed 's/^/    /'
echo "    config.plist  $(md5 -q "$SM/EFI/OC/config.plist")"

mount -t msdos "/dev/$TGTP" "$TM" 2>/dev/null || { echo "ERROR: could not mount $TGTP (target)."; umount "$SM" 2>/dev/null; exit 1; }
mount | grep -q " on $TM (" || { echo "ERROR: mount of $TGTP did not take effect."; umount "$SM" 2>/dev/null; exit 1; }
echo
echo "TARGET  $TGTP  (mounted at $TM)"
if [ -d "$TM/EFI" ]; then
    ls "$TM/EFI/OC" 2>/dev/null | sed 's/^/    /'
    [ -f "$TM/EFI/OC/config.plist" ] && echo "    config.plist  $(md5 -q "$TM/EFI/OC/config.plist")"
else
    echo "    (no EFI folder — will create one)"
fi

echo
echo "Plan:"
echo "  - rename $TGTP/EFI -> EFI.orig-$(date +%Y%m%d)   (only if it exists)"
echo "  - copy $SRCP/EFI -> $TGTP/EFI"
read -r -p "Continue? [y/N] " yn
case "$yn" in y|Y|yes) ;; *)
    echo "Aborted — nothing was changed."
    umount "$SM" 2>/dev/null; umount "$TM" 2>/dev/null; exit 0;; esac

if [ -d "$TM/EFI" ]; then
    mv "$TM/EFI" "$TM/EFI.orig-$(date +%Y%m%d)"
    echo "Backed up old internal EFI as EFI.orig-$(date +%Y%m%d)."
fi
ditto "$SM/EFI" "$TM/EFI"
sync

echo
echo "=== Verification ==="
B=$(md5 -q "$TM/EFI/BOOT/BOOTx64.efi")
O=$(md5 -q "$TM/EFI/OC/OpenCore.efi")
C=$(md5 -q "$TM/EFI/OC/config.plist")
echo "  BOOTx64.efi    $B"
echo "  OpenCore.efi   $O"
echo "  config.plist   $C"

echo
read -r -p "Set this OpenCore as the boot entry via bless? [y/N] " yn
case "$yn" in y|Y|yes)
    bless --mount "$TM" --setBoot --file "$TM/EFI/OC/OpenCore.efi" && echo "boot entry set." \
      || echo "bless failed (normal on some Dell firmware) — press F12 at power-on and select OpenCore."
    ;; *) echo "Skipped — press F12 at power-on to select OpenCore.";; esac

umount "$SM" 2>/dev/null
umount "$TM" 2>/dev/null || diskutil unmount "$TM" 2>/dev/null || true
echo
echo "DONE. Internal EFI on $TGTP now contains the working OpenCore."
echo "Reboot WITHOUT the USB and confirm OpenCore starts from the internal disk."
