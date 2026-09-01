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
  log "opening 1Password — sign in once with your master password, then"
  log "enable Touch ID (Settings → Security → Touch ID) so the CLI unlocks"
  log "with your fingerprint from here on"
  open -a 1Password 2>/dev/null || true
  local waited=0
  while ! op account list >/dev/null 2>&1; do
    # Establish the CLI session via the app (works once the GUI is
    # unlocked; stdin from /dev/null so it never blocks on a prompt).
    ( op signin --account my.1password.com </dev/null >/dev/null 2>&1 & )
    if [[ "$waited" -ge 180 ]]; then
      warn "1Password CLI not ready after 3 min — sign in, then re-run:"
      warn "bash $LAPTOP_REPO_DIR/bootstrap.sh --from 30-1password"
      break
    fi
    sleep 5
    waited=$((waited + 5))
  done
  if op account list >/dev/null 2>&1; then
    ok "1Password signed in — Touch ID unlock ready"
  fi
fi
