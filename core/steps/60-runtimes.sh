#!/usr/bin/env bash
# Runtimes via mise, per ~/.config/mise/config.toml (installed by dotfiles).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if ! is_installed mise; then
  if is_installed brew; then
    run_cmd "install mise" brew install mise
  else
    warn "mise missing and Homebrew unavailable — install manually"
    exit 1
  fi
fi

if [[ -f "$HOME/.config/mise/config.toml" ]]; then
  run_cmd "mise install" mise install
else
  warn "no mise config yet (dotfiles step may not have run) — skipping mise install"
fi
