#!/bin/bash
# Builds Stash.app. Everything stays on this drive — SwiftPM keeps its cache in .build/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/Stash.app"
CONFIG="${1:-release}"

echo "▸ Compiling ($CONFIG)…"
swift build -c "$CONFIG" --package-path "$ROOT"

BIN="$ROOT/.build/$CONFIG/Stash"

echo "▸ Assembling app bundle…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Stash"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/Resources/Stash.icns" "$APP/Contents/Resources/Stash.icns"

echo "▸ Signing (ad-hoc, local use)…"
codesign --force --sign - "$APP" 2>/dev/null

echo "✓ Built $APP"
echo "  Run it:  open \"$APP\""
