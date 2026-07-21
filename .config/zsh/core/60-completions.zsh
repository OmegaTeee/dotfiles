# Completion initialization.

typeset -gU fpath FPATH

[[ -d /opt/homebrew/share/zsh-completions ]] &&
  fpath=(/opt/homebrew/share/zsh-completions $fpath)

[[ -d "$HOME/.zfunc" ]] &&
  fpath=("$HOME/.zfunc" $fpath)

autoload -Uz compinit

typeset -g ZSH_COMPDUMP="${ZSH_CACHE_HOME}/zcompdump-${ZSH_VERSION}"

if [[ -s $ZSH_COMPDUMP ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi
