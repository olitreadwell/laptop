#!/usr/bin/env bash
# One improvement pass: checks → agent pass → checks → commit + push.
# Safe: reverts the pass if checks fail; never touches ignored state.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

run_checks() {
  bash "$REPO_DIR/tests/run.sh"
}

if ! run_checks; then
  echo "[iterate] checks failed before pass — fix manually, not by the loop"
  exit 1
fi

PASS_SIZE="${LAPTOP_PASS_SIZE:-small}"
case "$PASS_SIZE" in
  small|medium|large) ;;
  *) echo "[iterate] invalid LAPTOP_PASS_SIZE=$PASS_SIZE (small|medium|large)"; exit 1 ;;
esac

AGENT="${LAPTOP_AGENT:-auto}"
case "$AGENT" in
  none)
    echo "[iterate] agent disabled (LAPTOP_AGENT=none)"
    exit 0
    ;;
  auto)
    if command -v codex >/dev/null 2>&1; then
      AGENT=codex
    elif command -v claude >/dev/null 2>&1; then
      AGENT=claude
    elif command -v opencode >/dev/null 2>&1; then
      AGENT=opencode
    else
      echo "[iterate] no agent CLI found — set LAPTOP_AGENT=codex|claude|opencode"
      exit 0
    fi
    ;;
esac

case "$PASS_SIZE" in
  small)
    PROMPT="Read PROMPT.md. Run ONE bounded improvement pass per its Improve mode rules. Pick one small change: fix a failing check, improve one step, research one approach, or tighten one safety gap. Keep it idempotent, safe, and verifiable. Do not touch secrets. Then run tests/run.sh and fix until green."
    ;;
  medium)
    PROMPT="Read PROMPT.md. Run ONE improvement pass. Scope: a few related changes that together improve one area — e.g. one step plus its docs plus its test, or one knowledge section plus its decision. Keep it idempotent, safe, and verifiable. Do not touch secrets. Then run tests/run.sh and fix until green."
    ;;
  large)
    PROMPT="Read PROMPT.md. Run ONE deep improvement pass. Scope: a larger improvement — add a new step, refactor an area, add platform support (linux/pi/server), or fix a systemic gap. Multiple related changes OK. Keep it idempotent, safe, and verifiable. Update docs and tests in the same pass. Do not touch secrets. Then run tests/run.sh and fix until green."
    ;;
esac

echo "[iterate] agent pass via $AGENT (size=$PASS_SIZE)"
case "$AGENT" in
  codex)    codex exec --skip-git-repo-check "$PROMPT" ;;
  claude)   claude -p "$PROMPT" ;;
  opencode) opencode run "$PROMPT" ;;
esac

if ! run_checks; then
  echo "[iterate] checks failed after agent pass — reverting"
  git checkout -- . 2>/dev/null || true
  git clean -fd 2>/dev/null || true
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "chore(laptop): loop improvement pass $(date +%Y-%m-%d)"
  git push origin HEAD 2>/dev/null || echo "[iterate] push failed (offline?)"
  echo "[iterate] committed and pushed"
else
  echo "[iterate] no changes"
fi
