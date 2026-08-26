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
log "verification done: $ok present, $missing missing"
