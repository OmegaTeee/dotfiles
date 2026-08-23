#!/bin/zsh

set -euo pipefail
emulate -L zsh

script_dir=${0:A:h}
repo_root=${script_dir:h}
stamp=${EPOCHSECONDS:-$(date +%s)}

backup_path() {
  local target=$1
  print -r -- "${target}.backup.${stamp}"
}

replace_file() {
  local source_file=$1
  local target_file=$2
  if [[ -e $target_file || -L $target_file ]]; then
    mv "$target_file" "$(backup_path "$target_file")"
  fi
  cp "$source_file" "$target_file"
}

replace_tree() {
  local source_dir=$1
  local target_dir=$2
  if [[ -e $target_dir || -L $target_dir ]]; then
    mv "$target_dir" "$(backup_path "$target_dir")"
  fi
  mkdir -p "${target_dir:h}"
  cp -R "$source_dir" "$target_dir"
}

replace_file "$repo_root/.zshrc" "$HOME/.zshrc"
replace_file "$repo_root/.zprofile" "$HOME/.zprofile"
replace_tree "$repo_root/.config/zsh" "$HOME/.config/zsh"

print -- "Synced Zsh home config from:"
print -- "  $repo_root"
print -- "Backups, if created, were written next to the replaced files."
