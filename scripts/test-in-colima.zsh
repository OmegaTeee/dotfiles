#!/bin/zsh
# Test the dotfiles in a throwaway Linux container on a Colima VM before
# touching the real $HOME.
#
#   scripts/test-in-colima.zsh
#
# The repo is streamed into the container as a tar archive (no bind mount,
# so it works even when the VM has no host folders mounted). The container
# syncs into its own HOME (/tmp/home) and checks syntax, a clean interactive
# startup, idempotent re-sync and a tidy XDG home layout. Nothing on the VM
# or your Mac home is written; the container is removed afterwards.
#
# Env overrides:
#   COLIMA_TEST_CONTEXT  docker context   (default: colima-linux-vm)
#   COLIMA_TEST_IMAGE    container image  (default: ubuntu:24.04)
#
# macOS-only parts (Keychain, launchctl, Homebrew) are skipped on Linux, so
# this covers the shell framework and the layout, not macOS integrations.

set -euo pipefail
emulate -L zsh

repo_root=${0:A:h:h}
context=${COLIMA_TEST_CONTEXT:-colima-linux-vm}
image=${COLIMA_TEST_IMAGE:-ubuntu:24.04}

(( $+commands[docker] )) || { print -u2 -- "docker CLI not found"; exit 127 }

if ! docker --context "$context" info >/dev/null 2>&1; then
  print -u2 -- "Docker context '$context' is not reachable."
  print -u2 -- "Start it with: colima start -p ${${context#colima-}:-default}"
  exit 1
fi

print -r -- "Testing $repo_root in $image on context $context"

# Talk to the context's socket with an empty, throwaway Docker config. The
# image is public, and this keeps the macOS credential helper (Keychain
# prompt) out of the pull.
endpoint=$(docker context inspect "$context" --format '{{.Endpoints.docker.Host}}')
export DOCKER_CONFIG=$(mktemp -d "${TMPDIR:-/tmp}/colima-test-docker.XXXXXX")
trap 'rm -rf "$DOCKER_CONFIG"' EXIT

container_script=$(cat <<'CONTAINER'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
step() { printf '\n== %s\n' "$*"; }

step "unpack repo"
mkdir -p /repo && tar --no-same-owner -xf - -C /repo && chmod -R a-w /repo
ls /repo

step "install zsh"
apt-get update -qq >/dev/null
apt-get install -y -qq zsh >/dev/null

export HOME=/tmp/home USER=tester
mkdir -p "$HOME/.colima/linux-vm"     # simulate an existing Colima profile

step "sync (first run)"
zsh /repo/scripts/sync-home.zsh --home "$HOME"

step "sync (second run must change nothing)"
out=$(zsh /repo/scripts/sync-home.zsh --home "$HOME")
echo "$out"
grep -q "changed: 0" <<<"$out"

step "syntax"
cfg=$HOME/.config/zsh
zsh -n "$HOME/.zshenv" "$cfg/.zshrc" "$cfg/.zprofile" "$cfg/init.zsh" \
  "$cfg"/core/*.zsh "$cfg"/apps.d/*.zsh "$cfg"/plugins.d/*.plugin.zsh
echo "ok"

step "interactive login shell"
zsh -lic '
  print -r -- "ZDOTDIR=$ZDOTDIR"
  print -r -- "HISTFILE=$HISTFILE"
  print -r -- "modules loaded=${#ZSH_LOADED_MODULES} failed=${#ZSH_FAILED_MODULES}"
  (( ${#ZSH_FAILED_MODULES} == 0 )) || { print -l -- "FAILED:" $ZSH_FAILED_MODULES; exit 1 }
  [[ $ZDOTDIR  == $HOME/.config/zsh ]]          || { print "bad ZDOTDIR"; exit 1 }
  [[ $HISTFILE == $HOME/.local/state/zsh/history ]] || { print "bad HISTFILE"; exit 1 }
  whence -w zsh-doctor headroom-deploy colima-test
  alias hr-lms-restart hr-init-status
'

step "zsh-doctor (informational)"
zsh -lic 'zsh-doctor' || echo "(zsh-doctor reported warnings; expected on Linux without Homebrew)"

step "second shell start reuses compiled modules"
zsh -lic 'print -r -- "compiled this start: ${#ZSH_COMPILED_MODULES}"; (( ${#ZSH_COMPILED_MODULES} == 0 ))'

step "home layout"
ls -A "$HOME"
extra=$(ls -A "$HOME" | grep -vxE '\.zshenv|\.config|\.local|\.cache|\.colima' || true)
if [[ -n $extra ]]; then
  echo "unexpected entries in HOME:"; echo "$extra"; exit 1
fi

printf '\nPASS\n'
CONTAINER
)

# Ship the working tree (uncommitted changes included) minus state/secrets.
COPYFILE_DISABLE=1 tar -C "$repo_root" -cf - \
    --exclude .git --exclude node_modules --exclude .tokensave \
    --exclude home/headroom --exclude .history --exclude .DS_Store \
    --exclude '*.zwc' . |
  docker -H "$endpoint" run --rm -i -e TERM=xterm-256color \
    "$image" bash -c "$container_script"
