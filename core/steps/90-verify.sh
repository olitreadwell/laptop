#!/usr/bin/env bash
# Final verification: key tools present, versions, camera/mic, git identity.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

log "verification:"
ok=0
missing=0
for t in brew git gh op mise zsh starship fzf zoxide; do
  if is_installed "$t"; then
    v="$("$t" --version 2>/dev/null | head -1 || true)"
    case "$v" in Usage:*|Error:*) v="(no --version)" ;; esac
    ok "  $t ($v)"
    ok=$((ok + 1))
  else
    warn "  missing: $t"
    missing=$((missing + 1))
  fi
done

if is_installed git; then
  if [[ -n "$(git config --global user.name 2>/dev/null)" && -n "$(git config --global user.email 2>/dev/null)" ]]; then
    ok "  git identity set ($(git config --global user.name))"
  else
    warn "  git identity missing — run: git config --global user.name/email"
  fi
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]]; then
    ok "  iCloud Drive present"
    if [[ -L "$HOME/Desktop" ]]; then
      ok "  Desktop & Documents sync on"
    else
      warn "  Desktop & Documents sync off — enable: System Settings → Apple Account → iCloud → iCloud Drive"
    fi
  else
    warn "  iCloud Drive not enabled — sign in: System Settings → Apple Account → iCloud"
  fi
  if system_profiler SPCameraDataType 2>/dev/null | grep -qi "camera"; then
    ok "  camera present"
  else
    warn "  missing: camera"
  fi
  if system_profiler SPAudioDataType 2>/dev/null | grep -qi "microphone"; then
    ok "  microphone present"
  else
    warn "  missing: microphone"
  fi
fi

# 1Password: signed in + can actually read secrets + SSH agent.
if op account list >/dev/null 2>&1; then
  ok "  1Password signed in"
  if value="$(op item get "Ollama Cloud Pro API Key" --fields credential --reveal 2>/dev/null)" && [[ -n "$value" ]]; then
    ok "  1Password secret read works"
  else
    warn "  1Password cannot read secrets — CLI session broken, run: op signin"
  fi
  if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
    ok "  1Password SSH agent socket present"
  else
    warn "  1Password SSH agent socket missing — enable in 1Password → Settings → SSH Agent"
  fi
else
  warn "  1Password not signed in — open the app and sign in"
fi

# Codex: config, provider, keys, live smoke test.
if is_installed codex; then
  if [[ -f "$HOME/.codex/config.toml" ]]; then
    if grep -q 'model_provider = "ollama-cloud"' "$HOME/.codex/config.toml"; then
      ok "  codex provider: ollama-cloud"
    else
      warn "  codex provider not ollama-cloud — check ~/.codex/config.toml"
    fi
    model="$(grep -E '^model = ' "$HOME/.codex/config.toml" | head -1 | cut -d'"' -f2)"
    log "  codex model: ${model:-unknown}"
  else
    warn "  codex config missing — run dotfiles step (40)"
  fi
  if [[ -f "$HOME/.config/op/secrets.env" ]] && grep -q "OLLAMA_CLOUD_API_KEY=" "$HOME/.config/op/secrets.env"; then
    ok "  OLLAMA_CLOUD_API_KEY present"
  else
    warn "  OLLAMA_CLOUD_API_KEY missing — run 80-auth.sh"
  fi
  if [[ -f "$HOME/.config/op/secrets.env" ]] && grep -q "OLLAMA_CLOUD_API_KEY_2=" "$HOME/.config/op/secrets.env"; then
    ok "  OLLAMA_CLOUD_API_KEY_2 present"
  else
    warn "  OLLAMA_CLOUD_API_KEY_2 missing — run 80-auth.sh"
  fi
  if [[ -f "$HOME/.config/op/secrets.env" ]]; then
    source "$HOME/.config/op/secrets.env"
  fi
  if [[ -n "${OLLAMA_CLOUD_API_KEY:-}" ]]; then
    if out="$(codex exec --skip-git-repo-check "reply with exactly: codex-ok" 2>&1)"; then
      if grep -q "codex-ok" <<<"$out"; then
        ok "  codex live test passed"
      else
        warn "  codex live test returned unexpected output"
      fi
    else
      warn "  codex live test failed: $(echo "$out" | tail -1)"
    fi
  else
    warn "  OLLAMA_CLOUD_API_KEY not in env — source secrets.env first"
  fi
else
  warn "  codex not installed"
fi

if [[ "$missing" -eq 0 ]]; then
  ok "verification done: $ok present, $missing missing"
else
  warn "verification done: $ok present, $missing missing"
fi
