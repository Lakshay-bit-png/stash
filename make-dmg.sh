#!/bin/bash
# Packages Stash.app into a styled drag-to-install disk image.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/Stash.app"
STAGE="$ROOT/build/dmg-stage"
RW="$ROOT/build/stash-rw.dmg"
DMG="$ROOT/build/Stash.dmg"
VOLUME="Stash"

[ -d "$APP" ] || { echo "Build the app first: ./build.sh"; exit 1; }

rm -rf "$STAGE" "$RW" "$DMG"
mkdir -p "$STAGE/.background"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
cp "$ROOT/Resources/dmg-background.png" "$STAGE/.background/background.png"

# A writable image first, so Finder can lay the window out before it's compressed.
hdiutil create -volname "$VOLUME" -srcfolder "$STAGE" -ov -format UDRW "$RW" >/dev/null
hdiutil detach "/Volumes/$VOLUME" >/dev/null 2>&1 || true
hdiutil attach "$RW" -noautoopen >/dev/null

# Finder owns icon positions and the background picture; there is no hdiutil flag for them.
osascript <<APPLESCRIPT >/dev/null 2>&1 || echo "  (Finder styling skipped — the image still works)"
tell application "Finder"
  tell disk "$VOLUME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 860, 540}
    set theOptions to the icon view options of container window
    set arrangement of theOptions to not arranged
    set icon size of theOptions to 112
    set background picture of theOptions to file ".background:background.png"
    set position of item "Stash.app" of container window to {170, 230}
    set position of item "Applications" of container window to {490, 230}
    close
    open
    update without registering applications
    delay 2
  end tell
end tell
APPLESCRIPT

sync
hdiutil detach "/Volumes/$VOLUME" >/dev/null 2>&1 || true
hdiutil convert "$RW" -format UDZO -imagekey zlib-level=9 -o "$DMG" >/dev/null
rm -rf "$STAGE" "$RW"

echo "✓ $DMG  ($(du -h "$DMG" | cut -f1))"
