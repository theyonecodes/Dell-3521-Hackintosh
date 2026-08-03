#!/bin/bash
# Quick verification of EFI on a mounted ESP
# Usage: ./verify_efi.sh /Volumes/ESP

ESP_PATH="${1:-/Volumes/ESP}"

EXPECTED_BOOTX64="c2e80064f0d6e8a588b7c2f278ec6a88"
EXPECTED_OPENCORE="c171f38a5a047c2803981f3439fd9183"
EXPECTED_CONFIG="23353fe0675c2f6ea3a8c2f6cb02b640"
EXPECTED_BOOTMGfw_ALT="3a796d91c84cb79d704ac39aa5d6760c"

echo "=== Verifying EFI at $ESP_PATH ==="

check() {
    local file="$1"
    local expected="$2"
    if [ -f "$ESP_PATH/EFI/$file" ]; then
        actual=$(md5 -q "$ESP_PATH/EFI/$file")
        if [ "$actual" = "$expected" ]; then
            echo "✅ $file: $actual"
        else
            echo "❌ $file: $actual (expected: $expected)"
            return 1
        fi
    else
        echo "❌ $file: MISSING"
        return 1
    fi
}

check "BOOT/BOOTx64.efi" "$EXPECTED_BOOTX64"
check "OC/OpenCore.efi" "$EXPECTED_OPENCORE"
check "OC/config.plist" "$EXPECTED_CONFIG"
check "Microsoft/Boot/bootmgfw_alt.efi" "$EXPECTED_BOOTMGfw_ALT"

# Check .contentDetails
if [ -f "$ESP_PATH/EFI/Microsoft/Boot/.contentDetails" ]; then
    content=$(cat "$ESP_PATH/EFI/Microsoft/Boot/.contentDetails")
    if [ "$content" = "Windows" ]; then
        echo "✅ .contentDetails: Windows"
    else
        echo "❌ .contentDetails: '$content' (expected: Windows)"
    fi
else
    echo "❌ .contentDetails: MISSING"
fi

echo "=== Done ==="
