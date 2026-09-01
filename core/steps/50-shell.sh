#!/usr/bin/env bash
# Shell: zsh, oh-my-zsh, starship, fzf, zoxide, autosuggestions, highlighting.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"

if is_installed brew; then
  run_cmd "install shell tools" brew install --yes zsh starship fzf zoxide zsh-autosuggestions zsh-syntax-highlighting
fi

if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  run_cmd "clone oh-my-zsh" git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  log "oh-my-zsh present"
fi

# Starship prompt: the dotfiles install links the dark/light variants, but
# the active ~/.config/starship.toml is normally created by the
# starship-dark / starship-light functions. Link the dark variant by default
# so the two-line prompt works out of the box.
if [[ -f "$HOME/.config/starship.dark.toml" ]] && [[ ! -e "$HOME/.config/starship.toml" ]]; then
  ln -s "$HOME/.config/starship.dark.toml" "$HOME/.config/starship.toml"
  ok "starship config linked (dark)"
fi

if [[ "$(uname -s)" == "Darwin" ]] && is_installed zsh; then
  if [[ "$(dscl . -read "$HOME" UserShell 2>/dev/null)" != *zsh* ]]; then
    run_cmd "set default shell" chsh -s "$(command -v zsh)"
  else
    log "zsh is the default shell"
  fi
fi
