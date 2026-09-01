#!/usr/bin/env bash
# Shared helpers: logging, error handling, idempotent command runner.
# Source from steps: source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
set -euo pipefail

export LAPTOP_REPO_DIR="${LAPTOP_REPO_DIR:-$HOME/laptop}"
export LAPTOP_LOG_FILE="${LAPTOP_LOG_FILE:-$HOME/laptop.log}"
export LAPTOP_STATE_DIR="${LAPTOP_STATE_DIR:-$HOME/.laptop/state}"
export STEP_NAME="${STEP_NAME:-unknown}"

mkdir -p "$LAPTOP_STATE_DIR"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LAPTOP_LOG_FILE"; }
warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*" | tee -a "$LAPTOP_LOG_FILE" >&2; }
fail() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LAPTOP_LOG_FILE" >&2; exit 1; }

# run_cmd <label> <cmd...> — run, log, hard-fail on error
run_cmd() {
  local label="$1"; shift
  log "step $STEP_NAME: $label"
  if "$@"; then
    log "step $STEP_NAME: ok: $label"
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
    log "step $STEP_NAME: ok: $label"
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
