#!/usr/bin/env bash
# Detect machine: OS, chip, model, macOS version, key tools.
# Prints KEY=VALUE lines; consume with: eval "$(bash core/detect.sh)"
set -euo pipefail

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "os=macos" ;;
    Linux)  echo "os=linux" ;;
    *)      echo "os=unknown" ;;
  esac
}

detect_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    arm64)  echo "arch=arm64" ;;
    x86_64) echo "arch=x86_64" ;;
    *)      echo "arch=$arch" ;;
  esac
}

detect_chip() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
      echo "chip=apple-silicon"
    else
      echo "chip=intel"
    fi
  else
    echo "chip=unknown"
  fi
}

detect_model() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "model=$(sysctl -n hw.model 2>/dev/null || echo unknown)"
  else
    echo "model=unknown"
  fi
}

detect_macos_version() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos_version=$(sw_vers -productVersion 2>/dev/null || echo unknown)"
  fi
}

detect_tools() {
  local t
  for t in brew git gh op mise zsh starship fzf zoxide codex claude opencode docker mas; do
    if is_installed "$t"; then
      echo "has_$t=yes"
    else
      echo "has_$t=no"
    fi
  done
}

is_installed() { command -v "$1" >/dev/null 2>&1; }

main() {
  detect_os
  detect_arch
  detect_chip
  detect_model
  detect_macos_version
  detect_tools
}

main "$@"
