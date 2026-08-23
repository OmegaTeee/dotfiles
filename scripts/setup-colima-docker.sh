#!/usr/bin/env bash
set -euo pipefail

timestamp="${EPOCHSECONDS:-$(date +%s)}"
docker_config_dir="$HOME/.docker"
docker_config_file="$docker_config_dir/config.json"
cli_plugins_dir="$docker_config_dir/cli-plugins"

backup_if_present() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mv "$target" "${target}.backup.${timestamp}"
  fi
}

require_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Please install it from https://brew.sh/"
    exit 1
  fi
}

install_brew_packages() {
  echo "Installing Docker, docker-credential-helper, docker-compose, docker-buildx, and Colima..."
  brew install docker docker-credential-helper docker-compose docker-buildx colima
}

write_docker_config() {
  echo "Configuring $docker_config_file..."
  mkdir -p "$docker_config_dir"
  backup_if_present "$docker_config_file"
  cat >"$docker_config_file" <<'EOL'
{
  "auths": {},
  "credsStore": "osxkeychain",
  "currentContext": "colima"
}
EOL
}

link_cli_plugins() {
  echo "Creating Docker CLI plugin links..."
  mkdir -p "$cli_plugins_dir"
  ln -sfn "$(brew --prefix docker-compose)/bin/docker-compose" "$cli_plugins_dir/docker-compose"
  ln -sfn "$(brew --prefix docker-buildx)/bin/docker-buildx" "$cli_plugins_dir/docker-buildx"
}

verify_install() {
  echo "Checking docker compose command..."
  docker compose version
}

require_brew
install_brew_packages
write_docker_config
link_cli_plugins
verify_install

echo "Setup complete. Docker and Colima are ready to use without Docker Desktop."
