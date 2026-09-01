#!/usr/bin/env bash
# Codex model catalog: copy from repo if ~/.codex/model-catalog.json missing.
# The dotfiles config.toml references this file; without it codex errors.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

mkdir -p "$HOME/.codex"
if [[ -f "$HOME/.codex/model-catalog.json" ]]; then
  log "codex model catalog present"
else
  if [[ -f "$LAPTOP_REPO_DIR/config/codex-model-catalog.json" ]]; then
    cp "$LAPTOP_REPO_DIR/config/codex-model-catalog.json" "$HOME/.codex/model-catalog.json"
    ok "codex model catalog installed"
  else
    warn "codex model catalog missing from repo — codex may need it"
  fi
fi
