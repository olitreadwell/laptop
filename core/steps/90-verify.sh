#!/usr/bin/env bash
# Final verification: key tools present, versions, summary report.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

log "verification:"
ok=0
missing=0
for t in brew git gh op mise zsh starship fzf zoxide; do
  if is_installed "$t"; then
    log "  ok: $t ($("$t" --version 2>/dev/null | head -1))"
    ok=$((ok + 1))
  else
    warn "  missing: $t"
    missing=$((missing + 1))
  fi
done
if [[ "$(uname -s)" == "Darwin" ]]; then
  if system_profiler SPCameraDataType 2>/dev/null | grep -qi "camera"; then
    log "  ok: camera present"
  else
    warn "  missing: camera"
  fi
  if system_profiler SPAudioDataType 2>/dev/null | grep -qi "microphone"; then
    log "  ok: microphone present"
  else
    warn "  missing: microphone"
  fi
fi
log "verification done: $ok present, $missing missing"
