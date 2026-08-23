# PATH FPATH setup.

typeset -gU path PATH
typeset -gU fpath FPATH

typeset -a candidate_paths=(
 "$HOME/.local/bin"
 "$HOME/.lmstudio/bin"
 "$HOME/.lmstudio/llmster/current"
 "/opt/homebrew/opt/python@3/bin"
 "/Applications/Comet.app/Contents/MacOS"
 "$HOME/Applications/Comet.app/Contents/MacOS"
 "$HOME/.bun/bin"
 "$HOME/.venv-vllm-metal/bin"
 "$HOME/.cargo/bin"
 "$HOME/.dotnet/tools"
 "$HOME/.mtplx/bin/mtplx"
)

local directory
for directory in $candidate_paths; do
 [[ -d $directory ]] && path=("$directory" $path)
done

unset candidate_paths directory

# Homebrew provides mise, while mise owns the active Node runtime. Keep
# Homebrew after user tool directories so user shims remain ahead of it.
if [[ -x /opt/homebrew/bin/brew ]]; then
 export HOMEBREW_PREFIX="/opt/homebrew"
 export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
 export HOMEBREW_REPOSITORY="/opt/homebrew"
 path=($path /opt/homebrew/bin /opt/homebrew/sbin)
fi
