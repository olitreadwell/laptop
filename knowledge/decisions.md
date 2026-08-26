# Decisions (ADRs)

## ADR-001: Plain bash steps, not Ansible/nix/chezmoi

**Status:** accepted (2026-08-27)

Steps are numbered bash scripts under `core/steps/`, run by `bootstrap.sh`.
No Ansible, no nix-darwin, no chezmoi. Rationale: zero runtime dependencies
beyond bash + curl + git; matches the existing dotfiles approach; every agent
and human can read and edit it.

## ADR-002: Model-agnostic by construction

**Status:** accepted (2026-08-27)

No AI tool or model is required to provision a machine. The loop *may* use
whatever agent CLI is available (`codex`, `claude`, `opencode`), but the
provisioning path is pure bash. Rationale: the user runs Codex with
DeepSeek-flash via Ollama Cloud Pro today and may switch tomorrow; the setup
must not care.

## ADR-003: Exponential backoff loop, 15m → 30m → 60m

**Status:** accepted (2026-08-27)

`loop/loop.sh` runs improvement passes at 15, then 30, then 60 minutes,
capped at 60. No changes → back off; changes or failure → reset to 15.
Rationale: cheap when idle, responsive when the repo is actively improving.

## ADR-004: Idempotency + resume, never destructive

**Status:** accepted (2026-08-27)

Every step detects its own completion from system state; `bootstrap.sh`
supports `--from <step>` to resume. Overwrites always back up first
(`backup_file`). Rationale: a failed setup must never leave the machine
half-broken or lose data.

## ADR-005: Brewfile is a curated seed, not a dump

**Status:** accepted (2026-08-27)

`Brewfile` starts as a dump of the current machine but is meant to be pruned
to top-level tools only (dependencies install automatically). The loop prunes
it over time. Rationale: a 176-formula dump is honest but noisy; the target
is a readable manifest.
