# Dual-Boot Guide

## Recommended Layout

| Partition | Size | Filesystem |
|-----------|------|------------|
| EFI | 500MB | FAT32 |
| Windows/Linux | 50GB+ | NTFS/ext4 |
| macOS | 60GB+ | APFS |
| Data (optional) | Remaining | exFAT |

## Windows + macOS

### Install Order
1. Install Windows first (with GPT/UEFI)
2. Shrink Windows partition
3. Install macOS to freed space
4. OpenCore auto-detects Windows

### After macOS Install
If Windows doesn't boot:
1. Boot macOS
2. Mount EFI
3. Check `EFI/Microsoft/` exists
4. If missing, use [Visual BCD](https://www.wincert.net/forum/topic/1315-visual-bcd/) to rebuild

## Linux + macOS

### Install Order
1. Install Linux first
2. Shrink Linux partition
3. Install macOS
4. Restore OpenCore (Linux may overwrite EFI)

### Restore OpenCore After Linux

```bash
sudo mkdir -p /mnt/efi
sudo mount /dev/sda1 /mnt/efi
sudo cp -r ~/Downloads/Dell-3521-Hackintosh/Output/EFI/* /mnt/efi/EFI/
```

### Add macOS to GRUB (Optional)

Add to `/etc/grub.d/40_custom`:
```
menuentry 'macOS' {
    search --no-floppy --fs-uuid --set=root XXXX-XXXX
    chainloader /EFI/OC/OpenCore.efi
}
```
Then run: `sudo grub-mkconfig -o /boot/grub/grub.cfg`

## Shared Data Partition

exFAT works on all OSes without drivers:
- **macOS**: Native read/write
- **Windows**: Native read/write
- **Linux**: `sudo apt install exfat-fuse exfat-utils`

## Boot Keys

| Key | Action |
|-----|--------|
| F12 | Boot menu |
| F2 | BIOS setup |
| OpenCore picker | Default boot |