#!/usr/bin/env bash
# GameVault ISO Builder — Bootable Gaming OS (SteamOS-like)
#
# Builds a live Arch Linux ISO that boots directly into GameVault
# fullscreen mode. Uses archiso under the hood.
#
# Requirements: Arch Linux (or archiso installed), root privileges
#
# Usage:
#   sudo ./build-iso.sh              # Build the ISO
#   sudo ./build-iso.sh --clean      # Clean build artifacts
#   sudo ./build-iso.sh --output     # Print ISO path
#
# Output: iso/out/gamevault-*.iso

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DIR="$SCRIPT_DIR/archiso"
OUT_DIR="$SCRIPT_DIR/out"
ISO_LABEL="GAMEVAULT"
ISO_PUBLISHER="GameVault"
ISO_APP_ID="com.gamevault.launcher"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BLUE}::${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }

cleanup() {
  info "Cleaning build artifacts..."
  rm -rf "$OUT_DIR" "$PROFILE_DIR/work"
  ok "Done"
}

check_deps() {
  local missing=0
  for cmd in mkarchiso pacman; do
    if ! command -v "$cmd" &>/dev/null; then
      err "$cmd not found. Install archiso: pacman -S archiso"
      missing=1
    fi
  done
  if [ "$EUID" -ne 0 ]; then
    err "This script must be run as root (sudo)."
    missing=1
  fi
  return $missing
}

copy_gamevault() {
  local dest="$PROFILE_DIR/airootfs/usr/share/gamevault"
  mkdir -p "$dest"

  info "Copying GameVault web app into ISO rootfs..."

  local root_dir
  root_dir="$(cd "$SCRIPT_DIR/.." && pwd)"

  if [ -f "$root_dir/index.html" ]; then
    cp "$root_dir/index.html" "$dest/"
    ok "Copied index.html"
  else
    warn "index.html not found at $root_dir"
  fi

  # Copy Electron project if available
  if [ -d "$root_dir/work/gaming-launcher" ]; then
    cp -r "$root_dir/work/gaming-launcher" "$dest/electron-app"
    ok "Copied Electron project"
  fi

  # Ensure index.html exists at root of web bundle
  if [ ! -f "$dest/index.html" ]; then
    warn "No index.html found — creating placeholder"
    cat > "$dest/index.html" << 'HTML'
<!DOCTYPE html><html><body style="background:#0a0a0a;color:#4a9eff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;font-size:24px">GameVault — Loading...</body></html>
HTML
  fi

  mkdir -p "$dest/web"
  cp "$dest/index.html" "$dest/web/"
}

write_profile() {
  info "Writing archiso profile configuration..."

  # --- profile.conf ---
  cat > "$PROFILE_DIR/profile.conf" << 'EOF'
# GameVault archiso profile
iso_label="GAMEVAULT_$(date +%Y%m)"
iso_publisher="GameVault <https://github.com/A5tar0th1969/gamevault>"
iso_application="GameVault Gaming Launcher Live ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="gamevault"
buildmodes=('iso')
bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-x64.systemd-boot.esp'
  'uefi-x64.systemd-boot.eltorito'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/gamevault-kiosk"]="0:0:755"
  ["/usr/local/bin/gamevault-web-server"]="0:0:755"
)
EOF
  ok "profile.conf"

  # --- packages.x86_64 ---
  cat > "$PROFILE_DIR/packages.x86_64" << 'EOF'
# === Base System ===
base
base-devel
linux
linux-firmware
amd-ucode
intel-ucode
mkinitcpio
mkinitcpio-firmware

# === Display & Graphics ===
xorg-server
xorg-xinit
xorg-xrandr
xorg-xdpyinfo
mesa
mesa-utils
vulkan-intel
vulkan-radeon
vulkan-mesa-layers
libva-intel-driver
libva-mesa-driver
xf86-video-amdgpu
xf86-video-intel
xf86-video-nouveau

