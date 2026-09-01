#!/usr/bin/env bash
# Automation stack: SSH (1Password agent), codex subagents, LaunchAgents.
# Restores from the repo (automation/); idempotent, backs up before overwrite.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

[[ "$(uname -s)" == "Darwin" ]] || { log "not macOS — skipping"; exit 0; }

# 1. SSH config: 1Password SSH agent (IdentityAgent socket).
if [[ -f "$LAPTOP_REPO_DIR/automation/ssh-config" ]]; then
  mkdir -p "$HOME/.ssh"
  if [[ -f "$HOME/.ssh/config" ]] && ! grep -q "2BUA8C4S2C.com.1password" "$HOME/.ssh/config" 2>/dev/null; then
    backup_file "$HOME/.ssh/config"
  fi
  cp "$LAPTOP_REPO_DIR/automation/ssh-config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  fix_home_paths "$HOME/.ssh/config"
  ok "ssh config set (1Password agent)"
fi

# 2. Codex subagents (explorer, oracle, etc.).
if [[ -d "$LAPTOP_REPO_DIR/automation/codex-agents" ]]; then
  mkdir -p "$HOME/.codex/agents"
  for f in "$LAPTOP_REPO_DIR/automation/codex-agents/"*.toml; do
    [[ -f "$f" ]] || continue
    cp "$f" "$HOME/.codex/agents/$(basename "$f")"
  done
  ok "codex subagents installed"
fi

# 3. Orca agent hooks — wire Orca to codex/claude as its agents.
if [[ -d "$LAPTOP_REPO_DIR/automation/orca-agent-hooks" ]]; then
  mkdir -p "$HOME/.orca/agent-hooks"
  for f in "$LAPTOP_REPO_DIR/automation/orca-agent-hooks/"*.sh; do
    [[ -f "$f" ]] || continue
    cp "$f" "$HOME/.orca/agent-hooks/$(basename "$f")"
    chmod +x "$HOME/.orca/agent-hooks/$(basename "$f")"
  done
  ok "orca agent hooks installed"
fi

# 4. LaunchAgents — the automation stack (career, dashboards, digests,
#    loops, gmail-mcp, etc.). Loads each; missing target scripts fail
#    gracefully and work once their repos/credentials exist.
if [[ -d "$LAPTOP_REPO_DIR/automation/launchagents" ]]; then
  mkdir -p "$HOME/Library/LaunchAgents"
  for f in "$LAPTOP_REPO_DIR/automation/launchagents/"*.plist; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    dest="$HOME/Library/LaunchAgents/$name"
    if [[ -f "$dest" ]] && ! diff -q "$f" "$dest" >/dev/null 2>&1; then
      backup_file "$dest"
    fi
    cp "$f" "$dest"
    fix_home_paths "$dest"
    if ! launchctl list 2>/dev/null | grep -q "${name%.plist}"; then
      launchctl bootstrap "gui/$(id -u)" "$dest" 2>/dev/null \
        || launchctl load "$dest" 2>/dev/null || true
    fi
  done
  ok "launch agents restored"
fi
