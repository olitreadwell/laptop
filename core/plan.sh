#!/usr/bin/env bash
# Build the ordered step list for this machine. Prints one step name per line.
# Platform-specific steps are filtered by filename suffix:
#   *macos* / *linux*  — OS match
#   *arm64* / *intel*  — arch match
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STEPS_DIR="$REPO_DIR/core/steps"

main() {
  local os arch name
  os="$(uname -s)"
  arch="$(uname -m)"
  for step in "$STEPS_DIR"/*.sh; do
    [[ -f "$step" ]] || continue
    name="$(basename "$step" .sh)"
    case "$name" in
      *macos*) [[ "$os" == "Darwin" ]] || continue ;;
      *linux*) [[ "$os" == "Linux" ]] || continue ;;
      *arm64*) [[ "$arch" == "arm64" ]] || continue ;;
      *intel*) [[ "$arch" == "x86_64" ]] || continue ;;
    esac
    echo "$name"
  done
}

main "$@"
