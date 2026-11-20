# Powerlevel10k.

typeset p10k_theme="/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme"

[[ -r $p10k_theme ]] &&
  source "$p10k_theme"

# `p10k configure` writes ${ZDOTDIR:-$HOME}/.p10k.zsh, so read it from there.
if [[ -r "${ZDOTDIR:-$HOME}/.p10k.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.p10k.zsh"
elif [[ -r "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi

unset p10k_theme