# === Window Manager ===
openbox
obconf
tint2
xcompmgr
feh
xdotool
wmctrl
lxterminal

# === Audio ===
pipewire
pipewire-pulse
pipewire-alsa
pipewire-jack
wireplumber

# === Web Browser (kiosk for GameVault) ===
chromium
# Firefox alternative: firefox

# === Input & Controllers ===
libinput
xf86-input-libinput
evtest
gamepad-daemon

# === Network ===
networkmanager
network-manager-applet
iwd
dhcpcd

# === Fonts & Display ===
ttf-dejavu
ttf-liberation
noto-fonts
noto-fonts-cjk

# === Utilities ===
sudo
which
git
curl
wget
vim
htop
unzip
zip
dosfstools
mtools
ntfs-3g
exfatprogs
btrfs-progs

# === Game Support ===
steam      # Native Steam runtime
wine
winetricks

# === Optional Gaming ===
lutris
gamemode
mangohud
EOF
  ok "packages.x86_64 ($(wc -l < "$PROFILE_DIR/packages.x86_64") packages)"

  # --- pacman.conf ---
  cat > "$PROFILE_DIR/pacman.conf" << 'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
ParallelDownloads = 5

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
  ok "pacman.conf"

  # --- systemd-boot entry ---
  cat > "$PROFILE_DIR/efiboot/loader/entries/01-gamevault.conf" << 'EOF'
title   GameVault Gaming OS
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options quiet loglevel=3 systemd.show_status=1 splash rd.udev.log_level=3 vt.global_cursor_default=0
EOF
  ok "systemd-boot entry"

  cat > "$PROFILE_DIR/efiboot/loader/loader.conf" << 'EOF'
default 01-gamevault
timeout 4
console-mode max
editor  no
EOF
  ok "loader.conf"

  # --- syslinux config ---
  cat > "$PROFILE_DIR/syslinux/syslinux.cfg" << 'EOF'
DEFAULT gamevault
PROMPT 0
TIMEOUT 50

UI menu.c32

MENU TITLE GameVault Gaming OS
MENU COLOR border       30;44  #40ffffff #10ffffff std
MENU COLOR title        1;36;44 #ff4a9eff #10ffffff std
MENU COLOR sel          7;37;40 #ff4a9eff #20ffffff std
MENU COLOR unsel        37;44  #ffcccccc #10ffffff std
MENU COLOR help         37;40  #ff888888 #10ffffff std
MENU COLOR timeout_msg  37;40  #ff888888 #10ffffff std
MENU COLOR timeout      1;37;40 #ffcccccc #10ffffff std
MENU COLOR msg07        37;40  #ffcccccc #10ffffff std
MENU TABMSG

LABEL gamevault
  MENU LABEL ^GameVault Gaming OS
  LINUX ../vmlinuz-linux
  INITRD ../intel-ucode.img,../amd-ucode.img,../initramfs-linux.img
  APPEND quiet loglevel=3 systemd.show_status=1 splash rd.udev.log_level=3 vt.global_cursor_default=0

LABEL safe
  MENU LABEL GameVault (Safe Mode)
  LINUX ../vmlinuz-linux
  INITRD ../intel-ucode.img,../amd-ucode.img,../initramfs-linux.img
  APPEND nomodeset xf86-video-intel.nohwcvt=1 loglevel=5

LABEL memtest
  MENU LABEL Memtest86+
  LINUX ../memtest86+/memtest.bin

LABEL hdt
  MENU LABEL Hardware Detection Tool
  COM32 hdt.c32

LABEL reboot
  MENU LABEL Reboot
  COM32 reboot.c32

LABEL poweroff
  MENU LABEL Power Off
  COM32 poweroff.c32
EOF
  ok "syslinux.cfg"

  # --- GRUB theme ---
  cat > "$PROFILE_DIR/grub/grub.cfg" << 'EOF'
set default="gamevault"
set timeout=5
set gfxmode=auto
set gfxpayload=keep

