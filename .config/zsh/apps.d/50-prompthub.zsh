# PromptHub integration.

export PROMPTHUB_HOME="${HOME}/prompthub"

[[ -d "$PROMPTHUB_HOME/app/.venv/bin" ]] &&
  path=("$PROMPTHUB_HOME/app/.venv/bin" $path)

alias prompthub-router='launchctl kickstart -k gui/$(id -u)/com.prompthub.router'
alias prompthub-router-stop='launchctl bootout gui/$(id -u)/com.prompthub.router'
alias prompthub-health='curl --fail --silent --show-error http://localhost:9090/health'
alias prompthub-logs='tail -f ~/prompthub/logs/router-stderr.log'
