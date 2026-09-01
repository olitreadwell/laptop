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

# Finder: path bar, list view
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Trackpad: tap-to-click off, three-finger drag off (current machine)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

# Control Center: hide Now Playing
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false

# Restart affected apps so settings take effect
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
log "macOS settings applied"
