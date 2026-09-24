#!/usr/bin/env bash
# Sanity checks: syntax-check every script, run detect + plan, shellcheck.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

while IFS= read -r -d '' f; do
  if ! bash -n "$f"; then
    echo "FAIL: syntax: $f"
    failures=$((failures + 1))
  fi
done < <(find "$REPO_DIR" -name '*.sh' -not -path '*/state/*' -print0)

out="$(bash "$REPO_DIR/core/detect.sh")"
for key in os arch chip model macos_version; do
  grep -q "^$key=" <<<"$out" || { echo "FAIL: detect missing $key"; failures=$((failures + 1)); }
done

plan="$(bash "$REPO_DIR/core/plan.sh")"
[[ -n "$plan" ]] || { echo "FAIL: empty plan"; failures=$((failures + 1)); }

if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r -d '' f; do
    # SC1090/SC1091: three hook scripts source a path assembled at runtime
    # (an agent hook endpoint and the repo's own lib.sh), which shellcheck
    # cannot follow. Everything else at warning level stays fatal.
    shellcheck -S warning -e SC1090,SC1091 "$f" || { echo "FAIL: shellcheck: $f"; failures=$((failures + 1)); }
  done < <(find "$REPO_DIR" -name '*.sh' -not -path '*/state/*' -print0)
fi

if [[ "$failures" -gt 0 ]]; then
  echo "tests failed: $failures"
  exit 1
fi
echo "all checks passed"
