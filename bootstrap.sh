#!/usr/bin/env bash
# Laptop bootstrap: detect → plan → run steps in order → verify → report.
# Idempotent and safe: logs to ~/laptop.log, resumes with --from <step>.
#
# Usage:
#   bootstrap.sh                 full run (interactive steps may prompt)
#   bootstrap.sh --dry-run       preview the plan without running anything
#   bootstrap.sh --from <step>   resume from a step (e.g. 20-homebrew)
#   bootstrap.sh --only <step>   run a single step
#   bootstrap.sh --yes           non-interactive: skip prompts, warn instead
#   bootstrap.sh --no-sudo       skip steps that need sudo
#   bootstrap.sh --menu          force the interactive step-selection menu
#   bootstrap.sh --verbose       live progress bar + spinner while steps run
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LAPTOP_REPO_DIR="$REPO_DIR"
export LAPTOP_LOG_FILE="${LAPTOP_LOG_FILE:-$HOME/laptop.log}"
export LAPTOP_STATE_DIR="${LAPTOP_STATE_DIR:-$HOME/.laptop/state}"

source "$REPO_DIR/core/lib.sh"
source "$REPO_DIR/core/tui.sh"

# Apple Silicon: Homebrew lives in /opt/homebrew — make it visible to every step.
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

DRY_RUN=false
FROM_STEP=""
ONLY_STEP=""
ASSUME_YES=false
NO_SUDO=false
MENU=false
VERBOSE=false

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --from)    FROM_STEP="${2:-}"; shift 2 ;;
    --only)    ONLY_STEP="${2:-}"; shift 2 ;;
    --yes)     ASSUME_YES=true; shift ;;
    --menu)    MENU=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --no-sudo) NO_SUDO=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1 (see --help)" ;;
  esac
done

export ASSUME_YES NO_SUDO

preflight() {
  log "preflight: network, disk, power"
  if ! curl -fsS --max-time 10 https://github.com >/dev/null 2>&1; then
    fail "no network — connect to Wi-Fi first (see runbook step 1)"
  fi
  local free_gb
  free_gb="$(df -k "$HOME" | awk 'NR==2 {printf "%d", $4/1024/1024}')"
  if [[ "$free_gb" -lt 10 ]]; then
    fail "only ${free_gb}GB free on disk — need at least 10GB"
  fi
  log "preflight ok: network up, ${free_gb}GB free"
  if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(pmset -g batt 2>/dev/null)" != *"AC Power"* ]]; then
    warn "not on AC power — plug in before a long run"
  fi
}

print_plan() {
  echo
  if has_gum; then
    local body=""
    local i=1 step
    for step in "${STEPS[@]}"; do
      body+="  $i. $step\n"
      i=$((i + 1))
    done
    gum style --border double --padding "0 2" --foreground 212 \
      "Plan for this machine:" "$(printf '%b' "$body")"
  else
    echo "${C_BOLD}${C_MAGENTA}Plan for this machine:${C_RESET}"
    local i=1 step
    for step in "${STEPS[@]}"; do
      echo "  ${C_CYAN}$i.${C_RESET} $step"
      i=$((i + 1))
    done
  fi
  echo
}

