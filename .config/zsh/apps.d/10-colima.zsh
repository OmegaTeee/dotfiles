# Colima integration.

export COLIMA_PROJECT_ROOT="${COLIMA_PROJECT_ROOT:-$PROJECT_FOLDER}"

autoload -Uz add-zsh-hook

_colima_chpwd_hook() {
  emulate -L zsh

  [[ ${ZSH_AUTO_START_COLIMA:-0} == 1 ]] || return 0
  [[ $PWD == ${COLIMA_PROJECT_ROOT}(|/*) ]] || return 0
  (( $+commands[colima] )) || return 0

  command colima status >/dev/null 2>&1 ||
    command colima start >/dev/null 2>&1
}

add-zsh-hook chpwd _colima_chpwd_hook
