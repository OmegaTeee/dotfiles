#!/bin/zsh
# Copy repo-managed config into an XDG-style home.
#
#   scripts/sync-home.zsh [--dry-run] [--home DIR]
#
# Mappings (repo -> target):
#   home/zshenv                       -> ~/.zshenv
#   config/zsh/                       -> ~/.config/zsh/          (whole tree)
#   config/colima/<p>/colima.yaml     -> ~/.colima/<p>/colima.yaml (only if profile exists)
#   local/bin/*                       -> ~/.local/bin/           (files only)
#   macos/LaunchAgents/*.plist        -> ~/Library/LaunchAgents/ (macOS only)
#
# Unchanged targets are skipped. Anything replaced is first moved to
#   ~/.local/state/dotfiles/backups/<epoch>/<path relative to home>
#
# --home lets the Colima test harness sync into a throwaway directory.

set -euo pipefail
emulate -L zsh
setopt null_glob
zmodload zsh/datetime

script_dir=${0:A:h}
repo_root=${script_dir:h}
target_home=$HOME
dry_run=0

usage() {
  print -r -- "Usage: ${0:t} [--dry-run|-n] [--home DIR]"
}

while (( $# )); do
  case $1 in
    -n|--dry-run) dry_run=1; shift ;;
    --home)       target_home=${2:?--home needs a directory}; shift 2 ;;
    --home=*)     target_home=${1#--home=}; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            usage >&2; exit 2 ;;
  esac
done

[[ -d $target_home ]] || { print -u2 -- "Target home does not exist: $target_home"; exit 1 }
target_home=${target_home:A}
[[ $target_home == ${HOME:A} ]] && real_home=1 || real_home=0

stamp=$EPOCHSECONDS
backup_root="$target_home/.local/state/dotfiles/backups/$stamp"
typeset -i n_changed=0 n_same=0 n_backed_up=0
typeset -a changed_agents

# Pretty path: replace the target home with ~.
pp() { print -r -- "~${1#$target_home}" }

log() {
  local tag=$1; shift
  if (( dry_run )) && [[ $tag == (new|update|retire) ]]; then
    tag="would-$tag"
  fi
  printf '  %-14s %s\n' "$tag" "$*"
}

# Move an existing target into the backup tree.
backup() {
  local target=$1
  [[ -e $target || -L $target ]] || return 0
  local dest="$backup_root/${target#$target_home/}"
  (( dry_run )) || { mkdir -p "${dest:h}"; mv "$target" "$dest" }
  (( n_backed_up++ )) || true
}

# Sets REPLY to "changed" or "same".
replace_file() {
  local src=$1 dst=$2
  # cmp follows symlinks: a link to identical content (e.g. a LaunchAgent
  # linked to a system-wide copy) is left alone instead of being replaced.
  if [[ -f $dst ]] && cmp -s "$src" "$dst"; then
    if [[ -L $dst ]]; then
      log same "$(pp "$dst") (symlink -> $(readlink "$dst"))"
    else
      log same "$(pp "$dst")"
    fi
    (( n_same++ )) || true; REPLY=same; return 0
  fi
  local verb=new
  [[ -e $dst || -L $dst ]] && verb=update
  log $verb "$(pp "$dst")"
  backup "$dst"
  if (( ! dry_run )); then
    mkdir -p "${dst:h}"
    cp -p "$src" "$dst"
  fi
  (( n_changed++ )) || true
  REPLY=changed
}

# List files and symlinks (not followed), ignoring generated noise.
tree_entries() {
  ( cd "$1" && find . \( -type f -o -type l \) ! -name '*.zwc' ! -name '.DS_Store' | LC_ALL=C sort )
}

# True when both trees hold the same entries with the same content. Symlinks
# are compared by target, so a link that dangles on this OS (e.g. a Homebrew
# path on Linux) still counts as unchanged.
tree_same() {
  local src=$1 dst=$2 rel
  local src_list dst_list
  src_list=$(tree_entries "$src") || return 1
  dst_list=$(tree_entries "$dst") || return 1
  [[ $src_list == $dst_list ]] || return 1
  for rel in ${(f)src_list}; do
    if [[ -L $src/$rel ]]; then
      [[ -L $dst/$rel && $(readlink "$src/$rel") == $(readlink "$dst/$rel") ]] || return 1
    else
      cmp -s "$src/$rel" "$dst/$rel" || return 1
    fi
  done
}

replace_tree() {
  local src=$1 dst=$2
  if [[ -d $dst && ! -L $dst ]] && tree_same "$src" "$dst"; then
    log same "$(pp "$dst")/"; (( n_same++ )) || true; return 0
  fi
  local verb=new
  [[ -e $dst || -L $dst ]] && verb=update
  log $verb "$(pp "$dst")/"
  backup "$dst"
  if (( ! dry_run )); then
    mkdir -p "${dst:h}"
    cp -Rp "$src" "$dst"
    find "$dst" \( -name '*.zwc' -o -name '.DS_Store' \) -delete
  fi
  (( n_changed++ )) || true
}

print -r -- "Syncing $repo_root -> $target_home$( (( dry_run )) && print ' (dry run)')"

# 1. Zsh bootstrap + ZDOTDIR tree
replace_file "$repo_root/home/zshenv" "$target_home/.zshenv"
replace_tree "$repo_root/config/zsh"  "$target_home/.config/zsh"

# With ZDOTDIR set, ~/.zshrc and ~/.zprofile are never read. Retire them so
# nobody edits a dead file (tools like headroom append blocks there).
for stale in "$target_home/.zshrc" "$target_home/.zprofile"; do
  if [[ -e $stale || -L $stale ]]; then
    log retire "$(pp "$stale") (dead under ZDOTDIR)"
    backup "$stale"
  fi
done

# 2. Colima: config file only. VM disks/sockets stay in the Colima home.
colima_home=${COLIMA_HOME:-$target_home/.colima}
(( real_home )) || colima_home=$target_home/.colima
for src in "$repo_root"/config/colima/*/colima.yaml; do
  profile=${src:h:t}
  if [[ -d $colima_home/$profile ]]; then
    replace_file "$src" "$colima_home/$profile/colima.yaml"
    [[ $REPLY == changed ]] && log note "restart to apply: colima stop -p $profile && colima start -p $profile"
  else
    log skip "colima profile '$profile' (no $(pp "$colima_home/$profile"))"
  fi
done

# 3. ~/.local/bin: individual files, never the whole folder
for src in "$repo_root"/local/bin/*(.); do
  replace_file "$src" "$target_home/.local/bin/${src:t}"
done

# 4. macOS LaunchAgents
if [[ $OSTYPE == darwin* ]]; then
  for src in "$repo_root"/macos/LaunchAgents/*.plist; do
    replace_file "$src" "$target_home/Library/LaunchAgents/${src:t}"
    [[ $REPLY == changed ]] && changed_agents+=("$target_home/Library/LaunchAgents/${src:t}")
  done
  if (( real_home && ! dry_run )); then
    for plist in $changed_agents; do
      label=${plist:t:r}
      launchctl bootout "gui/$UID/$label" 2>/dev/null || true
      launchctl bootstrap "gui/$UID" "$plist" && log loaded "$label"
    done
  fi
else
  log skip "LaunchAgents (not macOS)"
fi

print -r -- ""
print -r -- "changed: $n_changed  unchanged: $n_same  backed up: $n_backed_up"
if (( n_backed_up && ! dry_run )); then
  print -r -- "backups: $(pp "$backup_root")"
fi
