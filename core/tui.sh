#!/usr/bin/env bash
# Interactive step-selection menu. Pure bash + ANSI, no deps — works on a
# fresh machine before Homebrew. Renders to /dev/tty, prints selection to
# stdout. Usage: tui_select_steps <title> <step...>
set -euo pipefail

tui_select_steps() {
  local title="$1"; shift
  local -a items=("$@")
  local -a selected=()
  local i cur=0 key key2 tty=/dev/tty

  for i in "${!items[@]}"; do selected[$i]=1; done

  if [[ ! -w "$tty" ]]; then
    printf '%s\n' "${items[@]}"
    return 0
  fi

  printf '\033[?25l' > "$tty"
  trap 'printf "\033[?25h" > "$tty"' RETURN

  while true; do
    printf '\033[2J\033[H' > "$tty"
    printf '\033[1;36m%s\033[0m\n' "$title" > "$tty"
    for i in "${!items[@]}"; do
      local mark=" "
      [[ "${selected[$i]}" == 1 ]] && mark="x"
      if [[ "$i" == "$cur" ]]; then
        printf '\033[7m[%s] %s\033[0m\n' "$mark" "${items[$i]}" > "$tty"
      else
        printf '[%s] %s\n' "$mark" "${items[$i]}" > "$tty"
      fi
    done
    printf '\n\033[2m↑/↓ move, space toggle, a all, n none, r run, q quit\033[0m' > "$tty"

    IFS= read -rsn1 key < "$tty"
    case "$key" in
      $'\033')
        IFS= read -rsn2 -t 1 key2 < "$tty" || key2=""
        case "$key2" in
          '[A') cur=$((cur > 0 ? cur - 1 : 0)) ;;
          '[B') cur=$((cur < ${#items[@]} - 1 ? cur + 1 : ${#items[@]} - 1)) ;;
        esac
        ;;
      ' ') selected[$cur]=$((1 - selected[$cur])) ;;
      a|A) for i in "${!items[@]}"; do selected[$i]=1; done ;;
      n|N) for i in "${!items[@]}"; do selected[$i]=0; done ;;
      r|R|$'\r') break ;;
      q|Q) printf '\033[2J\033[H' > "$tty"; return 1 ;;
    esac
  done

  printf '\033[2J\033[H' > "$tty"
  for i in "${!items[@]}"; do
    [[ "${selected[$i]}" == 1 ]] && printf '%s\n' "${items[$i]}"
  done
}
