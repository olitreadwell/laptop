#!/usr/bin/env bash
# Regenerate knowledge/current-machine.md and knowledge/tool-inventory.md
# from the live machine. Run: bash knowledge/snapshot.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO_DIR/knowledge"
TS="$(date '+%Y-%m-%d %H:%M:%S %Z')"

{
  echo "# Current Machine Snapshot"
  echo
  echo "Generated: $TS"
  echo
  echo "## Hardware"
  echo '```'
  system_profiler SPHardwareDataType 2>/dev/null | sed -n '1,20p'
  echo '```'
  echo
  echo "## Software"
  echo '```'
  sw_vers
  echo '```'
  echo
  echo "## Detection (core/detect.sh)"
  echo '```'
  bash "$REPO_DIR/core/detect.sh"
  echo '```'
} > "$OUT/current-machine.md"

{
  echo "# Tool Inventory"
  echo
  echo "Generated: $TS"
  echo
  echo "## Homebrew formulae ($(brew list --formula 2>/dev/null | wc -l | tr -d ' '))"
  echo '```'
  brew list --formula 2>/dev/null
  echo '```'
  echo
  echo "## Homebrew casks ($(brew list --cask 2>/dev/null | wc -l | tr -d ' '))"
  echo '```'
  brew list --cask 2>/dev/null
  echo '```'
  echo
  echo "## mise runtimes"
  echo '```'
  mise ls 2>/dev/null
  echo '```'
  echo
  echo "## npm global packages"
  echo '```'
  npm ls -g --depth=0 2>/dev/null || true
  echo '```'
  echo
  echo "## Custom scripts in ~/bin"
  echo '```'
  ls "$HOME/bin" 2>/dev/null || true
  echo '```'
} > "$OUT/tool-inventory.md"

echo "snapshot written to $OUT"
