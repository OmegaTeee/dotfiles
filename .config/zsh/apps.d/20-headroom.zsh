# Headroom integration.

export HEADROOM_PROXY_URL="http://127.0.0.1:8787"
export HEADROOM_HOME="${HOME}/.local/share/prompthub/headroom"

[[ -d "$HEADROOM_HOME/.venv/bin" ]] &&
  path=("$HEADROOM_HOME/.venv/bin" $path)

export OPENAI_BASE_URL="${HEADROOM_PROXY_URL}/v1"
export OPENAI_API_BASE="${HEADROOM_PROXY_URL}/v1"
export ANTHROPIC_BASE_URL="${HEADROOM_PROXY_URL}/v1"
export COPILOT_PROVIDER_TYPE="${COPILOT_PROVIDER_TYPE:-anthropic}"
export COPILOT_PROVIDER_BASE_URL="${HEADROOM_PROXY_URL}/v1"
