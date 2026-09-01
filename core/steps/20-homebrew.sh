#!/usr/bin/env bash
# Homebrew: install if missing (correct prefix per chip), then brew bundle.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if is_installed brew; then
  log "Homebrew present: $(brew --prefix)"
else
  log "Installing Homebrew (non-interactive)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
  is_installed brew || fail "Homebrew install failed"
fi

# gum powers the bootstrap TUI — install early so later steps can use it.
if ! is_installed gum; then
  run_cmd_soft "install gum" brew install gum
fi

# mise is needed by brew bundle's npm section (reshim) — install first.
if ! is_installed mise; then
  run_cmd_soft "install mise" brew install mise
fi

if [[ -f "$LAPTOP_REPO_DIR/Brewfile" ]]; then
  run_cmd_soft "brew bundle" brew bundle --verbose --file="$LAPTOP_REPO_DIR/Brewfile"
else
  log "no Brewfile — skipping brew bundle"
fi
