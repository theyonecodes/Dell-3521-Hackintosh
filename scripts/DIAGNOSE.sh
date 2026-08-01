#!/bin/bash
OUT=/Volumes/EFI/DIAGNOSE-output.txt
{
  echo "===== SW VERS ====="
  sw_vers
  echo "===== NETWORKSETUP ====="
  networksetup -listallhardwareports
  echo "===== IFCONFIG ====="
  ifconfig -a | grep -E '^[a-z].*:|status|ether|inet ' | grep -iE 'en|airport|wlan'
  echo "===== KEXTSTAT (wifi stack) ====="
  kextstat | grep -iE '80211|Atheros|AirPort|corecapture|HS80211'
  echo "===== LOG SHOW (kernel wifi lines, last 12m) ====="
  log show --last 12m --style compact --predicate 'process == "kernel"' 2>/dev/null | grep -iE 'atheros|80211|airport|awdl|wl[0-9]|en[0-9]' | head -60
  echo "===== DRIVER ATTACH (Atheros / 80211 / interface) ====="
  ioreg -l -w0 | grep -i -A6 'AirPort_Atheros\|IO80211Interface\|Atheros40'
  echo "===== IO80211 PLANE ====="
  ioreg -p IO80211Plane -l -w0
  echo "===== CARD NODE (IODeviceTree) ====="
  ioreg -p IODeviceTree -l -w0 | grep -i -B2 -A20 'pci168c'
  echo "===== END ====="
} 2>&1 | tee "$OUT"
echo "SAVED_TO=$OUT"
