#!/bin/zsh
# Static checks for the repo: zsh syntax on every zsh file, shellcheck on the
# bash scripts. CI runs this too (.github/workflows/ci.yml), so local and CI
# results match.
#
#   zsh scripts/lint.zsh
#
# core/65-completions-ast-grep.sh is a zsh completion despite its extension,
# so it gets `zsh -n`, not shellcheck.

set -euo pipefail
emulate -L zsh
setopt null_glob

cd -- ${0:A:h:h}

local -a zsh_files bash_files
zsh_files=(
  home/zshenv
  config/zsh/.zshrc config/zsh/.zprofile config/zsh/init.zsh
  config/zsh/core/*.zsh config/zsh/core/*.sh
  config/zsh/apps.d/*.zsh
  config/zsh/plugins.d/*.plugin.zsh
  config/zsh/functions/*(.)
  scripts/*.zsh
)
bash_files=(scripts/*.sh)

print -r -- "zsh -n: ${#zsh_files} files"
zsh -n -- $zsh_files

if (( ! $+commands[shellcheck] )); then
  print -u2 -- "shellcheck not found (brew install shellcheck)"
  exit 127
fi
print -r -- "shellcheck: ${#bash_files} files"
shellcheck -- $bash_files

print -r -- "lint ok"
