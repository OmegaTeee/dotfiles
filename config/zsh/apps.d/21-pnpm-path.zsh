# pnpm PATH.

# `if` (not `[[ ]] &&`) so a missing dir does not make the module "fail".
if [[ -d "$PNPM_HOME/bin" ]]; then
  path=("$PNPM_HOME/bin" $path)
fi
