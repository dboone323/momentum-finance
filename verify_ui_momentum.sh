#!/bin/bash
APP_PATH="/Users/danielstevens/Library/Developer/Xcode/DerivedData/MomentumFinance-eyokbxaaqtnuhkdigvcnogoazegu/Build/Products/Debug/MomentumFinance.app"
SCREENSHOT_DIR="$(pwd)/screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "Launching MomentumFinance..."
open "$APP_PATH"

echo "Waiting for app to launch..."
sleep 5

echo "Taking screenshot..."
# Capture the main screen or specific window if possible, but full screen is safer for now
screencapture -x "$SCREENSHOT_DIR/momentum_finance_launch.png"

echo "Closing MomentumFinance..."
pkill -f "MomentumFinance"

echo "Done. Screenshot saved to $SCREENSHOT_DIR/momentum_finance_launch.png"
