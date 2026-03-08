#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RELEASE_DIR="$PROJECT_DIR/release"
DMG_PATH="$RELEASE_DIR/Recopy.dmg"

echo "Building Recopy (Release)..."
xcodebuild -project "$PROJECT_DIR/Recopy.xcodeproj" \
  -scheme Recopy \
  -configuration Release \
  clean build \
  SYMROOT="$PROJECT_DIR/build" \
  2>&1 | tail -5

APP_PATH="$PROJECT_DIR/build/Release/Recopy.app"

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Build failed, app not found at $APP_PATH"
  exit 1
fi

echo "Creating DMG..."
mkdir -p "$RELEASE_DIR"
DMG_STAGING=$(mktemp -d)
cp -R "$APP_PATH" "$DMG_STAGING/Recopy.app"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create -volname "Recopy" \
  -srcfolder "$DMG_STAGING" \
  -ov -format UDZO \
  "$DMG_PATH"

rm -rf "$DMG_STAGING" "$PROJECT_DIR/build"

echo ""
echo "Done! DMG created at: $DMG_PATH"
echo "Size: $(du -h "$DMG_PATH" | cut -f1)"