select_steps() {
  if [[ "$DRY_RUN" == true || "$ASSUME_YES" == true ]]; then
    return 0
  fi
  if [[ "$MENU" == true || ( -t 0 && -t 1 ) ]]; then
    local -a chosen=()
    while IFS= read -r s; do chosen+=("$s"); done       < <(tui_select_steps "Select steps to run" "${STEPS[@]}")
    [[ ${#chosen[@]} -gt 0 ]] || fail "aborted — nothing selected"
    STEPS=("${chosen[@]}")
  else
    if has_gum; then
      gum confirm "Run these steps now?" || fail "aborted — nothing changed"
    else
      read -r -p "Run these steps now? [y/N] " answer
      [[ "$answer" == "y" || "$answer" == "Y" ]] || fail "aborted — nothing changed"
    fi
  fi
}

# has_gum — true when the gum TUI is installed (brew formula, step 20).
has_gum() { command -v gum >/dev/null 2>&1; }

# run_step_gum <step> <idx> <total> — gum spin spinner + title while the
# step runs; output captured, shown on failure.
run_step_gum() {
  local step="$1" idx="$2" total="$3"
  local step_start=$SECONDS
  if gum spin --show-output --spinner dot --title "$step ($((idx + 1))/$total)" \
      -- bash "$REPO_DIR/core/steps/$step.sh"; then
    ok "step $step done in $((SECONDS - step_start))s"
  else
    fail "step $step failed — fix and re-run: bash $LAPTOP_REPO_DIR/bootstrap.sh --from $step"
  fi
}

# progress_bar <done> <total> <label> — autosized bar, redraws in place.
progress_bar() {
  local done="$1" total="$2" label="$3"
  local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
  local pct=$((done * 100 / total))
  local bar_w=$((cols - 28))
  [[ "$bar_w" -lt 10 ]] && bar_w=10
  local filled=$((bar_w * done / total))
  local bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = filled; i < bar_w; i++)); do bar+="░"; done
  printf '\r\033[K%s %3d%% (%d/%d) %s' "$bar" "$pct" "$done" "$total" "$label"
}

# batch_of <step> — coarse group label for the plan.
batch_of() {
  case "$1" in
    1[0-9]-*|2[0-9]-*) echo "system" ;;
    3[0-9]-*) echo "secrets" ;;
    4[0-9]-*) echo "dotfiles+repos" ;;
    5[0-9]-*) echo "shell+settings" ;;
    6[0-9]-*) echo "runtimes" ;;
    7[0-9]-*) echo "apps" ;;
    8[0-9]-*) echo "auth" ;;
    9[0-9]-*) echo "verify" ;;
    *) echo "other" ;;
  esac
}

# parse_items <tmpfile> — emit ITEM:<name>:<pct> and PCT:<pct> lines from a
# step's captured output, so the panel can show per-item progress.
parse_items() {
  local tmp="$1" line item pct
  tr '\r' '\n' < "$tmp" | while IFS= read -r line; do
    case "$line" in
      *"==> Downloading "*)
        item="${line#*==> Downloading }"
        if [[ "$item" == *"/homebrew/core/"* ]]; then
          item="${item#*homebrew/core/}"; item="${item%%/*}"
        else
          item="$(basename "$item")"
        fi
        echo "ITEM:$item:0" ;;
      *"Cloning into '"*)
        item="${line#*Cloning into \'}"; item="${item%%\'*}"
        echo "ITEM:$item:0" ;;
      *"==> Installing "*)
        item="${line#*==> Installing }"
        echo "ITEM:$item:0" ;;
      *"==> Fetching "*)
        item="${line#*==> Fetching }"
        echo "ITEM:$item:0" ;;
      *"Receiving objects: "*)
        pct="${line#*Receiving objects: }"; pct="${pct%%%*}"
        echo "PCT:$pct" ;;
      *"downloading "*)
        item="${line% downloading*}"
        echo "ITEM:$item:0" ;;
      *" | "*[0-9]%*)
        pct="${line%% *}"; pct="${pct%\%}"; pct="${pct%%.*}"
        echo "PCT:$pct" ;;
    esac
  done
}

# render_panel <tmpfile> <idx> <total> <step> <spin> <batch> — full-screen
# panel: overall bar + one mini progress bar per item seen so far.
render_panel() {
  local tmp="$1" idx="$2" total="$3" step="$4" spin="$5" batch="$6"
  local -a names=() pcts=()
  local line item pct n j k
  while IFS= read -r line; do
    case "$line" in
      ITEM:*)
        item="${line#ITEM:}"; pct="${item##*:}"; item="${item%:*}"
        n=${#names[@]}
        for ((j = 0; j < n; j++)); do
          if [[ "${names[$j]}" == "$item" ]]; then
            pcts[$j]=$pct; item=""; break
          fi
        done
        if [[ -n "$item" ]]; then names+=("$item"); pcts+=("$pct"); fi
        ;;
      PCT:*)
        pct="${line#PCT:}"
        n=${#names[@]}
        [[ "$n" -gt 0 ]] && pcts[$((n - 1))]=$pct
        ;;
    esac
  done < <(parse_items "$tmp")

  local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
  local lines="${LINES:-$(tput lines 2>/dev/null || echo 24)}"
  local bar_w=$((cols - 28)); [[ "$bar_w" -lt 10 ]] && bar_w=10
  local pct=$((idx * 100 / total))
  local filled=$((bar_w * idx / total))
  local bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = filled; i < bar_w; i++)); do bar+="░"; done

  printf '\033[2J\033[H'
  printf '\033[1;36m%s\033[0m %s %3d%% (%d/%d)\n' "$step" "$spin" "$pct" "$idx" "$total"
  printf '%s\n' "$bar"
  printf '\033[2mfull output: %s\033[0m\n' "$LAPTOP_LOG_FILE"
  n=${#names[@]}
  local max_items=$((lines - 4)); [[ "$max_items" -lt 1 ]] && max_items=1
  local start=0
  [[ "$n" -gt "$max_items" ]] && start=$((n - max_items))
  for ((j = start; j < n; j++)); do
    local ipct="${pcts[$j]}" iw=$((bar_w - 12)); [[ "$iw" -lt 6 ]] && iw=6
    local ifilled=$((iw * ipct / 100))
    local ibar=""
    for ((k = 0; k < ifilled; k++)); do ibar+="█"; done
    for ((k = ifilled; k < iw; k++)); do ibar+="░"; done
    printf '  %s %3d%% %s\n' "$ibar" "$ipct" "${names[$j]}"
  done
}

