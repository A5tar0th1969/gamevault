#!/usr/bin/env bash
#
# GameVault — Linux startup script
# Supports: native Electron, Flatpak Steam, Lutris, Heroic Games Launcher
#
# Usage:
#   ./start.sh              # Launch with default settings
#   ./start.sh --dev        # Launch in dev mode (Vite + Electron)
#   ./start.sh --web        # Launch as web app only (browser-based)
#   ./start.sh --help       # Show this help

set -euo pipefail

APP_NAME="GameVault"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
ELECTRON_BIN=""

# --- Detect available runtime ---
detect_runtime() {
  # Check for system Electron
  if command -v electron &>/dev/null; then
    ELECTRON_BIN="electron"
    return 0
  fi

  # Check for npx-installed Electron
  if command -v npx &>/dev/null && npx --yes electron --version &>/dev/null 2>&1; then
    ELECTRON_BIN="npx electron"
    return 0
  fi

  # Check for node_modules electron
  if [ -f "$APP_DIR/node_modules/.bin/electron" ]; then
    ELECTRON_BIN="$APP_DIR/node_modules/.bin/electron"
    return 0
  fi

  # Check for Flatpak Electron
  if command -v flatpak &>/dev/null && flatpak list --app 2>/dev/null | grep -qi electron; then
    local electron_flatpak
    electron_flatpak=$(flatpak list --app 2>/dev/null | grep -i electron | head -1 | awk '{print $2}')
    if [ -n "$electron_flatpak" ]; then
      ELECTRON_BIN="flatpak run $electron_flatpak"
      return 0
    fi
  fi

  return 1
}

# --- Check dependencies ---
check_deps() {
  local missing=0

  if ! command -v node &>/dev/null; then
    echo "⚠️  Node.js is not installed."
    echo "   Install it from: https://nodejs.org (v18+ recommended)"
    echo "   Or use your package manager: sudo apt install nodejs npm"
    echo ""
    missing=1
  fi

  if ! command -v npm &>/dev/null; then
    echo "⚠️  npm is not installed."
    echo "   Usually included with Node.js."
    echo ""
    missing=1
  fi

  if [ "$missing" -eq 1 ]; then
    echo "Install the missing dependencies and re-run this script."
    exit 1
  fi
}

# --- Install dependencies if needed ---
install_deps() {
  if [ ! -d "$APP_DIR/node_modules" ]; then
    echo "📦 Installing dependencies..."
    cd "$APP_DIR" && npm install
    echo "✅ Dependencies installed."
  fi
}

# --- Launch as web app (browser-based, no Electron needed) ---
launch_web() {
  echo "🌐 Starting $APP_NAME as web app..."
  echo "   Open your browser to http://localhost:3000"

  if command -v python3 &>/dev/null; then
    cd "$APP_DIR" && python3 -m http.server 3000 --directory dist 2>/dev/null || true
  elif command -v python &>/dev/null; then
    cd "$APP_DIR" && python -m http.server 3000 --directory dist 2>/dev/null || true
  else
    echo "❌ Python not found. Install python3 to use web mode."
    exit 1
  fi
}

# --- Launch with Electron ---
launch_electron() {
  echo "🎮 Launching $APP_NAME..."

  # Build if needed
  if [ ! -d "$APP_DIR/dist" ]; then
    echo "🔨 Building application..."
    cd "$APP_DIR" && npm run build
  fi

  # Set Linux-specific environment variables
  export ELECTRON_ENABLE_STACK_DUMPING=true
  export ELECTRON_ENABLE_SECURITY_WARNINGS=false

  # Wayland support (optional)
  if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    export ELECTRON_USE_OZONE_PLATFORM=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    echo "   Wayland detected — enabling Ozone support"
  fi

  # X11 fallback
  if [ -z "${XDG_SESSION_TYPE:-}" ] || [ "$XDG_SESSION_TYPE" = "x11" ]; then
    export ELECTRON_USE_OZONE_PLATFORM=0
  fi

  # Detect GPU and rendering
  if command -v glxinfo &>/dev/null && glxinfo 2>/dev/null | grep -qi "renderer.*software"; then
    echo "   Software renderer detected — disabling GPU acceleration"
    export ELECTRON_DISABLE_GPU=1
  fi

  # Launch
  if [ -n "$ELECTRON_BIN" ]; then
    cd "$APP_DIR" && $ELECTRON_BIN .
  else
    cd "$APP_DIR" && npx electron .
  fi
}

# --- Create .desktop file for Linux desktop integration ---
install_desktop() {
  local desktop_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  local icon_dir="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/256x256/apps"

  mkdir -p "$desktop_dir" "$icon_dir" 2>/dev/null || true

  # Copy icon if available
  if [ -f "$APP_DIR/public/icon.png" ] && [ ! -f "$icon_dir/gamevault.png" ]; then
    cp "$APP_DIR/public/icon.png" "$icon_dir/gamevault.png" 2>/dev/null || true
  fi

  local desktop_file="$desktop_dir/gamevault.desktop"

  cat > "$desktop_file" << EOF
[Desktop Entry]
Name=GameVault
GenericName=Game Launcher
Comment=Unified gaming launcher with Steam, Xbox Game Pass & Epic Games Store
Exec=$APP_DIR/start.sh
Icon=gamevault
Terminal=false
Type=Application
Categories=Game;
Keywords=steam;xbox;epic;gaming;launcher;
StartupNotify=true
StartupWMClass=GameVault
EOF

  chmod +x "$desktop_file" 2>/dev/null || true
  echo "📌 Desktop shortcut created at: $desktop_file"

  # Update desktop database
  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$desktop_dir" 2>/dev/null || true
  fi
}

# --- Main ---
main() {
  local mode="auto"

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --dev) mode="dev" ;;
      --web) mode="web" ;;
      --help|-h)
        echo "GameVault — $APP_NAME"
        echo ""
        head -7 "$0" | tail -6
        exit 0
        ;;
      --install-desktop) mode="desktop" ;;
      *) echo "Unknown option: $arg"; exit 1 ;;
    esac
  done

  case "$mode" in
    web)
      check_deps
      install_deps
      cd "$APP_DIR" && npm run build
      launch_web
      ;;
    dev)
      check_deps
      install_deps
      echo "🔧 Launching in dev mode..."
      cd "$APP_DIR" && npm run electron:dev
      ;;
    desktop)
      install_desktop
      exit 0
      ;;
    auto)
      check_deps 2>/dev/null || true

      # Try Electron first, fall back to web
      if detect_runtime || [ -d "$APP_DIR/node_modules" ]; then
        install_deps 2>/dev/null || true
        launch_electron
      else
        echo "ℹ️  Electron not found — launching as web app..."
        install_deps
        cd "$APP_DIR" && npm run build
        launch_web
      fi
      ;;
  esac
}

main "$@"
