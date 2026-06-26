# GameVault Bootable ISO

Build a bootable SteamOS-like gaming OS ISO that launches directly into GameVault fullscreen mode.

## Requirements

- **Arch Linux** (or any distro with `archiso` installed)
- Root privileges (`sudo`)
- ~4GB free disk space
- Internet connection for package downloads

## Quick Start

```bash
cd iso
sudo ./build-iso.sh
```

The ISO will be written to `iso/out/gamevault-*.iso`.

## Write to USB

```bash
sudo dd bs=4M if=iso/out/gamevault-*.iso of=/dev/sdX status=progress
```

Replace `/dev/sdX` with your USB device (e.g., `/dev/sdb` — **not** a partition like `/dev/sdb1`).

## Test in VM

```bash
qemu-system-x86_64 -cdrom iso/out/gamevault-*.iso -m 4G -enable-kvm
```

## What's Inside

The ISO is a custom Arch Linux live environment that:

- Boots directly into GameVault fullscreen kiosk mode (Chromium)
- Auto-starts Xorg → Openbox → Chromium → GameVault
- Includes Steam, Lutris, Wine for native game support
- Game controller support via udev rules
- Vulkan + Mesa for AMD/Intel/NVIDIA GPUs
- NetworkManager for WiFi/Ethernet
- PipeWire audio
- Custom dark GRUB boot menu with GameVault branding

## Keyboard Shortcuts

| Key | Action |
|---|---|
| `F11` | Toggle fullscreen |
| `Ctrl+Alt+Delete` | Reboot |
| `Ctrl+Alt+x` | Power off |
| `Alt+F2` | Terminal (if needed) |

## Build Options

```bash
sudo ./build-iso.sh          # Build ISO
sudo ./build-iso.sh --clean  # Remove build artifacts
sudo ./build-iso.sh --output # Show ISO path
```

## Customization

- Edit `iso/archiso/packages.x86_64` to add/remove packages
- Edit `iso/archiso/airootfs/` to modify the live filesystem
- Edit `iso/archiso/grub/` to change boot theme
- Rebuild with `sudo ./build-iso.sh`

## How It Works

1. `archiso` builds a squashfs image of the root filesystem
2. The rootfs includes GameVault's `index.html` at `/usr/share/gamevault/`
3. A Python HTTP server serves it on port 8080
4. The `gamevault-kiosk` systemd service starts Xorg → Openbox → Chromium in kiosk mode
5. Chromium loads `http://localhost:8080` — the full GameVault launcher
6. User gets a SteamOS-like console experience
