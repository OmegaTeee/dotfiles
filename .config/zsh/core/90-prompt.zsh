# Powerlevel10k.

typeset p10k_theme="/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme"

[[ -r $p10k_theme ]] &&
  source "$p10k_theme"

[[ -r "$HOME/.p10k.zsh" ]] &&
  source "$HOME/.p10k.zsh"

unset p10k_theme
