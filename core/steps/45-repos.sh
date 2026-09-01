#!/usr/bin/env bash
# Personal repos: clone into ~/code from GitHub, pull if present.
# Manifest: $LAPTOP_REPO_DIR/repos.txt (one repo name per line, # comments).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

MANIFEST="$LAPTOP_REPO_DIR/repos.txt"
if [[ ! -f "$MANIFEST" ]]; then
  log "no repos.txt manifest — skipping repo clone"
  exit 0
fi

mkdir -p "$HOME/code"

cloned=0
while IFS= read -r repo; do
  [[ -n "$repo" && "$repo" != \#* ]] || continue
  dest="$HOME/code/$repo"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only origin main 2>/dev/null \
      && log "repo up to date: $repo" \
      || warn "repo pull failed (offline or conflicts): $repo"
  elif [[ -d "$dest" ]]; then
    warn "repo dir exists but not a git repo — skipping: $repo"
  else
    if git clone "https://github.com/olitreadwell/$repo.git" "$dest" 2>/dev/null; then
      log "cloned: $repo"
      cloned=$((cloned + 1))
    else
      warn "clone failed (offline or missing): $repo"
    fi
  fi
done < "$MANIFEST"
log "repos done: $cloned cloned, rest present or warned"
