# Laptop — Master Prompt

This file is the operating prompt for the `laptop` repo. It drives two modes:

1. **Improve mode** — run by the self-improvement loop (`loop/loop.sh`) or by
   any agent pointed at this file. Goal: make the repo safer, faster, and
   more complete, one small verifiable change at a time.
2. **Provision mode** — run on a new machine. Goal: set the machine up from
   zero to daily-driver in the right order, idempotently, with no damage on
   failure.

Model-agnostic: works with Codex, Claude Code, Cursor, Orca, OpenCode, Gemini
CLI, or any agent that reads markdown and runs shell commands. No model-specific
syntax anywhere. Scripts are plain bash; the loop is plain bash.

## Mission

Build and maintain a personal, version-controlled laptop provisioning system
that:

- Sets up a new machine from zero to daily-driver in the right order.
- Is idempotent: safe to re-run any number of times; re-runs converge.
- Fails safely: never destroys data; every step logs, reports, and can resume.
- Detects the machine it runs on (OS, chip, model, macOS version, existing
  tools) and adapts its plan.
- Is model-agnostic: no hard dependency on any AI tool or model.
- Continuously improves itself via a loop with exponential backoff
  (15 min → 30 min → 60 min, capped).
- Is version controlled: every change is a commit with a clear message.

## Context

### Current machine (source of truth)

- MacBook Pro 14,2 — 2017 13" Intel Core i7 3.5 GHz, 16 GB RAM
- macOS 13.6.8 Ventura
- Homebrew at `/usr/local` (Intel prefix), 176 formulae + 27 casks
- Dotfiles: `github.com/olitreadwell/dotfiles` — plain-git symlink install
  (`~/install.sh`, `~/update_system.sh`), no chezmoi
- Agent harness: `~/.agents` = `github.com/olitreadwell/ai-harness` — skills +
  `install.sh` wiring into Claude Code, OpenCode, Codex
- Runtimes via mise: bun latest, node lts, python 3.14.2, ruby 3.4.9
  (also present: java 26.0.2, maven 3.9.16)
- 1Password + 1Password CLI (`op`), SSH agent socket, secrets in `~/.config/op`
- Codex CLI: model `deepseek-v4-flash:0731` via `ollama-cloud` (Ollama Cloud
  Pro), 400k context, `approval_policy = "never"`, `danger-full-access`
- Terminal: Ghostty; prompt: starship; shell: zsh + oh-my-zsh; fzf, zoxide
- GitHub CLI with credential helper; GPG signing (key `C0BE2AC185873969`)
- Custom scripts in `~/bin` (git helpers, gmail sync, etc.)
- Repos in `~/code` (learning, nz-data-lab, nz-tech-for-good, etc.)
- AI editor: Orca (agent hooks in `~/.orca/agent-hooks`)

### Target machine (next focus)

- MacBook Pro M1 2021 16" (Apple Silicon)
- macOS current (Sequoia/Tahoe era)
- Differences that matter: `/opt/homebrew` prefix, Rosetta 2 for x86 tools,
  arm64 builds, newer macOS defaults, different 1Password/SSH agent behavior

### Future targets (design for, don't build yet)

- Linux desktop, Raspberry Pi, home server, Windows (low priority)

## Repo layout

```
laptop/
├── PROMPT.md              # this file — the operating prompt
├── README.md              # quickstart + commands
├── AGENTS.md              # conventions for agents working in this repo
├── bootstrap.sh           # provision entry point: detect → plan → run → verify
├── Brewfile               # current machine's Homebrew manifest (seed, curated)
├── repos.txt              # personal repos cloned into ~/code (step 45)
├── Makefile               # check / test / snapshot targets
├── core/
│   ├── lib.sh             # logging, error handling, idempotency helpers
│   ├── detect.sh          # OS/chip/model/version/tool detection
│   ├── plan.sh            # ordered step list for this machine
│   └── steps/             # one idempotent step per file, numbered
│       ├── 10-prereqs.sh  # Xcode CLT, sudo
│       ├── 20-homebrew.sh # Homebrew + brew bundle
│       ├── 30-1password.sh# 1Password app + CLI + SSH agent
│       ├── 40-dotfiles.sh # dotfiles + ai-harness
│       ├── 45-repos.sh    # clone personal repos from repos.txt
│       ├── 50-shell.sh    # zsh, oh-my-zsh, starship, fzf, zoxide
│       ├── 60-runtimes.sh # mise + node/python/ruby/bun
│       ├── 70-apps.sh     # App Store (mas) + app-level extras
│       ├── 80-auth.sh     # gh / claude / codex auth
│       └── 90-verify.sh   # final checks + report
├── loop/
│   ├── loop.sh            # exponential backoff runner (15m → 30m → 60m)
│   ├── iterate.sh         # one improvement pass (checks → agent → commit)
│   └── state/             # gitignored: backoff level, pid, last run
├── knowledge/
│   ├── current-machine.md # live snapshot of the current Mac
│   ├── tool-inventory.md  # brew/mise/npm/custom-bin inventory
│   ├── research.md        # dated research notes (new approaches)
│   ├── decisions.md       # ADRs — why things are the way they are
│   └── snapshot.sh        # regenerates the two snapshot files
├── mac/
│   ├── current/           # current Mac specifics + limitations
│   └── new/               # new MacBook Pro M1 2021 16" specifics
├── docs/
│   ├── architecture.md    # how the pieces fit
│   └── new-machine-runbook.md # step-by-step for the new laptop
└── tests/
    └── run.sh             # syntax + detect + plan + shellcheck
```

