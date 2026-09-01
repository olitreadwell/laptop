#!/usr/bin/env bash
# macOS system settings via defaults. Values mirror the current machine;
# each write is idempotent (same value re-written = no-op).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

[[ "$(uname -s)" == "Darwin" ]] || { log "not macOS — skipping"; exit 0; }

# Dock: autohide, magnification, small tiles
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 16
defaults write com.apple.dock largesize -int 128

# Finder: path bar, list view, external drives on desktop
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Trackpad: tap-to-click off, three-finger drag off, smart zoom on,
# two-finger right-edge swipe (notification center) — current machine
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3

# Natural scrolling off (current machine)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Dock: bottom-right hot corner = Quick Note
defaults write com.apple.dock wvous-br-corner -int 14

# Control Center: hide Now Playing
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false

# Keyboard shortcuts: restore the full symbolichotkeys dict from the repo
if [[ -f "$LAPTOP_REPO_DIR/config/app-prefs/com.apple.symbolichotkeys.plist" ]]; then
  defaults import com.apple.symbolichotkeys "$LAPTOP_REPO_DIR/config/app-prefs/com.apple.symbolichotkeys.plist" 2>/dev/null \
    && log "keyboard shortcuts restored" \
    || warn "keyboard shortcuts restore failed"
fi

# Restart affected apps so settings take effect
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
log "macOS settings applied"
