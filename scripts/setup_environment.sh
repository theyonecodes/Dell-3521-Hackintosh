#!/bin/bash
# Dell 3521 Hackintosh - Environment Setup Script
# Run this script to install all required dependencies

set -e

echo "🔧 Setting up Hackintosh build environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &> /dev/null; then
        PM="apt"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    else
        echo -e "${RED}Unsupported package manager${NC}"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PM="brew"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Detected package manager: $PM${NC}"

# Install dependencies
echo -e "${YELLOW}📦 Installing required packages...${NC}"

if [ "$PM" = "apt" ]; then
    sudo apt update
    sudo apt install -y git python3 python3-pip wget curl unzip base-devel gdisk sgdisk dosfstools
elif [ "$PM" = "pacman" ]; then
    sudo pacman -S --needed git python python-pip wget curl unzip base-devel gdisk dosfstools
elif [ "$PM" = "dnf" ]; then
    sudo dnf install -y git python3 python3-pip wget curl unzip @development-tools gdisk dosfstools
elif [ "$PM" = "brew" ]; then
    brew install git python3 wget curl unzip gnu-sed
fi

# Install Python packages
echo -e "${YELLOW}🐍 Installing Python packages...${NC}"
pip3 install --user --upgrade pip
pip3 install --user plistlib34 biplist 2>/dev/null || true

# Verify installation
echo -e "${GREEN}✅ Verifying installations...${NC}"

tools=("git" "python3" "wget" "curl" "unzip" "sgdisk" "mkfs.fat")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool: $(which $tool)${NC}"
    else
        echo -e "${RED}❌ $tool: NOT FOUND${NC}"
    fi
done

# Create project directories
mkdir -p ~/Downloads/Dell-3521-Hackintosh/{docs,scripts,images,config_examples,Tools}

echo -e "${GREEN}✅ Environment setup complete!${NC}"
echo
echo "Next steps:"
echo "1. cd ~/Downloads/Dell-3521-Hackintosh"
echo "2. Run ./scripts/create_hardware_report.sh"
echo "3. Run ./scripts/build_opencore.sh"
echo "4. Follow docs/hardware-validation.md"