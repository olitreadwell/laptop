#!/usr/bin/env bash
# Personal repos: clone into ~/code from GitHub, pull if present.
# Manifest: $LAPTOP_REPO_DIR/repos.txt (one repo name per line, # comments).
# Clones run in parallel (4 at a time) with partial clone for speed.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

MANIFEST="$LAPTOP_REPO_DIR/repos.txt"
if [[ ! -f "$MANIFEST" ]]; then
  log "no repos.txt manifest — skipping repo clone"
  exit 0
fi

mkdir -p "$HOME/code"

# clone_one uses gh's own auth when available so private clones never
# prompt for a password.

clone_one() {
  local repo="$1"
  local dest="$HOME/code/$repo"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only origin main 2>/dev/null \
      && log "repo up to date: $repo" \
      || warn "repo pull failed (offline or conflicts): $repo"
  elif [[ -d "$dest" ]]; then
    warn "repo dir exists but not a git repo — skipping: $repo"
  else
    if is_installed gh && gh auth status >/dev/null 2>&1; then
      gh repo clone "olitreadwell/$repo" "$dest" 2>/dev/null \
        || git clone --filter=blob:none --progress "https://github.com/olitreadwell/$repo.git" "$dest" 2>/dev/null \
        || true
    else
      git clone --filter=blob:none --progress "https://github.com/olitreadwell/$repo.git" "$dest" 2>/dev/null \
        || true
    fi
    if [[ -d "$dest/.git" ]]; then
      ok "cloned: $repo"
    else
      warn "clone failed (offline or missing): $repo"
    fi
  fi
}
export -f clone_one
export HOME

REPOS=()
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
  REPOS+=("$line")
done < "$MANIFEST"
if [[ ${#REPOS[@]} -eq 0 ]]; then
  log "repos.txt empty — nothing to clone"
  exit 0
fi

printf '%s\n' "${REPOS[@]}" | xargs -P 4 -I{} bash -c 'source "$LAPTOP_REPO_DIR/core/lib.sh"; clone_one "$@"' _ {}
log "repos done: ${#REPOS[@]} in manifest, cloned or already present"
