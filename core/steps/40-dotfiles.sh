#!/usr/bin/env bash
# Dotfiles + ai-harness: clone if missing, pull if present, install symlinks.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

# If gh is already authed, wire git to its credential helper so private
# clones (dotfiles, ai-harness) never prompt for a password.
if is_installed gh && gh auth status >/dev/null 2>&1; then
  gh auth setup-git 2>/dev/null || true
fi

if [[ -d "$HOME/dotfiles/.git" ]]; then
  log "dotfiles repo present"
  git -C "$HOME/dotfiles" pull --ff-only origin main 2>/dev/null \
    || warn "dotfiles pull failed (offline or conflicts)"
else
  run_cmd "clone dotfiles" git clone --progress git@github.com:olitreadwell/dotfiles.git "$HOME/dotfiles"
fi

if [[ -x "$HOME/dotfiles/executable_install.sh" ]]; then
  run_cmd "install dotfiles" bash "$HOME/dotfiles/executable_install.sh"
else
  warn "dotfiles install script missing — check the repo"
fi

if [[ -d "$HOME/.agents/.git" ]]; then
  log "ai-harness present"
  git -C "$HOME/.agents" pull --ff-only origin main 2>/dev/null \
    || warn "ai-harness pull failed (offline or conflicts)"
else
  run_cmd "clone ai-harness" git clone --progress git@github.com:olitreadwell/ai-harness.git "$HOME/.agents"
fi

if [[ -x "$HOME/.agents/install.sh" ]]; then
  run_cmd "wire agent skills" bash "$HOME/.agents/install.sh"
fi

# Global Claude rules + settings (from this repo) — copy if missing.
mkdir -p "$HOME/.claude"
for f in CLAUDE.md settings.json; do
  if [[ -f "$HOME/.claude/$f" ]]; then
    log "claude $f present"
  elif [[ -f "$LAPTOP_REPO_DIR/config/claude/$f" ]]; then
    cp "$LAPTOP_REPO_DIR/config/claude/$f" "$HOME/.claude/$f"
    ok "claude $f installed"
  else
    warn "claude $f missing from repo"
  fi
done
