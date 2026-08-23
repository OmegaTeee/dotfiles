# Re-prepend pnpm shims after mise activation.

[[ -d "$PNPM_HOME/bin" ]] &&
  path=("$PNPM_HOME/bin" $path)
