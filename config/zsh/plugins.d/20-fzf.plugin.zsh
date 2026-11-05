# General-purpose command-line fuzzy finder

if (( $+commands[fzf] )); then
  if source <(command fzf --zsh); then
    ZSH_PLUGIN_STATUS[fzf]="active"
  else
    ZSH_PLUGIN_STATUS[fzf]="failed to initialize"
  fi
else
  ZSH_PLUGIN_STATUS[fzf]="unavailable (fzf is not on PATH)"
fi
