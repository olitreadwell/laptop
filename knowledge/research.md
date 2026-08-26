# Research Notes

Dated findings on laptop-setup approaches. Verdict column: adopt / consider /
reject. New findings go at the top. Never adopt without a decision in
`knowledge/decisions.md`.

## 2026-08-27 — Landscape scan (seed)

- **thoughtbot/laptop** — the classic: single idempotent `mac` script, logs to
  `~/laptop.log`, installs/upgrades/skips based on what's installed. Verdict:
  adopt its idempotency + logging conventions; we split into ordered steps
  instead of one script.
- **minamarkham/formation** (1.8k★) — macOS setup script for front-end dev.
  Verdict: consider as a source of step ordering + cask choices.
- **narze/dotfiles** (174★) — chezmoi-managed, 1-line setup, tested on Apple
  Silicon. Verdict: we already replaced chezmoi with plain-git symlinks
  (`dotfiles/executable_install.sh`); keep that, it's simpler.
- **geerlingguy/mac-dev-playbook** — Ansible-based. Verdict: reject for now;
  adds a runtime dependency (Ansible) for no gain over bash steps.
- **nix-darwin / home-manager** — declarative, powerful, steep learning curve.
  Verdict: reject for now; revisit only if bash steps prove unmaintainable.
- **1Password CLI + SSH agent** — `op` + `~/.ssh/config` IdentityAgent socket
  is already the working pattern on the current Mac. Verdict: adopt as the
  secret/SSH path on the new machine.
- **mas** — App Store CLI, already installed. Verdict: adopt for App Store
  apps in step 70.

## Open questions

- Agent-driven provisioning: run `bootstrap.sh` under an agent that reads
  errors and self-heals? Test on the current Mac first (dry-run → real).
- Rosetta 2: install unconditionally on Apple Silicon, or only when an x86
  tool is needed? Current answer: install it, it's cheap and avoids
  mid-setup surprises.
- Migration Assistant vs fresh setup for the new MacBook: fresh setup +
  this repo is the plan; Migration Assistant only for app data that has no
  sync (rare).