# run_step_verbose <step> <idx> <total> <batch> — full-screen panel with
# per-item progress while the step runs. No output flood: full detail goes
# to the log file; on failure the last lines are shown.
run_step_verbose() {
  local step="$1" idx="$2" total="$3" batch="$4"
  local step_start=$SECONDS pid rc i chars='|/-\\' tmp
  tmp="$(mktemp)"
  STEP_NAME="$step" bash "$REPO_DIR/core/steps/$step.sh" >"$tmp" 2>&1 &
  pid=$!
  i=0
  while kill -0 "$pid" 2>/dev/null; do
    render_panel "$tmp" "$idx" "$total" "$step" "${chars:$i:1}" "$batch"
    i=$(( (i + 1) % ${#chars} ))
    sleep 0.1
  done
  wait "$pid"
  rc=$?
  render_panel "$tmp" "$((idx + 1))" "$total" "$step" "" "$batch"
  sleep 0.3
  printf '\033[2J\033[H'
  cat "$tmp"
  rm "$tmp"
  if [[ "$rc" -eq 0 ]]; then
    ok "step $step done in $((SECONDS - step_start))s"
  else
    fail "step $step failed — fix and re-run: bash $LAPTOP_REPO_DIR/bootstrap.sh --from $step"
  fi
}

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

  preflight
  print_plan
  select_steps

  local step started=false step_start elapsed idx=0 total=${#STEPS[@]} batch=""
  for step in "${STEPS[@]}"; do
    if [[ -n "$FROM_STEP" && "$started" == false && "$step" != "$FROM_STEP" ]]; then
      continue
    fi
    started=true
    if [[ -n "$ONLY_STEP" && "$step" != "$ONLY_STEP" ]]; then
      continue
    fi
    if [[ "$VERBOSE" == true && -t 1 && "$DRY_RUN" == false ]]; then
      local b
      b="$(batch_of "$step")"
      [[ "$b" != "$batch" ]] && batch="$b"
      if has_gum; then
        run_step_gum "$step" "$idx" "$total"
      else
        run_step_verbose "$step" "$idx" "$total" "$batch"
      fi
      idx=$((idx + 1))
      continue
    fi
    step_header "$step"
    if [[ "$DRY_RUN" == true ]]; then
      log "dry-run: would run $step"
      continue
    fi
    step_start=$SECONDS
    if STEP_NAME="$step" bash "$REPO_DIR/core/steps/$step.sh"; then
      elapsed=$((SECONDS - step_start))
      ok "step $step done in ${elapsed}s"
    else
      fail "step $step failed — fix and re-run: bash $REPO_DIR/bootstrap.sh --from $step"
    fi
  done

  echo
  if has_gum; then
    gum style --border double --padding "0 2" --foreground 212 \
      "==> bootstrap complete" \
      "log: $LAPTOP_LOG_FILE" \
      "next: 1Password sign-in, then: bash $LAPTOP_REPO_DIR/core/steps/80-auth.sh" \
      "then: bash $LAPTOP_REPO_DIR/core/steps/90-verify.sh"
  else
    echo "${C_BOLD}${C_GREEN}==> bootstrap complete${C_RESET}"
    echo "  log: $LAPTOP_LOG_FILE"
    echo "  next: 1Password sign-in, then: bash $LAPTOP_REPO_DIR/core/steps/80-auth.sh"
    echo "  then: bash $LAPTOP_REPO_DIR/core/steps/90-verify.sh"
  fi
  log "laptop bootstrap complete"
}

main "$@"