insmod all_video
insmod gfxterm
insmod png
insmod gfxmenu

loadfont /usr/share/grub/unicode.pf2

terminal_output gfxterm

set theme=($root)/grub/theme/theme.txt

menuentry "GameVault Gaming OS" --class gamevault --class os {
  set gfxpayload=keep
  linux /vmlinuz-linux quiet loglevel=3 systemd.show_status=0 splash rd.udev.log_level=3 vt.global_cursor_default=0
  initrd /intel-ucode.img /amd-ucode.img /initramfs-linux.img
}

menuentry "GameVault (Safe Mode)" --class gamevault --class os {
  linux /vmlinuz-linux nomodeset loglevel=5
  initrd /intel-ucode.img /amd-ucode.img /initramfs-linux.img
}

menuentry "Reboot" --class reboot {
  reboot
}

menuentry "Power Off" --class poweroff {
  halt
}
EOF
  ok "grub.cfg"

  # --- Custom GRUB theme ---
  mkdir -p "$PROFILE_DIR/grub/theme"
  cat > "$PROFILE_DIR/grub/theme/theme.txt" << 'EOF'
# GameVault GRUB Theme
title-text: ""
title-color: "#4a9eff"
title-font: "DejaVu Sans Bold 18"
desktop-image: "background.png"
desktop-color: "#0a0a0a"
terminal-font: "DejaVu Sans 12"

+ boot_menu {
    left = 30%
    top = 25%
    width = 40%
    height = 50%
    item_color = "#888888"
    selected_item_color = "#4a9eff"
    item_height = 36
    item_padding = 8
    item_spacing = 4
    icon_width = 32
    icon_height = 32
    item_icon_space = 12
    selected_item_pixmap_style = "select_*.png"
    scrollbar = true
    scrollbar_width = 8
}

+ label {
    text = "GameVault"
    font = "DejaVu Sans Bold 36"
    color = "#4a9eff"
    align = "center"
    left = 0
    top = 8%
    width = 100%
    height = 60
}

+ label {
    text = "Press Enter to launch"
    font = "DejaVu Sans 12"
    color = "#555555"
    align = "center"
    left = 0
    top = 18%
    width = 100%
    height = 30
}

+ label {
    text = "GAMEVAULT_" 
    font = "DejaVu Sans 10"
    color = "#333333"
    align = "right"
    left = 0
    top = 92%
    width = 98%
    height = 20
}
EOF
  ok "GRUB theme"

  # Generate a simple GRUB background image (SVG)
  cat > "$PROFILE_DIR/grub/theme/background.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a0a0a"/>
      <stop offset="50%" stop-color="#0d0d0d"/>
      <stop offset="100%" stop-color="#0a0a0a"/>
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="40%" r="50%">
      <stop offset="0%" stop-color="rgba(74,158,255,0.06)"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
  </defs>
  <rect width="1920" height="1080" fill="url(#bg)"/>
  <rect width="1920" height="1080" fill="url(#glow)"/>
  <circle cx="960" cy="540" r="200" fill="none" stroke="rgba(74,158,255,0.04)" stroke-width="1"/>
  <circle cx="960" cy="540" r="300" fill="none" stroke="rgba(74,158,255,0.02)" stroke-width="1"/>
</svg>
EOF
  ok "GRUB background.svg"

  # --- mkinitcpio.conf ---
  cat > "$PROFILE_DIR/airootfs/etc/mkinitcpio.conf" << 'EOF'
MODULES=(amdgpu i915 nouveau)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)
EOF
  ok "mkinitcpio.conf"
}

