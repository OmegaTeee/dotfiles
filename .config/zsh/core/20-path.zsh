# PATH and FPATH setup.

typeset -gU path PATH
typeset -gU fpath FPATH

typeset -a candidate_paths=(
  "$HOME/.local/bin"
  "$HOME/.lmstudio/bin"
  "$HOME/.lmstudio/llmster/current"
  "/opt/homebrew/opt/python@3/bin"
  "/Applications/Comet.app/Contents/MacOS"
  "$HOME/Applications/Comet.app/Contents/MacOS"
  "$PNPM_HOME/bin"
  "$HOME/.npm-global/bin"
  "$HOME/.bun/bin"
  "$HOME/.venv-vllm-metal/bin"
  "$HOME/.cargo/bin"
  "$HOME/.dotnet/tools"
)

local directory
for directory in $candidate_paths; do
  [[ -d $directory ]] && path=("$directory" $path)
done

unset candidate_paths directory

# Homebrew owns the Node runtime. Add it after user tool directories have been
# collected so it remains first in the final PATH and cannot be shadowed by a
# second Node installation in ~/.local/bin.
if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
fi
