#!/usr/bin/env bash
# Final verification: key tools present, versions, camera/mic, git identity.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

log "verification:"
ok=0
missing=0
for t in brew git gh op mise zsh starship fzf zoxide; do
  if is_installed "$t"; then
    ok "  $t ($("$t" --version 2>/dev/null | head -1))"
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

if [[ "$missing" -eq 0 ]]; then
  ok "verification done: $ok present, $missing missing"
else
  warn "verification done: $ok present, $missing missing"
fi
