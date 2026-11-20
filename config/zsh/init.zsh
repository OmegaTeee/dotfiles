# ~/config/zsh/init.zsh
#
# Framework entry point:
# - automatic module discovery
# - incremental adjacent .zwc compilation
# - ordered core, app, and plugin loading

emulate -L zsh
setopt extended_glob

typeset -ga ZSH_LOADED_MODULES=()
typeset -ga ZSH_COMPILED_MODULES=()
typeset -ga ZSH_FAILED_MODULES=()
typeset -gA ZSH_PLUGIN_STATUS=()

typeset -g ZSH_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

mkdir -p "$ZSH_CACHE_HOME"

# Remember which config folder this shell loaded. sync-home.zsh installs a
# brand-new folder (new inode), so zsh-doctor can tell when this shell is
# running an older copy of the config. mtimes can't: the sync preserves them.
typeset -g ZSH_CONFIG_INODE=""
if zmodload -F zsh/stat b:zstat 2>/dev/null; then
  typeset -ga _zsh_config_stat=()
  zstat -A _zsh_config_stat +inode -- "$ZSH_CONFIG_HOME" 2>/dev/null &&
    ZSH_CONFIG_INODE=${_zsh_config_stat[1]}
  unset _zsh_config_stat
fi

# Compile a source file when its adjacent bytecode file is missing or stale.
#
# Zsh automatically selects:
#
#   module.zsh.zwc
#
# when this function sources:
#
#   module.zsh
#
# provided that the compiled file is valid and newer than the source.
_zsh_source_module() {
  emulate -L zsh
  setopt local_options no_aliases

  local source_file=$1
  local compiled_file="${source_file}.zwc"
  local relative="${source_file#$ZSH_CONFIG_HOME/}"

  [[ -r $source_file ]] || return 0

  if [[ ! -s $compiled_file || $source_file -nt $compiled_file ]]; then
    rm -f -- "$compiled_file"

    if zcompile -R "$compiled_file" "$source_file" 2>/dev/null; then
      ZSH_COMPILED_MODULES+=("$relative")
    else
      ZSH_FAILED_MODULES+=("$relative")
      rm -f -- "$compiled_file"
    fi
  fi

  # Source the text filename. Zsh automatically uses the adjacent, newer
  # compiled file when it is valid.
  source "$source_file" || {
    ZSH_FAILED_MODULES+=("$relative")
    return 1
  }

  ZSH_LOADED_MODULES+=("$relative")
}

# Load files matching a pattern in lexical order.
_zsh_discover_and_load() {
  emulate -L zsh
  setopt local_options null_glob

  local pattern=$1
  local file

  for file in ${~pattern}(N); do
    _zsh_source_module "$file"
  done
}

# Numeric prefixes determine order within each directory.
_zsh_discover_and_load "${ZSH_CONFIG_HOME}/core/*.zsh"
_zsh_discover_and_load "${ZSH_CONFIG_HOME}/apps.d/*.zsh"
_zsh_discover_and_load "${ZSH_CONFIG_HOME}/plugins.d/*.plugin.zsh"

unset -f _zsh_discover_and_load
