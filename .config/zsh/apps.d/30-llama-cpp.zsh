# llama.cpp integration.

export LLAMA_CPP_HOME="${HOME}/llama.cpp"
export LLAMA_CACHE="${HOME}/.cache/llama.cpp"

export LLAMA_ARG_FLASH_ATTN=1
export LLAMA_ARG_CACHE_TYPE_K=q8_0
export LLAMA_ARG_CACHE_TYPE_V=q8_0
export LLAMA_ARG_THREADS=10
export LLAMA_ARG_THREADS_BATCH=10
export GGML_METAL_NO_RESIDENCY=1

[[ -d "$LLAMA_CPP_HOME/build/bin" ]] &&
  path=("$LLAMA_CPP_HOME/build/bin" $path)

alias llama-server="${LLAMA_CPP_HOME}/build/bin/llama-server"
alias llama-cli="${LLAMA_CPP_HOME}/build/bin/llama-cli"
alias llama-bench="${LLAMA_CPP_HOME}/build/bin/llama-bench"
alias llama-simple="${LLAMA_CPP_HOME}/build/bin/llama-simple"
