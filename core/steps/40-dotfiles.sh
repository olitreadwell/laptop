#!/usr/bin/env bash
# Dotfiles + ai-harness: clone if missing, pull if present, install symlinks.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

# clone_private <owner/repo> <dest> — use gh's own auth when available so
# private clones never prompt for a password; fall back to plain git.
clone_private() {
  local repo="$1" dest="$2"
  if is_installed gh && gh auth status >/dev/null 2>&1; then
    gh repo clone "$repo" "$dest" 2>/dev/null \
      || git clone --progress "https://github.com/$repo.git" "$dest"
  else
    git clone --progress "https://github.com/$repo.git" "$dest"
  fi
}

if [[ -d "$HOME/dotfiles/.git" ]]; then
  log "dotfiles repo present"
  git -C "$HOME/dotfiles" pull --ff-only origin main 2>/dev/null \
    || warn "dotfiles pull failed (offline or conflicts)"
else
  run_cmd "clone dotfiles" clone_private olitreadwell/dotfiles "$HOME/dotfiles"
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
  run_cmd "clone ai-harness" clone_private olitreadwell/ai-harness "$HOME/.agents"
fi

if [[ -x "$HOME/.agents/install.sh" ]]; then
  run_cmd "wire agent skills" bash "$HOME/.agents/install.sh"
fi

# New machine may have a different username or arch — fix the dotfiles'
# hardcoded /Users/olitreadwell paths and the Intel brew path in .zprofile.
for f in "$HOME/.zprofile" "$HOME/.zshrc"; do
  fix_home_paths "$f"
done
if [[ "$(uname -m)" == "arm64" ]] && [[ -f "$HOME/.zprofile" ]]; then
  sed -i '' 's|/usr/local/bin/brew|/opt/homebrew/bin/brew|g' "$HOME/.zprofile" 2>/dev/null \
    || sed -i 's|/usr/local/bin/brew|/opt/homebrew/bin/brew|g' "$HOME/.zprofile"
  log "zprofile brew path fixed for Apple Silicon"
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
