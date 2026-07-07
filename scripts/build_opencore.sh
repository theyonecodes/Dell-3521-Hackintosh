#!/bin/bash
# Dell 3521 Hackintosh - OpenCore EFI Builder

set -e

OC_SIMPLIFY_DIR="$HOME/Downloads/Hackintosh/OpCore-Simplify"
OUTPUT_DIR="$HOME/Downloads/Dell-3521-Hackintosh/Output"

echo "⚙️ Building OpenCore EFI with OpCore-Simplify..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if OpCore-Simplify exists
if [ ! -d "$OC_SIMPLIFY_DIR" ]; then
    echo "❌ OpCore-Simplify not found at $OC_SIMPLIFY_DIR"
    echo "Run ./scripts/setup_environment.sh first"
    exit 1
fi

# Check hardware report exists
if [ ! -f "$HOME/Downloads/Hackintosh/OpCore-Simplify/SysReport/Report.json" ]; then
    echo "❌ Hardware report not found. Run ./scripts/create_hardware_report.sh first"
    exit 1
fi

echo "📦 Building OpenCore EFI..."

# Run OpCore-Simplify in non-interactive mode (if supported)
# Otherwise we need to run it interactively

echo "📋 Building EFI with OpCore-Simplify..."
echo "This will launch the interactive menu. Please follow these steps:"
echo ""
echo "1. Select '1. Select Hardware Report'"
echo "   -> Enter: $HOME/Downloads/Hackintosh/OpCore-Simplify/SysReport/Report.json"
echo ""
echo "2. Select '2. Select macOS Version'"
echo "   -> Select '20. macOS Big Sur 11'"
echo ""
echo "3. Press Enter for '3. Customize ACPI Patch' (skip)"
echo ""
echo "4. Select '4. Customize Kexts'"
echo "   Enter: 1,2,3,4,6,8,11,12,17,21,22,23,41,42,44,45,64,65,75,76,80,81,82,84,85"
echo ""
echo "4. Customize SMBIOS -> Select '30. MacBookAir5,2'"
echo ""
echo "5. Select '6. Build OpenCore EFI'"
echo ""
echo "Press Enter to continue..."
read -p ""

cd "$HOME/Downloads/Hackintosh/OpCore-Simplify"
./OpCore-Simplify.py

# Copy result to output
if [ -d "Results/EFI" ]; then
    rm -rf "$OUTPUT_DIR/EFI"
    cp -r Results/EFI "$OUTPUT_DIR/EFI"
    echo "✅ EFI built and copied to $OUTPUT_DIR/EFI"
else
    echo "❌ Build failed - EFI not found in Results/"
    exit 1
fi

echo ""
echo "✅ EFI build complete!"
echo "Output: $OUTPUT_DIR/EFI"

# Download macOS recovery image (Big Sur 11.0)
echo ""
echo "🔽 Downloading macOS Big Sur recovery image..."

OPENCORE_PKG="$HOME/Downloads/Hackintosh/OpenCorePkg"

if [ -d "$OPENCORE_PKG" ]; then
    cd "$OPENCORE_PKG/Utilities/macrecovery"
    
    # Download Big Sur recovery
    python3 macrecovery.py -b Mac-2BD1B31983FE1663 -m 00000000000000000 download
    
    # Copy to Output
    mkdir -p "$OUTPUT_DIR/com.apple.recovery.boot"
    if [ -d "com.apple.recovery.boot" ]; then
        cp -r "com.apple.recovery.boot"/* "$OUTPUT_DIR/com.apple.recovery.boot/"
        echo "✅ Recovery image downloaded to $OUTPUT_DIR/com.apple.recovery.boot"
    else
        echo "⚠️ Create USB: Copy recovery manually from $OPENCORE_PKG/Utilities/macrecovery/com.apple.recovery.boot"
    fi
else
    echo "⚠️ Download macOS recovery manually:"
    echo "1. cd ~/Downloads/Hackintosh/OpenCorePkg/Utilities/macrecovery"
    echo "2. python3 macrecovery.py -b Mac-2BD1B31983FE1663 -m 00000000000000000 download"
    echo "3. Copy com.apple.recovery.boot to USB"
fi

echo ""
echo "Next steps:"
echo "1. Verify EFI: ls -la $OUTPUT_DIR/EFI/OC/Kexts/"
echo "2. Download confirmed: ls -la $OUTPUT_DIR/com.apple.recovery.boot/"
echo "3. Create USB installer: docs/macos-installation.md"