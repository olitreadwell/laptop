#!/usr/bin/env bash
# 1Password app + CLI + SSH agent. First-run sign-in is manual.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -d "/Applications/1Password.app" ]]; then
    log "1Password app present"
  elif is_installed brew; then
    run_cmd "install 1password cask" brew install --cask 1password
  else
    warn "1Password app not installed and Homebrew missing — install manually"
  fi
fi

if is_installed op; then
  log "op CLI present"
else
  if is_installed brew; then
    run_cmd "install 1password-cli" brew install --cask 1password-cli
  else
    warn "op CLI missing — install manually"
  fi
fi

if op account list >/dev/null 2>&1; then
  log "1Password signed in"
else
  warn "1Password not signed in — open the app, sign in, then run: op signin"
fi
