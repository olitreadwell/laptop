#!/usr/bin/env bash
# Dev tool auth: gh, claude, codex. Interactive — skipped with a warning in --yes mode.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if is_installed gh; then
  if gh auth status >/dev/null 2>&1; then
    log "gh authenticated"
  elif [[ "${ASSUME_YES:-false}" == "true" ]]; then
    warn "gh not authenticated — run manually: gh auth login"
  else
    run_cmd "gh auth login" gh auth login --web -h github.com || warn "gh auth failed"
  fi
fi

if is_installed claude; then
  if claude auth status >/dev/null 2>&1; then
    log "claude authenticated"
  elif [[ "${ASSUME_YES:-false}" == "true" ]]; then
    warn "claude auth skipped (--yes) — run manually: claude auth login"
  else
    run_cmd "claude auth login" claude auth login || warn "claude auth failed"
  fi
fi

if is_installed codex; then
  if codex login status >/dev/null 2>&1; then
    log "codex authenticated"
  elif [[ "${ASSUME_YES:-false}" == "true" ]]; then
    warn "codex auth skipped (--yes) — run manually: codex login"
  else
    run_cmd "codex login" codex login || warn "codex auth failed"
  fi
fi
