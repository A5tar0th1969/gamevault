#!/usr/bin/env bash
# Generate iOS app icons from SVG source
# Requires: svg2png (rsvg-convert) or ImageMagick (convert)
#
# Usage: ./generate-icons.sh [source.svg]
# Defaults to icon.svg in same directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="${1:-$SCRIPT_DIR/icon.svg}"
OUTPUT_DIR="$SCRIPT_DIR/GameVault/Assets.xcassets/AppIcon.appiconset"

ICON_SIZES=(
  "120:120"
  "152:152"
  "167:167"
  "180:180"
  "192:192"
  "256:256"
  "512:512"
  "1024:1024"
)

mkdir -p "$OUTPUT_DIR"

echo "🎨 Generating iOS icons from: $SOURCE"

if command -v rsvg-convert &>/dev/null; then
  for size_pair in "${ICON_SIZES[@]}"; do
    w="${size_pair%%:*}"
    h="${size_pair##*:}"
    name="icon-${w}.png"
    echo "  → $name (${w}x${h})"
    rsvg-convert "$SOURCE" -w "$w" -h "$h" -o "$OUTPUT_DIR/$name"
  done
elif command -v convert &>/dev/null; then
  for size_pair in "${ICON_SIZES[@]}"; do
    w="${size_pair%%:*}"
    h="${size_pair##*:}"
    name="icon-${w}.png"
    echo "  → $name (${w}x${h})"
    convert -background none -size "${w}x${h}" "$SOURCE" "$OUTPUT_DIR/$name"
  done
else
  echo "❌ No SVG converter found."
  echo "   Install librsvg (rsvg-convert) or ImageMagick (convert):"
  echo "   brew install librsvg"
  echo "   # or: sudo apt install librsvg2-bin"
  echo ""
  echo "   Place PNG icons manually in: $OUTPUT_DIR"
  echo "   Required sizes: ${ICON_SIZES[*]}"
  exit 1
fi

echo ""
echo "✅ Icons generated in: $OUTPUT_DIR"
echo "   Open GameVault.xcodeproj in Xcode and run on device/simulator."
