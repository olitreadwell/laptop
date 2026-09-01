# Laptop

Personal, version-controlled laptop provisioning system. Sets up a new
machine from zero to daily-driver in the right order, idempotently and
safely. Continuously improves itself via an agent loop with exponential
backoff (15m → 30m → 60m).

Model-agnostic: provisioning is pure bash; the improvement loop uses
whatever agent CLI is available (`codex`, `claude`, `opencode`).

## Quickstart

```sh
git clone https://github.com/olitreadwell/laptop ~/laptop
bash ~/laptop/bootstrap.sh --dry-run   # preview the plan
bash ~/laptop/bootstrap.sh            # run it
```

Full new-machine walkthrough: `docs/new-machine-runbook.md`.

## Commands

- `bash bootstrap.sh` — provision this machine (idempotent, safe to re-run).
- `bash bootstrap.sh --from <step>` — resume from a failed step.
- `bash bootstrap.sh --yes` — non-interactive (skips prompts with warnings).
- `bash bootstrap.sh --verbose` — live progress: gum spinner + styled
  headers when gum is installed, ANSI per-item panel otherwise.
- `bash bootstrap.sh --menu` — interactive step-selection menu.
- `bash bootstrap.sh --only <step>` — run a single step.
- `bash bootstrap.sh --parallel` — run independent steps concurrently
  (waves: 1Password/dotfiles/repos/settings, then shell/runtimes/apps).
- `make check` — syntax + detect + plan + shellcheck tests.
- `make snapshot` — regenerate `knowledge/current-machine.md` +
  `knowledge/tool-inventory.md` from this machine.
- `bash loop/loop.sh --once|--deep|--daemon|--stop|--status` — improvement
  loop. `--deep` runs one large pass; daemon pass size via `LAPTOP_PASS_SIZE`
  (`small` default, `medium`, `large`).

## Layout

- `PROMPT.md` — the operating prompt (improve mode + provision mode rules).
- `core/` — detection, planning, and ordered idempotent steps.
- `loop/` — self-improvement loop with exponential backoff.
- `knowledge/` — machine snapshots, tool inventory, research, decisions.
- `mac/` — per-machine knowledge (current Intel 2017, new M1 2021).
- `docs/` — architecture + new-machine runbook.

## How it improves itself

`loop/loop.sh` runs one agent pass per iteration: pull → check → agent
improves (size via `LAPTOP_PASS_SIZE`: small/medium/large) → check → commit +
push. No changes → back off (15 → 30 → 60 min, capped). Changes or failure →
reset to 15 min. Scope rules and definition of done live in `PROMPT.md`.

## Related repos

- `github.com/olitreadwell/dotfiles` — dotfiles, installed via plain-git
  symlinks (`~/install.sh`).
- `github.com/olitreadwell/ai-harness` — agent skills + wiring
  (`~/.agents/install.sh`).
