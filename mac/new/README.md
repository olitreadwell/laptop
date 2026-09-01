# New Mac — MacBook Pro M1 2021 16"

Next provisioning target. Apple Silicon changes several assumptions.

## Specs (expected)

- MacBook Pro 18,x — 16" 2021, M1 Pro/Max
- Apple Silicon (arm64), macOS Sequoia/Tahoe era

## Apple Silicon differences

- Homebrew installs to `/opt/homebrew`; PATH must include it (step
  `30-homebrew.sh` handles this).
- Rosetta 2 needed for x86-only tools: installed by `15-rosetta-arm64.sh`
  (`softwareupdate --install-rosetta --agree-to-license`) before brew bundle.
- arm64 bottles for most formulae; some tools still x86-only — detect and
  warn, don't fail.
- `uname -m` returns `arm64`; `core/detect.sh` reports `chip=apple-silicon`.
- Newer macOS: `defaults` keys change, Gatekeeper stricter, 1Password SSH
  agent behavior may differ — verify step 20 on the real machine.

## New-machine runbook

See `docs/new-machine-runbook.md`.
