# Shared non-secret environment.

export MAGICK_HOME="/opt/homebrew"
export AUTOTRACE="/opt/homebrew/bin/autotrace"

export UV_TOOL_DIR="${HOME}/uv-tools"
export UV_CACHE_DIR="${HOME}/uv-cache"

export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.8

export PH_ROUTER_URL="http://127.0.0.1:9090"
export PH_DAEMON_MODEL="qwopus3-5-9b-coder-flash-i1"

export HF_HUB_CACHE="${HOME}/.cache/huggingface/hub"
export PROJECT_FOLDER="${HOME}/workspaces"

export RAPID_MLX_TELEMETRY=0
export HF_HUB_OFFLINE=0
