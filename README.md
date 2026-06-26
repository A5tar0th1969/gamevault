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
├── manifest.json                 # PWA manifest (iOS/Android home screen)
├── service-worker.js             # PWA service worker (offline support)
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

## 🛠️ Build for Distribution

```bash
cd work/gaming-launcher
npm run build                    # Build web assets
npm run electron:build           # Build platform installers
```

Outputs go to `work/gaming-launcher/release/`.

## 📱 iOS (iPhone / iPad)

### Option A: PWA (no Xcode needed)

Open `index.html` in Safari, tap **Share → Add to Home Screen**. Works offline via service worker. Fullscreen mode hides Safari chrome.

### Option B: Native SwiftUI App (Xcode)

```bash
cd ios
chmod +x generate-icons.sh
./generate-icons.sh               # Auto-generate all icon sizes from SVG
open GameVault.xcodeproj          # Open in Xcode
```

Then **⌘R** to run on simulator or device. The app bundles the full web launcher as a WKWebView with:

- Fullscreen edge-to-edge with notch/safe area support
- Landscape + portrait orientation support
- External links open in Safari
- Dark launch screen with GameVault branding
- No navigation bars — pure fullscreen gaming UI

| iOS File | Purpose |
|---|---|
| `ios/GameVault/GameVaultApp.swift` | SwiftUI app entry |
| `ios/GameVault/ContentView.swift` | WKWebView wrapper |
| `ios/GameVault/Info.plist` | App config, orientations, fullscreen |
| `ios/GameVault/LaunchScreen.storyboard` | Launch screen |
| `ios/icon.svg` | Master icon source |
| `ios/generate-icons.sh` | Icon generation script |

On first launch, the app copies the web bundle from the project root into the app bundle. Rebuild when `index.html` changes.

## 📜 License

MIT
