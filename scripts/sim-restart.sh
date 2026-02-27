#!/usr/bin/env bash
# sim-restart.sh — Boot or restart the iPhone 17 Pro Max simulator.
# Usage: ./scripts/sim-restart.sh

DEVICE_NAME="iPhone 17 Pro Max"

UDID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -oE '[A-F0-9]{8}-([A-F0-9]{4}-){3}[A-F0-9]{12}' | head -1)

if [ -z "$UDID" ]; then
    echo "Error: Could not find a simulator named '$DEVICE_NAME'." >&2
    exit 1
fi

STATUS=$(xcrun simctl list devices | grep "$UDID" | grep -oE '\(Booted\)|\(Shutdown\)')

if [ "$STATUS" = "(Booted)" ]; then
    echo "Shutting down $DEVICE_NAME ($UDID)..."
    xcrun simctl shutdown "$UDID"
fi

echo "Booting $DEVICE_NAME ($UDID)..."
xcrun simctl boot "$UDID"
open -a Simulator
echo "Done."
