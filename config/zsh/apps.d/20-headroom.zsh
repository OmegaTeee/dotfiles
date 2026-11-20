# Headroom (context-compression proxy) deployments.
#
# Headroom manages its own state in ~/.headroom (databases, logs, deploy
# scripts). That folder is never copied into this repo.
#
# Non-secret defaults that `headroom install apply` used to append to
# ~/.zshrc. ~/.zshrc is dead under ZDOTDIR, so they live here now.
# Tokens (e.g. the LM Studio key) are deliberately NOT exported here.
export HEADROOM_PORT="${HEADROOM_PORT:-8788}"
export HEADROOM_HOST="${HEADROOM_HOST:-127.0.0.1}"
export HEADROOM_MODE="${HEADROOM_MODE:-token}"
export HEADROOM_BACKEND="${HEADROOM_BACKEND:-anthropic}"
export HEADROOM_EMBEDDER_RUNTIME="${HEADROOM_EMBEDDER_RUNTIME:-cpu}"
export HEADROOM_KOMPRESS_BACKEND="${HEADROOM_KOMPRESS_BACKEND:-onnx}"
export HEADROOM_TELEMETRY="${HEADROOM_TELEMETRY:-off}"
export OPENAI_TARGET_API_URL="${OPENAI_TARGET_API_URL:-http://127.0.0.1:1234/v1}"

# Shorthand -> deployment profile (folder name under ~/.headroom/deploy).
typeset -gA HEADROOM_PROFILE_ALIASES=(
  lms   visualval-lmstudio   # :8788, LM Studio upstream
  init  init-visualval       # :8787
)
typeset -g HEADROOM_DEFAULT_PROFILE="${HEADROOM_DEFAULT_PROFILE:-visualval-lmstudio}"

# hr-<short>-<action>, e.g.
#   hr-lms-restart  ==  headroom install restart --profile visualval-lmstudio
() {
  local short action
  for short in ${(k)HEADROOM_PROFILE_ALIASES}; do
    for action in start stop restart status; do
      alias "hr-${short}-${action}=headroom install ${action} --profile ${HEADROOM_PROFILE_ALIASES[$short]}"
    done
    alias "hr-${short}-health=headroom-deploy health ${short}"
    alias "hr-${short}-logs=headroom-deploy logs ${short}"
  done
}
