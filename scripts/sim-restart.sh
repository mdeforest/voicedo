#!/usr/bin/env bash
# sim-restart.sh — Clean build and (re)launch VoiceDo on the iPhone 17 Pro Max simulator.
#
# What it does:
#   1. Cleans the Xcode build folder (equivalent to ⌘⇧K)
#   2. Builds the app fresh
#   3. Boots the simulator (or restarts it if already running)
#   4. Installs and launches the new binary
#
# Usage: ./scripts/sim-restart.sh

set -euo pipefail

DEVICE_NAME="iPhone 17 Pro Max"
SCHEME="VoiceDo"
PROJECT="VoiceDo.xcodeproj"
BUNDLE_ID="com.voicedo.app"

# ── 1. Resolve simulator UDID ──────────────────────────────────────────────────

UDID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -oE '[A-F0-9]{8}-([A-F0-9]{4}-){3}[A-F0-9]{12}' | head -1)

if [ -z "$UDID" ]; then
    echo "Error: Could not find a simulator named '$DEVICE_NAME'." >&2
    exit 1
fi

echo "▸ Found $DEVICE_NAME ($UDID)"

# ── 2. Clean build folder ──────────────────────────────────────────────────────

echo "▸ Cleaning build folder..."
xcodebuild clean \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -quiet

# ── 3. Build ───────────────────────────────────────────────────────────────────

echo "▸ Building..."
BUILD_DIR=$(mktemp -d)

xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -derivedDataPath "$BUILD_DIR" \
    -quiet

APP_PATH=$(find "$BUILD_DIR" -name "*.app" -not -name "*.appex" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Built .app not found in $BUILD_DIR" >&2
    exit 1
fi

echo "▸ Built: $(basename "$APP_PATH")"

# ── 4. Boot/restart simulator ──────────────────────────────────────────────────

STATUS=$(xcrun simctl list devices | grep "$UDID" | grep -oE '\(Booted\)|\(Shutdown\)')

if [ "$STATUS" = "(Booted)" ]; then
    echo "▸ Terminating running app..."
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
else
    echo "▸ Booting simulator..."
    xcrun simctl boot "$UDID"
fi

open -a Simulator

# Give the simulator a moment to be ready
xcrun simctl bootstatus "$UDID" -b > /dev/null

# ── 5. Install and launch ──────────────────────────────────────────────────────

echo "▸ Installing..."
xcrun simctl install "$UDID" "$APP_PATH"

echo "▸ Launching..."
xcrun simctl launch "$UDID" "$BUNDLE_ID"

echo "✓ Done — VoiceDo is running on $DEVICE_NAME."
