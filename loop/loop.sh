#!/usr/bin/env bash
# Self-improvement loop with exponential backoff: 15m → 30m → 60m (cap).
#
# Usage:
#   loop/loop.sh --once      run one iteration and exit
#   loop/loop.sh --daemon    run forever in the background (nohup)
#   loop/loop.sh --stop      stop a running daemon
#   loop/loop.sh --status    show backoff level and last run
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$REPO_DIR/loop/state"
PID_FILE="$STATE_DIR/loop.pid"
BACKOFFS=(900 1800 3600)   # seconds: 15m, 30m, 60m

mkdir -p "$STATE_DIR"

backoff_level() { cat "$STATE_DIR/backoff_level" 2>/dev/null || echo 0; }
set_backoff()   { echo "$1" > "$STATE_DIR/backoff_level"; }

next_delay() {
  local lvl
  lvl="$(backoff_level)"
  [[ "$lvl" -ge "${#BACKOFFS[@]}" ]] && lvl=$(( ${#BACKOFFS[@]} - 1 ))
  echo "${BACKOFFS[$lvl]}"
}

iterate() {
  local before after
  before="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo none)"
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
  if ! bash "$REPO_DIR/loop/iterate.sh"; then
    echo "[loop] iteration failed — resetting backoff"
    set_backoff 0
    return 1
  fi
  after="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo none)"
  if [[ "$before" != "$after" ]]; then
    echo "[loop] changes landed — resetting backoff to 15m"
    set_backoff 0
  else
    local lvl
    lvl="$(backoff_level)"
    set_backoff $(( lvl + 1 ))
    echo "[loop] no changes — next delay: $(( $(next_delay) / 60 ))m"
  fi
  date +%s > "$STATE_DIR/last_run"
}

daemon() {
  echo "$$" > "$PID_FILE"
  echo "[loop] daemon started pid $$"
  while true; do
    iterate || true
    sleep "$(next_delay)"
  done
}

stop_daemon() {
  if [[ -f "$PID_FILE" ]]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null && echo "[loop] stopped" || echo "[loop] no daemon running"
    rm -f "$PID_FILE"
  else
    echo "[loop] no daemon running"
  fi
}

status() {
  echo "backoff_level: $(backoff_level) (delay: $(( $(next_delay) / 60 ))m)"
  if [[ -f "$STATE_DIR/last_run" ]]; then
    echo "last_run: $(date -r "$(cat "$STATE_DIR/last_run")" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || cat "$STATE_DIR/last_run")"
  else
    echo "last_run: never"
  fi
  [[ -f "$PID_FILE" ]] && echo "daemon: running (pid $(cat "$PID_FILE"))" || echo "daemon: not running"
}

case "${1:-}" in
  --once)   iterate ;;
  --daemon) daemon ;;
  --stop)   stop_daemon ;;
  --status) status ;;
  *) echo "usage: loop/loop.sh --once|--daemon|--stop|--status"; exit 1 ;;
esac
