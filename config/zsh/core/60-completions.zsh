# Completion initialization.

typeset -gU fpath FPATH

[[ -d /opt/homebrew/share/zsh-completions ]] &&
  fpath=(/opt/homebrew/share/zsh-completions $fpath)

# Completions installed by Homebrew formulae (moved from the old ~/.zshenv,
# where argcomplete had added it).
[[ -d /opt/homebrew/share/zsh/site-functions ]] &&
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# argcomplete: version-independent path (newest python3.* wins).
typeset -a _argcomplete_dirs
_argcomplete_dirs=(/opt/homebrew/opt/python-argcomplete/libexec/lib/python3.*/site-packages/argcomplete/bash_completion.d(N/On))
(( ${#_argcomplete_dirs} )) && fpath=($_argcomplete_dirs[1] $fpath)
unset _argcomplete_dirs

[[ -d "$HOME/.zfunc" ]] &&
  fpath=("$HOME/.zfunc" $fpath)

autoload -Uz compinit

typeset -g ZSH_COMPDUMP="${ZSH_CACHE_HOME}/zcompdump-${ZSH_VERSION}"

if [[ -s $ZSH_COMPDUMP ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi

# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# headroom-deploy: complete actions, then profile names/shorthands.
_headroom_deploy() {
  local deploy_dir="${HEADROOM_HOME:-$HOME/.headroom}/deploy"
  local -a profiles
  profiles=(${deploy_dir}/*/manifest.json(N:h:t) ${(k)HEADROOM_PROFILE_ALIASES})
  _arguments \
    '1:action:(start stop restart status health logs)' \
    "2:profile:(${profiles[*]})"
}
(( $+functions[compdef] )) && compdef _headroom_deploy headroom-deploy
return 0
