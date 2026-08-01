# Activate mise after the base PATH has been assembled.

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

