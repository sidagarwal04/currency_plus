#!/bin/bash

# Quick Start Emulator Testing Script
# Usage: ./start_emulator_test.sh

set -e

PROJECT_DIR="/Users/sidagarwal/Documents/GitHub/currency_plus"
EMULATOR_NAME="Medium_Phone_API_36.1"
EMULATOR_PATH="~/Library/Android/sdk/emulator/emulator"

echo "🚀 Currency Plus - Emulator Testing"
echo "===================================="
echo ""

# Step 1: Check if emulator is already running
echo "📱 Checking for running emulator..."
if adb devices | grep -q "emulator"; then
    echo "✅ Emulator already running!"
else
    echo "🔄 Starting emulator: $EMULATOR_NAME"
    echo "   (This may take 30-60 seconds)"
    eval $EMULATOR_PATH "-avd $EMULATOR_NAME" &
    
    # Wait for emulator to boot
    echo "⏳ Waiting for emulator to boot..."
    sleep 45
    
    # Verify it's running
    if ! adb devices | grep -q "emulator"; then
        echo "❌ Emulator failed to start"
        exit 1
    fi
fi

# Step 2: Verify ADB connection
echo ""
echo "🔗 Checking ADB connection..."
DEVICES=$(adb devices -l | grep emulator)
echo "✅ Connected: $DEVICES"

# Step 3: Navigate to project
echo ""
echo "📂 Navigating to project: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Step 4: Run the app
echo ""
echo "🚀 Starting Flutter app on emulator..."
echo ""
echo "💡 Quick Tips:"
echo "   • Press 'r' to Hot Reload (instant refresh)"
echo "   • Press 'R' to Hot Restart (full restart)"
echo "   • Press 'q' to quit"
echo ""

flutter run

