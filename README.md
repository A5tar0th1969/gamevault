# GameVault — Cross-Platform Gaming Launcher

> A gaming UI launcher like Playnite/Steam with Steam Store, Xbox Game Pass, and Epic Game Store integration. Features a built-in fullscreen game mode inspired by Steam Big Picture / SteamOS with the Aniki ReMake UI design.

---

## ✨ Features

- **Unified Library** — Browse all your games from Steam, Xbox Game Pass, Epic Games Store, and local installs in one place
- **Store Integration** — Quick access to Steam Store, Xbox Game Pass catalog, and Epic Games Store
- **Fullscreen Game Mode** — Immersive Big Picture-style interface with hero banners, game shelves, and store cards
- **Aniki ReMake UI** — Dark, modern theme inspired by the popular Playnite theme
- **Game Details** — Rich modal overlay with metadata, genres, descriptions, and developer info
- **Search & Filter** — Real-time search and platform-based filtering
- **Cross-Platform** — Works on Windows, macOS, and Linux (with native game detection)
- **Zero Dependencies** — The standalone HTML version runs in any browser with no install required

## 🚀 Quick Start

### Option 1: Open in Browser (fastest)

Just open `index.html` in any modern browser:

```bash
open index.html          # macOS
xdg-open index.html      # Linux
start index.html         # Windows
```

Or serve with Python:

```bash
python3 -m http.server 3000
# Open http://localhost:3000
```

### Option 2: Electron App (full experience)

```bash
cd work/gaming-launcher
npm install
npm run electron:dev      # Development mode
npm run electron:start    # Production mode
```

### Option 3: Linux Setup

```bash
cd work/gaming-launcher
chmod +x start.sh install-linux.sh
./install-linux.sh        # System-wide install
./start.sh                # Launch
```

## 🎮 Fullscreen Mode

Click the **Fullscreen** button in the top bar or press **F11** to enter fullscreen game mode. This transforms the interface into a SteamOS-like Big Picture experience:

- Hero section with blurred game art, cover, title, and Play/Info buttons
- "Continue Playing" shelf with installed games
- Store cards (Steam / Xbox / Epic) with game counts
- "Installed Games" shelf
- Live clock display
- Navigate via top nav bar
- Press **Escape** or click **Exit** to leave

## 📁 Project Structure

```
├── index.html                    # Standalone launcher (zero deps, open in browser)
├── iso/                          # Bootable gaming OS ISO builder
│   ├── build-iso.sh              # Build script (requires Arch Linux + archiso)
│   ├── archiso/                  # archiso profile
│   │   ├── profile.conf          # ISO configuration
│   │   ├── packages.x86_64       # Packages to include
│   │   ├── airootfs/             # Root filesystem overlay
│   │   ├── grub/                 # GRUB boot theme
│   │   ├── efiboot/              # systemd-boot entries
│   │   └── syslinux/             # syslinux boot config
│   └── README.md                 # ISO build instructions
├── .gitignore
├── README.md
├── outputs/
│   └── index.html                # Built output
└── work/gaming-launcher/         # Electron + React + TypeScript project
    ├── electron/
    │   ├── main.js               # Electron main process (Win/Mac/Linux)
    │   ├── preload.js            # Context bridge
    │   └── gamevault.desktop     # Linux desktop entry
    ├── src/
    │   ├── App.tsx               # Main React app with view routing
    │   ├── components/
    │   │   ├── Sidebar.tsx       # Navigation sidebar
    │   │   ├── TopBar.tsx        # Search bar + fullscreen toggle
    │   │   ├── LibraryView.tsx   # Game grid with filters
    │   │   ├── GameCard.tsx      # Individual game card
    │   │   ├── StoreView.tsx     # Store integration views
    │   │   ├── FullscreenMode.tsx # SteamOS-like fullscreen UI
    │   │   ├── GameDetailsPanel.tsx # Modal game details
    │   │   └── Settings.tsx      # Settings panel
    │   ├── services/
    │   │   ├── gameDetection.ts  # Local game scanner (Steam/Xbox/Epic/Linux)
    │   │   └── storeIntegration.ts
    │   └── store/
    │       ├── gameStore.ts      # Zustand game state
    │       └── uiStore.ts        # Zustand UI state
    ├── start.sh                  # Linux launcher script
    ├── install-linux.sh          # Linux installer
    ├── package.json
    └── vite.config.ts
```

## 🔧 Linux Support

GameVault has full Linux support:

| Feature | Status |
|---|---|
| Electron + Wayland | ✅ Ozone platform auto-detect |
| Steam (native) | ✅ Path detection |
| Steam (Flatpak) | ✅ `~/.var/app/com.valvesoftware.Steam` |
| Heroic Games Launcher | ✅ Epic/GOG detection |
| Lutris | ✅ Game library scanning |
| Native Linux games | ✅ Standard paths |
| .desktop integration | ✅ MIME handlers (`steam://`) |
| AppImage / deb / rpm / snap | ✅ Build targets |

Run `./install-linux.sh` to install system-wide, or `./start.sh` to launch directly.

## 💿 Bootable Gaming ISO (SteamOS-like)

Build a live ISO that boots directly into GameVault fullscreen kiosk mode — like SteamOS.

```bash
cd iso
sudo ./build-iso.sh             # Requires Arch Linux + archiso
sudo dd bs=4M if=out/gamevault-*.iso of=/dev/sdX status=progress  # Write to USB
```

The ISO includes:
- Xorg + Openbox + Chromium kiosk mode → GameVault launcher
- Steam, Lutris, Wine pre-installed
- Vulkan/Mesa for AMD/Intel/NVIDIA
- Gamepad controller support
- PipeWire audio, NetworkManager, dark GRUB theme

See `iso/README.md` for full details.

## 🛠️ Build for Distribution

```bash
cd work/gaming-launcher
npm run build                    # Build web assets
npm run electron:build           # Build platform installers
```

Outputs go to `work/gaming-launcher/release/`.

## 📜 License

MIT
