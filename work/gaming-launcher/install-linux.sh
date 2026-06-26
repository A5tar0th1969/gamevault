#!/usr/bin/env bash
# GameVault installer for Linux
# Run: sudo ./install-linux.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/opt/gamevault"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/256x256/apps"

echo "🎮 Installing GameVault..."

# Create directories
sudo mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# Copy application files
sudo cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
sudo rm -f "$INSTALL_DIR/install-linux.sh"

# Install icon
if [ -f "$INSTALL_DIR/public/icon.svg" ]; then
  sudo cp "$INSTALL_DIR/public/icon.svg" "$ICON_DIR/gamevault.svg"
fi
if [ -f "$INSTALL_DIR/public/icon.png" ]; then
  sudo cp "$INSTALL_DIR/public/icon.png" "$ICON_DIR/gamevault.png"
fi

# Install desktop file
if [ -f "$INSTALL_DIR/electron/gamevault.desktop" ]; then
  sudo cp "$INSTALL_DIR/electron/gamevault.desktop" "$DESKTOP_DIR/gamevault.desktop"
  sudo sed -i "s|Exec=.*|Exec=$INSTALL_DIR/start.sh|" "$DESKTOP_DIR/gamevault.desktop"
fi

# Make start script executable
sudo chmod +x "$INSTALL_DIR/start.sh"

# Update desktop database
if command -v update-desktop-database &>/dev/null; then
  sudo update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

# Update icon cache
if command -v gtk-update-icon-cache &>/dev/null; then
  sudo gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
fi

echo ""
echo "✅ GameVault installed to $INSTALL_DIR"
echo ""
echo "📌 Launch from application menu or run: $INSTALL_DIR/start.sh"
echo ""
echo "💡 To uninstall:"
echo "   sudo rm -rf $INSTALL_DIR $DESKTOP_DIR/gamevault.desktop $ICON_DIR/gamevault.*"
echo ""
echo "🎉 Game on!"
