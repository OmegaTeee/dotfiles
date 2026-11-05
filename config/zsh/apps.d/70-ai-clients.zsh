# Shared AI client defaults.
# Actual secret loading and process startup happen only when wrappers are invoked.

export OPENAI_MODEL="${PH_DAEMON_MODEL}"
export OPENROUTER_BASE_URL="https://openrouter.ai/api/v1"
export OPENROUTER_MODEL="openrouter/free"
export LM_STUDIO_API_URL="http://127.0.0.1:1234/v1"
export LM_STUDIO_MODEL="${PH_DAEMON_MODEL}"
