#!/usr/bin/env bash
# Prereqs: Xcode Command Line Tools + sudo availability.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if xcode-select -p >/dev/null 2>&1; then
  log "Xcode CLT already installed"
else
  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    warn "Xcode CLT missing and --yes mode cannot click the install dialog"
    warn "run manually: xcode-select --install, then re-run bootstrap"
    exit 1
  fi
  log "Installing Xcode Command Line Tools (dialog will appear)..."
  xcode-select --install
  warn "finish the CLT install dialog, then re-run:"
  warn "bash $LAPTOP_REPO_DIR/bootstrap.sh --from 10-prereqs"
  exit 1
fi

if [[ "${NO_SUDO:-false}" == "false" ]]; then
  if sudo -n true 2>/dev/null; then
    log "sudo available without prompt"
  else
    warn "sudo will prompt later — keep the password handy, or use --no-sudo"
  fi
fi
