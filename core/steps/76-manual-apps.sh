#!/usr/bin/env bash
# Manual installs for Gatekeeper-disabled apps (qBittorrent, dupeGuru).
# Homebrew disabled their casks; install from official sources + clear the
# quarantine flag. Best effort — warns if a download fails.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

[[ "$(uname -s)" == "Darwin" ]] || { log "not macOS — skipping"; exit 0; }

install_dmg_app() {
  local name="$1" url="$2" dmg="/tmp/$name.dmg"
  if [[ -d "/Applications/$name.app" ]]; then
    log "$name already installed"
    return 0
  fi
  log "downloading $name..."
  if curl -fL --max-time 300 -o "$dmg" "$url" 2>/dev/null; then
    local vol
    vol="$(hdiutil attach "$dmg" -nobrowse 2>/dev/null | grep -o '/Volumes/.*' | head -1)"
    if [[ -n "$vol" ]]; then
      cp -R "$vol/$name.app" /Applications/ 2>/dev/null \
        && xattr -dr com.apple.quarantine "/Applications/$name.app" 2>/dev/null \
        && ok "$name installed" \
        || warn "$name install failed"
      hdiutil detach "$vol" >/dev/null 2>&1 || true
    else
      warn "$name dmg mount failed"
    fi
  else
    warn "$name download failed — install from the website manually"
  fi
}

install_zip_app() {
  local name="$1" url="$2" zip="/tmp/$name.zip"
  if [[ -d "/Applications/$name.app" ]]; then
    log "$name already installed"
    return 0
  fi
  log "downloading $name..."
  if curl -fL --max-time 300 -o "$zip" "$url" 2>/dev/null; then
    local tmp="/tmp/$name-unzip" app
    mkdir -p "$tmp"
    unzip -q -o "$zip" -d "$tmp" 2>/dev/null
    app="$(find "$tmp" -maxdepth 2 -name "*.app" | head -1)"
    if [[ -n "$app" ]]; then
      cp -R "$app" /Applications/ 2>/dev/null \
        && xattr -dr com.apple.quarantine "/Applications/$(basename "$app")" 2>/dev/null \
        && ok "$name installed" \
        || warn "$name install failed"
    else
      warn "$name app not found in archive"
    fi
  else
    warn "$name download failed — install from the website manually"
  fi
}

install_dmg_app "qBittorrent" "https://sourceforge.net/projects/qbittorrent/files/latest/download"
install_zip_app "dupeGuru" "https://github.com/arsenetar/dupeguru/releases/download/4.3.1/dupeguru_macOS_Qt_4.3.1.zip"
