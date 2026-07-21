# Autoload functions without parsing their bodies during startup.

typeset -gU fpath FPATH
fpath=("${ZSH_CONFIG_HOME}/functions" $fpath)

local function_file function_name
for function_file in "${ZSH_CONFIG_HOME}"/functions/*(N-.); do
  function_name="${function_file:t}"
  autoload -Uz "$function_name"
done

unset function_file function_name
