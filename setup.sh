#!/bin/zsh

# Currency Plus - Automated Setup Script
# This script sets up Flutter and Android SDK environment variables
# Run this in Terminal: chmod +x setup.sh && ./setup.sh

echo "🚀 Currency Plus Setup Script"
echo "=============================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check if zshrc exists
echo "${BLUE}Step 1: Checking shell configuration...${NC}"
if [ ! -f ~/.zshrc ]; then
    echo "${YELLOW}⚠️  ~/.zshrc not found. Creating...${NC}"
    touch ~/.zshrc
fi
echo "${GREEN}✓ Shell configuration ready${NC}"
echo ""

# Step 2: Check Flutter installation
echo "${BLUE}Step 2: Checking Flutter installation...${NC}"
if [ ! -d "/Users/sidagarwal/flutter" ]; then
    echo "${RED}✗ Flutter not found at /Users/sidagarwal/flutter${NC}"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi
echo "${GREEN}✓ Flutter found at /Users/sidagarwal/flutter${NC}"
echo ""

# Step 3: Check Android Studio installation
echo "${BLUE}Step 3: Checking Android Studio...${NC}"
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo "${GREEN}✓ Android SDK found at ~/Library/Android/sdk${NC}"
else
    echo "${YELLOW}⚠️  Android SDK not found. You'll need to install Android Studio.${NC}"
    echo "   Download from: https://developer.android.com/studio"
fi
echo ""

# Step 4: Add environment variables to zshrc
echo "${BLUE}Step 4: Setting up environment variables...${NC}"

# Check if variables are already set
if grep -q "ANDROID_HOME" ~/.zshrc; then
    echo "${YELLOW}⚠️  ANDROID_HOME already set in ~/.zshrc${NC}"
else
    echo "${YELLOW}Adding ANDROID_HOME to ~/.zshrc...${NC}"
    cat >> ~/.zshrc << 'EOF'

# ===== Currency Plus Setup (Added automatically) =====
# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# Flutter
export PATH="$PATH:/Users/sidagarwal/flutter/bin"
# ===== End Currency Plus Setup =====
EOF
    echo "${GREEN}✓ Added ANDROID_HOME to ~/.zshrc${NC}"
fi

if grep -q "/Users/sidagarwal/flutter/bin" ~/.zshrc; then
    echo "${YELLOW}Flutter PATH already set${NC}"
else
    echo "${YELLOW}Adding Flutter to PATH...${NC}"
    echo 'export PATH="$PATH:/Users/sidagarwal/flutter/bin"' >> ~/.zshrc
    echo "${GREEN}✓ Added Flutter to PATH${NC}"
fi
echo ""

# Step 5: Reload shell configuration
echo "${BLUE}Step 5: Reloading shell configuration...${NC}"
source ~/.zshrc
echo "${GREEN}✓ Shell configuration reloaded${NC}"
echo ""

# Step 6: Run Flutter doctor
echo "${BLUE}Step 6: Running Flutter doctor...${NC}"
echo ""
/Users/sidagarwal/flutter/bin/flutter doctor
echo ""

# Step 7: Check results
echo "${BLUE}Step 7: Verifying setup...${NC}"
echo ""

echo "Checking Flutter installation:"
/Users/sidagarwal/flutter/bin/flutter --version
echo ""

echo "Checking ANDROID_HOME:"
echo "ANDROID_HOME = $ANDROID_HOME"
echo ""

if [ -z "$ANDROID_HOME" ]; then
    echo "${RED}✗ ANDROID_HOME not set. Please restart Terminal and run this script again.${NC}"
    exit 1
fi

echo "${GREEN}✓ ANDROID_HOME is set${NC}"
echo ""

# Step 8: Suggest next steps
echo "${BLUE}Step 8: Setup Summary${NC}"
echo "=============================="
echo ""
echo "If you see ✓ marks above, your setup is complete!"
echo ""
echo "${YELLOW}Next Steps:${NC}"
echo "1. Close and reopen Terminal"
echo "2. Navigate to project: cd ~/Documents/GitHub/currency_plus"
echo "3. Accept Android licenses: flutter doctor --android-licenses"
echo "4. Build APK: flutter build apk --release"
echo ""
echo "${YELLOW}If you don't have Android Studio installed:${NC}"
echo "1. Download from: https://developer.android.com/studio"
echo "2. Install Android Studio"
echo "3. Let it download and install SDK components"
echo "4. Run this script again"
echo ""
echo "${GREEN}Setup Complete! 🎉${NC}"
