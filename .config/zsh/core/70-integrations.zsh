# Lightweight terminal integrations.

if (( $+commands[direnv] )); then
  eval "$(command direnv hook zsh)"
fi

# VS Code normally injects shell integration itself.
if [[ $TERM_PROGRAM == vscode &&
      ${ZSH_FORCE_VSCODE_INTEGRATION:-0} == 1 ]] &&
   (( $+commands[code-insiders] || $+commands[code] )); then
  typeset vscode_cli vscode_integration
  if (( $+commands[code-insiders] )); then
    vscode_cli=code-insiders
  else
    vscode_cli=code
  fi

  vscode_integration="$(command "$vscode_cli" --locate-shell-integration-path zsh 2>/dev/null)"
  [[ -r $vscode_integration ]] && source "$vscode_integration"
  unset vscode_cli vscode_integration
fi

if [[ $TERM_PROGRAM == iTerm.app &&
      -r "$HOME/.iterm2_shell_integration.zsh" ]]; then
  source "$HOME/.iterm2_shell_integration.zsh"
fi