write_rootfs_overlay() {
  info "Writing root filesystem overlay..."

  # --- Auto-login on tty1 ---
  cat > "$PROFILE_DIR/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf" << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I 38400 linux
Type=simple
EOF
  ok "autologin.conf"

  # --- GameVault kiosk launcher script ---
  cat > "$PROFILE_DIR/airootfs/usr/local/bin/gamevault-kiosk" << 'SHELL'
#!/usr/bin/env bash
# GameVault Kiosk Mode — auto-launched at boot
# Launches Xorg + Openbox + Chromium in fullscreen pointing at GameVault

set -euo pipefail

LOG=/var/log/gamevault-kiosk.log
exec > "$LOG" 2>&1

echo "[gamevault-kiosk] Starting at $(date)"

# Set up display
export DISPLAY=:0
export XAUTHORITY=/root/.Xauthority

# Wait for Xorg to be ready
sleep 1

# Start Openbox window manager
openbox --config-file /etc/xdg/openbox/rc.xml --startup /etc/xdg/openbox/autostart &
sleep 1

# Hide cursor after inactivity
unclutter -idle 1 -root &

# Start the web server for GameVault
/usr/local/bin/gamevault-web-server &
sleep 1

# Wait for web server
for i in $(seq 1 10); do
  if curl -s http://localhost:8080 >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Launch Chromium in kiosk mode
echo "[gamevault-kiosk] Launching Chromium..."
chromium \
  --kiosk \
  --no-first-run \
  --disable-fre \
  --disable-features=TranslateUI \
  --disable-translate \
  --disable-sync \
  --no-default-browser-check \
  --disable-extensions \
  --disable-component-update \
  --disable-background-networking \
  --disable-session-crashed-bubble \
  --disable-infobars \
  --disable-notifications \
  --disable-prompt-on-repost \
  --disable-features=ChromeWhatsNewUI \
  --disable-features=ChromeMenuOpenNewTab \
  --noerrdialogs \
  --enable-features=OverlayScrollbar,OverlayScrollbarFlash \
  --fast \
  --fast-start \
  --user-data-dir=/tmp/chrome-gamevault \
  --app=http://localhost:8080 \
  http://localhost:8080 2>/dev/null &

CHROME_PID=$!

# Wait for chrome to exit (user quits = reboot)
wait $CHROME_PID || true

# If kiosk exits, offer options
echo "[gamevault-kiosk] Kiosk closed. Idling..."
while true; do
  sleep 30
done
SHELL
  chmod +x "$PROFILE_DIR/airootfs/usr/local/bin/gamevault-kiosk"
  ok "gamevault-kiosk"

  # --- Web server script (serves the bundled GameVault) ---
  cat > "$PROFILE_DIR/airootfs/usr/local/bin/gamevault-web-server" << 'SHELL'
#!/usr/bin/env bash
# GameVault local web server — serves the launcher on port 8080

WEB_ROOT="/usr/share/gamevault"
PORT=8080

exec python3 -m http.server "$PORT" --directory "$WEB_ROOT" 2>/dev/null || \
  busybox httpd -f -p "$PORT" -h "$WEB_ROOT" 2>/dev/null || \
  while true; do
    { echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"; cat "$WEB_ROOT/index.html"; } | nc -l -p "$PORT" -q 1 2>/dev/null || true
  done
SHELL
  chmod +x "$PROFILE_DIR/airootfs/usr/local/bin/gamevault-web-server"
  ok "gamevault-web-server"

  # --- Openbox autostart ---
  cat > "$PROFILE_DIR/airootfs/etc/xdg/openbox/autostart" << 'SHELL'
#!/usr/bin/env bash
# Openbox autostart — run when GameVault kiosk starts

# Set dark background
xsetroot -solid "#0a0a0a"

# Disable screen blanking/power saving
xset s off
xset s noblank
xset -dpms

# Set initial wallpaper (dark)
feh --bg-scale "#0a0a0a" 2>/dev/null || true

# Start compositor for smooth rendering
xcompmgr -c -C -t-5 -l-5 -r4.2 -o.55 &

# Enable tap-to-click on touchpads
xinput list | grep -i touchpad | while read -r line; do
  id=$(echo "$line" | sed 's/.*id=\([0-9]*\).*/\1/')
  [ -n "$id" ] && xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
done
SHELL
  ok "openbox autostart"

  # --- Openbox rc.xml for kiosk ---
  cat > "$PROFILE_DIR/airootfs/etc/xdg/openbox/rc.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>Clearlooks</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>no</keepBorder>
    <keepDecorations>no</keepDecorations>
  </theme>
  <desktops>
    <number>1</number>
    <names><name>GameVault</name></names>
  </desktops>
  <resistance>
    <strength>10</strength>
    <corner_strength>20</corner_strength>
  </resistance>
  <focus>
    <focusNew>yes</focusNew>
    <followMouse>no</followMouse>
    <focusLast>yes</focusLast>
    <underMouse>no</underMouse>
    <focusDelay>200</focusDelay>
    <raiseOnFocus>yes</raiseOnFocus>
  </focus>
  <placement>
    <policy>PIL</policy>
    <center>yes</center>
    <monitor>Primary</monitor>
  </placement>
  <mouse>
    <context name="Root">
      <mousebind button="A-Left" action="WorkspaceMenu"/>
      <mousebind button="A-Right" action="HideMenus"/>
    </context>
  </mouse>
  <keyboard>
    <keybind key="A-F4"><action name="Close"/></keybind>
    <keybind key="A-Tab"><action name="NextWindow"/></keybind>
    <keybind key="A-Escape"><action name="Lower"/></keybind>
    <keybind key="F11"><action name="ToggleFullscreen"/></keybind>
    <keybind key="C-A-Delete"><action name="Execute"><command>systemctl reboot</command></action></keybind>
    <keybind key="C-A-x"><action name="Execute"><command>systemctl poweroff</command></action></keybind>
  </keyboard>
  <applications>
    <application class="*">
      <decor>no</decor>
      <border>no</border>
      <maximized>yes</maximized>
      <focus>yes</focus>
      <desktop>1</desktop>
      <skipTaskbar>yes</skipTaskbar>
      <skipPager>yes</skipPager>
      <fullscreen>yes</fullscreen>
    </application>
    <application name="Firefox" class="Firefox">
      <decor>no</decor>
      <fullscreen>yes</fullscreen>
    </application>
    <application name="Chromium" class="Chromium">
      <decor>no</decor>
      <fullscreen>yes</fullscreen>
      <maximized>yes</maximized>
    </connection>
  </applications>
</openbox_config>
EOF
  ok "openbox rc.xml"

  # --- systemd service: gamevault-kiosk ---
  cat > "$PROFILE_DIR/airootfs/etc/systemd/system/gamevault-kiosk.service" << 'EOF'
[Unit]
Description=GameVault Kiosk Mode
After=display-manager.service network.target
Requires=display-manager.service

[Service]
Type=simple
ExecStart=/usr/local/bin/gamevault-kiosk
Restart=on-failure
RestartSec=5
User=root
Environment=DISPLAY=:0
Environment=XAUTHORITY=/root/.Xauthority

[Install]
WantedBy=multi-user.target
EOF
  ok "gamevault-kiosk.service"

  # --- Enable services in the live environment ---
  cat > "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/gamevault-kiosk.service" << 'EOF'
[Unit]
Description=GameVault Kiosk Mode (enabled symlink)
EOF

  mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/display-manager.service.wants"
  cat > "$PROFILE_DIR/airootfs/etc/systemd/system/display-manager.service.wants/gamevault-kiosk.service" << 'EOF'
[Unit]
Description=GameVault Kiosk Mode (enabled symlink)
EOF
  ok "kiosk service enabled"

  # --- NetworkManager autostart ---
  cat > "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service" << 'EOF'
[Unit]
Description=Network Manager (enabled symlink)
EOF
  ok "NetworkManager enabled"

  # --- Custom bashrc for root ---
  cat > "$PROFILE_DIR/airootfs/root/.bashrc" << 'BASHRC'
#!/usr/bin/env bash
export DISPLAY=:0
export EDITOR=vim
alias ll='ls -la'
alias la='ls -A'
alias gamevault='chromium --kiosk http://localhost:8080'
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
echo -e "\e[1;34mGameVault Gaming OS\e[0m — Type \e[1mgamevault\e[0m to launch, \e[1mreboot\e[0m to restart"
BASHRC
  ok "root .bashrc"

  # --- /etc/issue (login prompt) ---
  cat > "$PROFILE_DIR/airootfs/etc/issue" << 'EOF'
[1;34m
   ______                      __      __
  / ____/___ _____ ___  ____ _/ /___ _/ /____  _____
 / / __/ __ `/ __ `__ \/ __ `/ / __ `/ __/ _ \/ ___/
/ /_/ / /_/ / / / / / / /_/ / / /_/ / /_/  __/ /
\____/\__, /_/ /_/ /_/\__,_/_/\__,_/\__/\___/_/
     /____/

[0;37m  GameVault Gaming OS — Press Enter to auto-launch
EOF
  ok "/etc/issue"

  # --- udev rule for gamepad controller support ---
  cat > "$PROFILE_DIR/airootfs/etc/udev/rules.d/71-gamevault-controllers.rules" << 'EOF'
# Game Controller permissions for kiosk mode
KERNEL=="event*", SUBSYSTEM=="input", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", TAG+="uaccess"
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess"
EOF
  ok "controller udev rules"

  # --- Optimize for performance ---
  mkdir -p "$PROFILE_DIR/airootfs/etc/sysctl.d"
  cat > "$PROFILE_DIR/airootfs/etc/sysctl.d/99-gamevault.conf" << 'EOF'
# GameVault performance tuning
vm.swappiness = 10
vm.vfs_cache_pressure = 50
kernel.nmi_watchdog = 0
kernel.sched_autogroup_enabled = 1
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
EOF
  ok "sysctl tuning"

  ok "Rootfs overlay complete"
}

# --- Main ---
main() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}  GameVault ISO Builder${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""

  case "${1:-}" in
    --clean|-c)
      cleanup
      exit 0
      ;;
    --output|-o)
      ls -1 "$OUT_DIR"/*.iso 2>/dev/null || echo "No ISO built yet"
      exit 0
      ;;
    --help|-h)
      echo "Usage: sudo $0 [--clean|--output]"
      exit 0
      ;;
  esac

  check_deps || exit 1

  # Clean previous build
  cleanup

  # Generate all config files
  write_profile
  write_rootfs_overlay
  copy_gamevault

  # Generate GRUB background PNG from SVG (if rsvg-convert available)
  if command -v rsvg-convert &>/dev/null; then
    rsvg-convert "$PROFILE_DIR/grub/theme/background.svg" -o "$PROFILE_DIR/grub/theme/background.png" 2>/dev/null && \
      ok "GRUB background generated" || \
      warn "GRUB background not generated"
  fi

  # Build the ISO
  info "Building ISO (this may take a while)..."
  mkdir -p "$OUT_DIR"

  mkarchiso -v -w "$PROFILE_DIR/work" -o "$OUT_DIR" "$PROFILE_DIR"

  # Clean working directory
  rm -rf "$PROFILE_DIR/work"

  # Show result
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════${NC}"
  echo -e "${GREEN}  ISO Build Complete!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════${NC}"
  echo ""

  local iso
  iso=$(ls -1 "$OUT_DIR"/*.iso 2>/dev/null | head -1)
  if [ -n "$iso" ]; then
    local size
    size=$(du -h "$iso" | cut -f1)
    echo -e "  ${BLUE}ISO:${NC}    $iso"
    echo -e "  ${BLUE}Size:${NC}   $size"
    echo ""
    echo "  Write to USB: sudo dd bs=4M if=$iso of=/dev/sdX status=progress"
    echo "  Or boot in VM: qemu-system-x86_64 -cdrom $iso -m 4G"
  else
    warn "ISO not found in $OUT_DIR"
  fi
  echo ""
}

main "$@"
