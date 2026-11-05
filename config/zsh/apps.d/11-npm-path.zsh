# npm PATH.

[[ -d "$NPM_CONFIG_PREFIX/bin" ]] &&
  path=("$NPM_CONFIG_PREFIX/bin" $path)
