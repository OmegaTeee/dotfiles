# PATH FPATH setup.

typeset -gU path PATH
typeset -gU fpath FPATH

typeset -a candidate_paths=(
 "/Applications/Comet.app/Contents/MacOS"
 "$HOME/Applications/Comet.app/Contents/MacOS"
 "$HOME/.local/bin"
 "$HOME/.bun/bin"
 "$HOME/.cargo/bin"
 "$HOME/.dotnet/tools"
 "$HOME/.lmstudio/bin"
 "$HOME/.opencode/bin"
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
