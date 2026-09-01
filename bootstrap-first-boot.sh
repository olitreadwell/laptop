#!/usr/bin/env bash
# First-boot bootstrap: install Xcode CLT, clone this repo, run bootstrap
# hands-off. Idempotent. Installs a LaunchAgent so a reboot mid-setup
# resumes automatically at next login; disables itself when done.
#
# Kick off on a fresh Mac with one command (after Wi-Fi + account setup):
#   curl -fsSL https://raw.githubusercontent.com/olitreadwell/laptop/main/bootstrap-first-boot.sh | bash
set -euo pipefail

LOG="$HOME/laptop-first-boot.log"
exec >>"$LOG" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] first-boot bootstrap start"

PLIST="$HOME/Library/LaunchAgents/com.olitreadwell.laptop-bootstrap.plist"

install_launch_agent() {
  mkdir -p "$(dirname "$PLIST")"
  cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.olitreadwell.laptop-bootstrap</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$HOME/laptop/bootstrap-first-boot.sh</string></array>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
EOF
  launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null \
    || launchctl load "$PLIST" 2>/dev/null || true
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] launch agent installed — resumes after reboot"
}

disable_launch_agent() {
  launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
  mv "$PLIST" "$PLIST.done" 2>/dev/null || true
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] launch agent disabled — bootstrap done"
}

# 1. Xcode CLT — needed for git. Dialog may appear; poll up to 5 min.
if ! xcode-select -p >/dev/null 2>&1; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] installing Xcode CLT (dialog may appear)"
  xcode-select --install 2>/dev/null || true
  for _ in $(seq 1 60); do
    xcode-select -p >/dev/null 2>&1 && break
    sleep 5
  done
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CLT not finished — will retry at next login"
    install_launch_agent
    exit 0
  fi
fi

# 2. Clone (or refresh) this repo.
if [[ ! -d "$HOME/laptop/.git" ]]; then
  git clone https://github.com/olitreadwell/laptop.git "$HOME/laptop"
else
  git -C "$HOME/laptop" pull --ff-only origin main 2>/dev/null || true
fi

# 3. Hands-off bootstrap. Hard failure keeps the launch agent → retry at
#    next login; steps are idempotent so re-runs converge.
install_launch_agent
if bash "$HOME/laptop/bootstrap.sh" --yes; then
  disable_launch_agent
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] first-boot bootstrap complete"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] bootstrap failed — will retry at next login"
  exit 1
fi
