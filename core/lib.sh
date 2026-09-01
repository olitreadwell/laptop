#!/usr/bin/env bash
# Shared helpers: logging, error handling, idempotent command runner.
# Source from steps: source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
set -euo pipefail

export LAPTOP_REPO_DIR="${LAPTOP_REPO_DIR:-$HOME/laptop}"
export LAPTOP_LOG_FILE="${LAPTOP_LOG_FILE:-$HOME/laptop.log}"
export LAPTOP_STATE_DIR="${LAPTOP_STATE_DIR:-$HOME/.laptop/state}"
export STEP_NAME="${STEP_NAME:-unknown}"

mkdir -p "$LAPTOP_STATE_DIR"

# ANSI colors — only when stdout is a TTY; log file stays plain.
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_MAGENTA=$'\033[35m'; C_CYAN=$'\033[36m'
else
  C_RESET=; C_BOLD=; C_DIM=; C_RED=; C_GREEN=; C_YELLOW=; C_BLUE=; C_MAGENTA=; C_CYAN=
fi

# log <msg> — plain INFO line; colored on TTY, plain in log file.
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LAPTOP_LOG_FILE"
  echo "${C_DIM}[$(date '+%H:%M:%S')]${C_RESET} ${C_BLUE}INFO${C_RESET}  $*"
}

# ok <msg> — success line (green).
ok() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK: $*" >> "$LAPTOP_LOG_FILE"
  echo "${C_DIM}[$(date '+%H:%M:%S')]${C_RESET} ${C_GREEN}OK${C_RESET}     $*"
}

# warn <msg> — warning line (yellow), stderr.
warn() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*" >> "$LAPTOP_LOG_FILE"
  echo "${C_DIM}[$(date '+%H:%M:%S')]${C_RESET} ${C_YELLOW}WARN${C_RESET}   $*" >&2
}

# fail <msg> — error line (red), stderr, exit 1.
fail() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LAPTOP_LOG_FILE"
  echo "${C_DIM}[$(date '+%H:%M:%S')]${C_RESET} ${C_RED}ERROR${C_RESET}  $*" >&2
  exit 1
}

# step_header <name> — big banner before a step runs.
step_header() {
  local name="$1"
  echo
  echo "${C_BOLD}${C_CYAN}==> $name${C_RESET}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ==> step: $name" >> "$LAPTOP_LOG_FILE"
}

# run_cmd <label> <cmd...> — run, log, hard-fail on error
run_cmd() {
  local label="$1"; shift
  log "step $STEP_NAME: $label"
  if "$@"; then
    ok "step $STEP_NAME: $label"
  else
    fail "step $STEP_NAME: failed: $label"
  fi
}

# run_cmd_soft <label> <cmd...> — run, log, warn (not fail) on error.
# For steps where one bad item must not block the rest of the bootstrap.
run_cmd_soft() {
  local label="$1"; shift
  log "step $STEP_NAME: $label"
  if "$@"; then
    ok "step $STEP_NAME: $label"
  else
    warn "step $STEP_NAME: failed (continuing): $label — resume: $*"
  fi
}

# is_installed <cmd> — true if command exists on PATH
is_installed() { command -v "$1" >/dev/null 2>&1; }

# backup_file <path> — timestamped .bak copy before any overwrite
backup_file() {
  local f="$1"
  [[ -e "$f" && ! -L "$f" ]] && cp -p "$f" "$f.bak.$(date +%s)"
}

# mark_done / was_done <name> — optional idempotency markers for steps that
# cannot detect their own completion from system state
mark_done() { : > "$LAPTOP_STATE_DIR/$1"; }
was_done() { [[ -f "$LAPTOP_STATE_DIR/$1" ]]; }
