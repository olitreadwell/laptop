#!/usr/bin/env bash
# App config: restore prefs, login items, open apps, sign-in prompts,
# browser extension guide. macOS-only. Idempotent.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

[[ "$(uname -s)" == "Darwin" ]] || { log "not macOS — skipping"; exit 0; }

# 1. Restore app preferences from the repo (config/app-prefs/).
restore_prefs() {
  local domain="$1" plist="$2"
  local container="$HOME/Library/Containers/$domain/Data/Library/Preferences/$domain.plist"
  if [[ -d "$HOME/Library/Containers/$domain" ]]; then
    mkdir -p "$(dirname "$container")"
    cp "$plist" "$container" && ok "prefs restored: $domain (container)" && return 0
  fi
  defaults import "$domain" "$plist" 2>/dev/null \
    && ok "prefs restored: $domain" \
    || warn "prefs restore failed: $domain"
}
prefs_dir="$LAPTOP_REPO_DIR/config/app-prefs"
if [[ -d "$prefs_dir" ]]; then
  for plist in "$prefs_dir"/*.plist; do
    [[ -f "$plist" ]] || continue
    restore_prefs "$(basename "$plist" .plist)" "$plist"
  done
else
  log "no app-prefs dir — skipping prefs restore"
fi

# 2. Login items (idempotent).
add_login_item() {
  local app="$1" path="/Applications/$app.app"
  [[ -d "$path" ]] || { log "not installed, skipping login item: $app"; return 0; }
  if osascript -e "tell application \"System Events\" to exists login item \"$app\"" 2>/dev/null | grep -qi true; then
    log "login item present: $app"
  else
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$path\", hidden:false}" 2>/dev/null \
      && ok "login item added: $app" \
      || warn "login item failed (Automation permission?): $app"
  fi
}
for app in Dato LuLu Espanso Rectangle Raycast KeepingYouAwake Claude Hammerspoon eul; do
  add_login_item "$app"
done

# 3. Open key apps for first-run setup.
for app in 1Password Raycast Espanso eul Claude; do
  if [[ -d "/Applications/$app.app" ]]; then
    open -a "$app" 2>/dev/null && log "opened $app for first-run"
  fi
done

# 4. Sign-in prompts.
if is_installed mas && ! mas account >/dev/null 2>&1; then
  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    warn "App Store not signed in — run manually: mas signin"
  else
    log "App Store sign-in needed — follow the prompt"
    run_cmd_soft "mas signin" mas signin
  fi
fi

# 5. Browser extension guide + open browsers.
log "1Password browser extensions:"
log "  Safari: 1Password for Safari (mas) — enable in Safari → Settings → Extensions"
log "  Chrome/Brave/Firefox: 1Password → Settings → Browsers → install extension"
for b in "Google Chrome" "Brave Browser" "Firefox"; do
  if [[ -d "/Applications/$b.app" ]]; then
    open -a "$b" 2>/dev/null && log "opened $b — sign in + enable 1Password extension"
  fi
done
