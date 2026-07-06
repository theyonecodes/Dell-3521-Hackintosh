# FAQ

## Why Big Sur 11?

HD 4000 (Ivy Bridge) only supports up to Big Sur 11 natively. Monterey+ requires Metal GPU which HD 4000 lacks.

## Why MacBookAir5,2?

i5-3337U is Ivy Bridge ULV (17W TDP). MacBookAir5,2 matches perfectly - same CPU generation, same power profile.

## Can I use a newer macOS?

Yes, but requires [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher). Adds complexity and potential instability.

## Can I upgrade Wi-Fi?

**Yes!** Replace with **Broadcom BCM94352HMB (DW1550)** for:
- 5GHz 802.11ac
- Continuity features (Handoff, AirDrop)
- No extra kexts needed

## Do I need a Mac?

**No!** Use `macrecovery.py` from OpenCorePkg to download recovery directly.

## What if I forget to copy EFI?

Boot from USB again, open Terminal in Recovery, copy EFI to internal drive. No data lost.

## How to update?

1. Backup EFI
2. System Preferences → Software Update
3. Update kexts if needed
4. Rebuild cache: `sudo kextcache -i /`

## Can I use iMessage?

Yes - generate valid serials with GenSMBIOS and set in config.plist.

## Where to get help?

- [r/hackintosh](https://reddit.com/r/hackintosh/)
- [Dortania Discord](https://discord.gg/Wxam8aH)
- [OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/)

## What's the cost?

| Item | Cost |
|------|------|
| USB | $5-10 |
| SSD 240GB | $20-30 |
| RAM 8GB | $15-25 |
| Wi-Fi Card | $15-20 |
| **Total** | **$55-85** |

vs $1000+ for comparable Mac.