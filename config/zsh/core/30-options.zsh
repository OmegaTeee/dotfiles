# Interactive behavior.

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Keep history in XDG state, NOT in $ZDOTDIR: sync-home.zsh replaces the
# whole ~/.config/zsh tree, which would otherwise move history into a backup.
typeset -g ZSH_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
[[ -d $ZSH_STATE_HOME ]] || mkdir -p "$ZSH_STATE_HOME"
HISTFILE="${ZSH_STATE_HOME}/history"
# One-time carry-over of the pre-XDG history file.
[[ ! -e $HISTFILE && -r $HOME/.zsh_history ]] && cp "$HOME/.zsh_history" "$HISTFILE"
HISTSIZE=50000
SAVEHIST=50000
