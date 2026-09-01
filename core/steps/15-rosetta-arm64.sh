#!/usr/bin/env bash
# Rosetta 2 on Apple Silicon: needed before x86-only tools in brew bundle.
# arm64-only filename suffix; skipped on Intel/Linux by plan.sh.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if [[ "$(uname -m)" != "arm64" ]]; then
  log "not Apple Silicon — skipping Rosetta"
  exit 0
fi

if arch -x86_64 /usr/bin/true 2>/dev/null; then
  log "Rosetta already installed"
  exit 0
fi

log "Installing Rosetta 2..."
if softwareupdate --install-rosetta --agree-to-license; then
  log "Rosetta installed"
else
  warn "run manually: softwareupdate --install-rosetta --agree-to-license"
  exit 1
fi
