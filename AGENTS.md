# Agent Instructions (laptop)

This repo provisions machines and improves itself. Read `PROMPT.md` first —
it defines the two modes (improve / provision) and the quality bar.

## Conventions

- Steps are numbered bash files in `core/steps/`; one concern per file.
  Order = filename order. Platform-specific steps get a suffix the planner
  filters on: `*macos*`, `*linux*`, `*arm64*`, `*intel*`.
- Every step: `set -euo pipefail`, source `core/lib.sh`, detect its own
  completion from system state, log start/end, never destroy data.
- Names are 2-3 word, domain-prefixed (`run_cmd`, `backup_file`,
  `mark_done`) — grep-friendly.
- Knowledge lives in `knowledge/`; machine-specific notes in `mac/`.
- Decisions go in `knowledge/decisions.md` (ADR format) before adoption.
- Commits use Conventional Commits (`feat`, `fix`, `chore`, `docs`, `test`).

## Rules for the loop

- One pass per iteration; scope by `LAPTOP_PASS_SIZE` (`small` default,
  `medium`, `large` — see `PROMPT.md` Improve mode).
- Never touch secrets, `loop/state/`, or anything gitignored.
- Never rewrite working code for style.
- Always run `tests/run.sh` before committing; revert if red.
- Keep docs in sync in the same commit.

## Testing

`make check` runs: `bash -n` on every script, `core/detect.sh` key checks,
`core/plan.sh` non-empty plan, shellcheck (if installed).
