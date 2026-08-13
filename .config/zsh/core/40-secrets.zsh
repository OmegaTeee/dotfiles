# Lazy macOS Keychain access.

keychain_secret() {
  emulate -L zsh

  local service=$1
  [[ -n $service ]] || return 2
  (( $+commands[security] )) || return 127

  command security find-generic-password \
    -a "$USER" \
    -s "$service" \
    -w 2>/dev/null
}

secret_export() {
  emulate -L zsh

  local variable=$1
  local service=$2
  local value

  [[ -n $variable && -n $service ]] || return 2

  value="$(keychain_secret "$service")" || {
    print -u2 -- "Secret not found in Keychain: ${service}"
    return 1
  }

  export "${variable}=${value}"
}

secrets_load_github() {
  secret_export GITHUB_API_KEY GITHUB_API_KEY || return
  secret_export GITHUB_PAT GITHUB_PAT || return
  secret_export CONTEXT7_API_KEY || return
  export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PAT"
  export GITHUB_PAT_TOKEN="$GITHUB_PAT"
  export CONTEXT7_API_KEY
}

secrets_load_ai() {
  secret_export PH_API_TOKEN PH_API_TOKEN || return
  secret_export LM_API_TOKEN LM_API_TOKEN || true
  secret_export HUGGINGFACE_API_KEY HUGGINGFACE_API_KEY || true
  secret_export OPENROUTER_API_KEY OPENROUTER_KEY || true
  secret_export LM_STUDIO_API_KEY LMSTUDIO_API_KEY || true
  secret_export OLLAMA_API_KEY OLLAMA_API_KEY || true
  secret_export GROQ_API_KEY GROQ_API_KEY || true
  secret_export MISTRAL_API_KEY MISTRAL_API_KEY || true
  secret_export GEMINI_API_KEY GEMINI_API_KEY || true

  export OPENAI_API_KEY="$PH_API_TOKEN"
  export HF_TOKEN="${HUGGINGFACE_API_KEY:-}"
  export LMSTUDIO_TOKEN="${LM_STUDIO_API_KEY:-}"
}

secrets_load_services() {
  secret_export OPENCLAW_GATEWAY_TOKEN OPENCLAW_GATEWAY_TOKEN || true
  secret_export DISCORD_BOT_API_KEY DISCORD_BOT_API_KEY || true
  secret_export DISCORD_BOT_TOKEN DISCORD_BOT_TOKEN || true
  secret_export DISCORD_CLIENT_ID DISCORD_CLIENT_ID || true
  secret_export PARALLEL_API_KEY PARALLEL_API_KEY || true
  secret_export CLOUDFLARE_AUTHTOKEN CLOUDFLARE_AUTHTOKEN || true
  secret_export PUBLIC_CLOUDINARY_API_KEY PUBLIC_CLOUDINARY_API_KEY || true
  secret_export CLOUDINARY_API_SECRET CLOUDINARY_API_SECRET || true
  secret_export NETLIFY_AUTH_TOKEN NETLIFY_AUTH_TOKEN || true
}

secrets_load_all() {
  secrets_load_github || true
  secrets_load_ai || true
  secrets_load_services || true
}

with_secrets() {
  emulate -L zsh

  local profile=$1
  shift || return 2

  (( $# )) || {
    print -u2 -- "Usage: with_secrets <github|ai|services|all> command [args...]"
    return 2
  }

  (
    case $profile in
      github)   secrets_load_github ;;
      ai)       secrets_load_ai ;;
      services) secrets_load_services ;;
      all)      secrets_load_all ;;
    *)
      print -u2 -- "Unknown secret profile: ${profile}"
      return 2
      ;;
    esac || return

    command "$@"
  )
}
