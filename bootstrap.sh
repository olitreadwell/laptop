#!/usr/bin/env bash
# Laptop bootstrap: detect → plan → run steps in order → verify → report.
# Idempotent and safe: logs to ~/laptop.log, resumes with --from <step>.
#
# Usage:
#   bootstrap.sh                 full run (interactive steps may prompt)
#   bootstrap.sh --dry-run       preview the plan without running anything
#   bootstrap.sh --from <step>   resume from a step (e.g. 30-homebrew)
#   bootstrap.sh --only <step>   run a single step
#   bootstrap.sh --yes           non-interactive: skip prompts, warn instead
#   bootstrap.sh --no-sudo       skip steps that need sudo
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LAPTOP_REPO_DIR="$REPO_DIR"
export LAPTOP_LOG_FILE="${LAPTOP_LOG_FILE:-$HOME/laptop.log}"
export LAPTOP_STATE_DIR="${LAPTOP_STATE_DIR:-$HOME/.laptop/state}"

source "$REPO_DIR/core/lib.sh"

DRY_RUN=false
FROM_STEP=""
ONLY_STEP=""
ASSUME_YES=false
NO_SUDO=false

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --from)    FROM_STEP="${2:-}"; shift 2 ;;
    --only)    ONLY_STEP="${2:-}"; shift 2 ;;
    --yes)     ASSUME_YES=true; shift ;;
    --no-sudo) NO_SUDO=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1 (see --help)" ;;
  esac
done

export ASSUME_YES NO_SUDO

main() {
  mkdir -p "$LAPTOP_STATE_DIR"
  log "laptop bootstrap start (dry_run=$DRY_RUN yes=$ASSUME_YES no_sudo=$NO_SUDO)"

  eval "$(bash "$REPO_DIR/core/detect.sh")"
  log "detected: os=$os arch=$arch chip=$chip model=$model macos_version=$macos_version"

  STEPS=()
  while IFS= read -r step; do
    STEPS+=("$step")
  done < <(bash "$REPO_DIR/core/plan.sh")
  log "plan: ${STEPS[*]:-<empty>}"
  [[ ${#STEPS[@]} -gt 0 ]] || fail "empty plan — no steps match this machine"

  local step started=false
  for step in "${STEPS[@]}"; do
    if [[ -n "$FROM_STEP" && "$started" == false && "$step" != "$FROM_STEP" ]]; then
      continue
    fi
    started=true
    if [[ -n "$ONLY_STEP" && "$step" != "$ONLY_STEP" ]]; then
      continue
    fi
    log "running step: $step"
    if [[ "$DRY_RUN" == true ]]; then
      log "dry-run: would run $step"
      continue
    fi
    if ! STEP_NAME="$step" bash "$REPO_DIR/core/steps/$step.sh"; then
      fail "step $step failed — fix and re-run: bash $REPO_DIR/bootstrap.sh --from $step"
    fi
  done

  log "laptop bootstrap complete"
}

main "$@"
