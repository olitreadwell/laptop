# Architecture

## Flow

```
new machine
  └─ git clone laptop
       └─ bootstrap.sh
            ├─ core/detect.sh   → os/arch/chip/model/version/tools
            ├─ core/plan.sh     → ordered step list (platform-filtered)
            ├─ core/steps/*.sh  → run in order, each idempotent
            └─ ~/laptop.log     → full log; resume with --from <step>

ongoing
  └─ loop/loop.sh (15m → 30m → 60m)
       ├─ git pull --ff-only
       ├─ tests/run.sh
       ├─ iterate.sh → agent pass (codex|claude|opencode, model-agnostic)
       ├─ tests/run.sh again → revert if red
       └─ commit + push (Conventional Commits)
```

## Components

- `core/lib.sh` — logging, `run_cmd`, `backup_file`, idempotency markers.
- `core/detect.sh` — prints `KEY=VALUE`; consumed via `eval`.
- `core/plan.sh` — filters steps by filename suffix (`*macos*`, `*arm64*`,
  etc.) so platform-specific steps can be added without touching the runner.
- `core/steps/` — one concern per file, numbered for order. Steps run as
  subprocesses: a failing step can't kill the runner.
- `loop/` — the self-improvement loop. State (backoff level, pid, last run)
  lives in `loop/state/` (gitignored).
- `knowledge/` — machine snapshots, tool inventory, research, decisions.
- `mac/` — per-machine knowledge: current (Intel 2017) and new (M1 2021).

## Safety model

- Idempotent: steps detect completion from system state.
- Backups: `backup_file` before any overwrite.
- Resume: `--from <step>`; a failed run never needs a clean reinstall.
- Non-interactive: `--yes` skips prompts with warnings instead of failing.
- Loop: reverts any pass that fails checks; never touches gitignored state.
