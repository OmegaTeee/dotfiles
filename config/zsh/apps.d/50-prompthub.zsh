# PromptHub integration.

export PROMPTHUB_HOME="${PROMPTHUB_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/prompthub}"

[[ -d "$PROMPTHUB_HOME/app/.venv/bin" ]] &&
  path=("$PROMPTHUB_HOME/app/.venv/bin" $path)

alias prompthub-router='launchctl kickstart -k gui/$(id -u)/com.prompthub.router'
alias prompthub-router-stop='launchctl bootout gui/$(id -u)/com.prompthub.router'
alias prompthub-health='curl --fail --silent --show-error http://localhost:9090/health'
alias prompthub-logs='tail -f "$PROMPTHUB_HOME/logs/router-stderr.log"'
