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

# Ollama Cloud Pro keys (codex provider) from 1Password -> ~/.config/op/secrets.env.
# Sourced by dotfiles zshrc; codex reads OLLAMA_CLOUD_API_KEY(_2) at runtime.
if op account list >/dev/null 2>&1; then
  secrets_file="$HOME/.config/op/secrets.env"
  mkdir -p "$(dirname "$secrets_file")"
  backup_file "$secrets_file"
  for pair in "Ollama Cloud Pro API Key:OLLAMA_CLOUD_API_KEY" "Ollama Cloud Pro 2 API Key:OLLAMA_CLOUD_API_KEY_2"; do
    item="${pair%%:*}"; var="${pair##*:}"
    if value="$(op item get "$item" --fields credential --reveal 2>/dev/null)"; then
      if [[ -f "$secrets_file" ]]; then
        grep -v "^export $var=" "$secrets_file" > "$secrets_file.tmp" || true
        mv "$secrets_file.tmp" "$secrets_file"
      fi
      printf 'export %s=%s\n' "$var" "$value" >> "$secrets_file"
      log "wrote $var to $secrets_file"
    else
      warn "1Password item not found: $item"
    fi
  done
else
  warn "1Password not signed in — cannot provision codex API keys"
fi
