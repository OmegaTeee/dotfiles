# npm PATH.

# `if` (not `[[ ]] &&`) so a missing dir does not make the module "fail".
if [[ -d "$NPM_CONFIG_PREFIX/bin" ]]; then
  path=("$NPM_CONFIG_PREFIX/bin" $path)
fi