## Quality bar

Every change must keep all of:

1. **Idempotency** — re-running is a no-op or converges to the same state.
2. **Safety** — backup before overwrite; never delete user data; sudo prompts
   explicit; `--yes` mode skips interactive steps with a warning instead of
   failing.
3. **Ordering** — steps numbered, dependencies respected: CLT → 1Password →
   Homebrew → git/gh → dotfiles → shell → runtimes → apps → auth → verify.
4. **Error handling** — every step logs start/end, returns non-zero on hard
   failure, and the runner prints the failing step + resume command.
5. **Version control** — one logical change per commit, Conventional Commits.
6. **Tests** — `bash -n` on every script, `tests/run.sh` green, shellcheck
   clean where available.
7. **Docs** — README, runbook, architecture, decisions stay in sync with code.

## Improve mode (the loop)

Run by `loop/loop.sh` with exponential backoff: 15 min → 30 min → 60 min
(capped at 60). Each iteration:

1. `git pull --ff-only` (offline → skip silently).
2. Run checks: `bash -n` all scripts + `tests/run.sh`.
3. If an agent CLI is available (`codex`, `claude`, `opencode` — first found,
   override with `LAPTOP_AGENT`), run ONE improvement pass with this file as
   context. Pass size is set by `LAPTOP_PASS_SIZE` (default `small`):
   - `small` — one bounded change: fix a failing check, improve one step,
     research one approach, tighten one safety gap.
   - `medium` — a few related changes that improve one area (step + its docs
     + its test, or a knowledge section + its decision).
   - `large` — a bigger improvement: new step, refactor, platform support
     (linux/pi/server), or a systemic gap. Multiple related changes OK.
   All sizes: keep it idempotent, safe, and verifiable; update docs and tests
   in the same pass. Do NOT: rewrite working code for style, add unrequested
   features, touch secrets, or make changes that can't be verified.
4. Re-run checks. Green + changes → commit (Conventional Commits) and push.
   Not green → revert the pass, log why.
5. Backoff: no changes → next level (15 → 30 → 60, cap 60). Changes or
   failure → reset to 15.

## Provision mode (new machine)

On the new machine:

1. Install Xcode Command Line Tools (`xcode-select --install`).
2. `git clone https://github.com/olitreadwell/laptop ~/laptop`
3. `bash ~/laptop/bootstrap.sh --dry-run` to preview, then
   `bash ~/laptop/bootstrap.sh`
4. Follow `docs/new-machine-runbook.md` for interactive bits (1Password
   sign-in, SSH, auth).

`bootstrap.sh` must: detect the machine, print the plan, run steps in order,
log to `~/laptop.log`, stop on the first hard failure with a resume command,
and never leave the machine half-broken (each step idempotent, so re-running
resumes cleanly).

## Research protocol

Each improve pass may research (web) one of:

- New AI-native setup approaches (agent-driven provisioning, declarative
  manifests, chezmoi/nix-darwin tradeoffs).
- New tool versions or replacements for pinned tools.
- Apple Silicon / macOS-version-specific gotchas.

Record findings in `knowledge/research.md` with date, source, verdict. Never
adopt a new approach without a decision in `knowledge/decisions.md`.

## Definition of done for a change

- Checks green (`bash -n`, `tests/run.sh`, shellcheck).
- Idempotent and safe (backups, no destructive ops).
- Docs updated in the same commit.
- Committed with a Conventional Commits message.
- Pushed.
