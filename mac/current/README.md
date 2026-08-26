# Current Mac — MacBook Pro 14,2 (2017, Intel)

Source of truth for what the setup must reproduce. Live snapshot:
`knowledge/current-machine.md` (regenerate with `make snapshot`).

## Specs

- MacBook Pro 14,2 — 13" Touch Bar, 2017
- Intel Core i7 3.5 GHz, 2 cores, 16 GB RAM
- macOS 13.6.8 Ventura

## Limitations (why the new machine matters)

- Intel-only Homebrew prefix `/usr/local`; no arm64 bottles.
- macOS 13 is past its support window — some tools drop support.
- `update_system.sh` already works around source-only formulae (no bottles on
  Intel/macOS 13) by upgrading only bottled formulae.
- 2 cores: builds are slow; mise/npm installs take a while.

## What to carry over

- Dotfiles install pattern (plain-git symlinks, `~/install.sh`).
- ai-harness wiring (`~/.agents/install.sh`).
- 1Password SSH agent socket in `~/.ssh/config`.
- Codex config: `deepseek-v4-flash:0731` via `ollama-cloud`, 400k context.
- Ghostty + starship + oh-my-zsh + fzf + zoxide shell stack.
