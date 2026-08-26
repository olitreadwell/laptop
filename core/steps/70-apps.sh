#!/usr/bin/env bash
# App-level extras: App Store apps via mas. Casks come from brew bundle.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if is_installed mas; then
  if mas account >/dev/null 2>&1; then
    run_cmd "mas upgrade" mas upgrade || warn "mas upgrade had issues"
  else
    warn "mas not signed in — run: mas signin"
  fi
else
  log "mas not installed — skipping App Store apps"
fi
