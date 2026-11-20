# Suggested commands

## Edit -> test -> apply
```zsh
colima-test                          # or first time: zsh scripts/test-in-colima.zsh
./scripts/sync-home.zsh --dry-run    # preview (-n)
./scripts/sync-home.zsh              # apply; backs up replaced files
exec zsh && zsh-doctor
```
- `colima-test` streams the working tree (incl. uncommitted) into a throwaway container; needs `colima start -p linux-vm` first. Asserts: 2nd sync is a no-op, `zsh -n` passes, 0 failed modules, no recompiles on 2nd start, sandbox $HOME holds only `.zshenv .config .local .cache .colima`.
- `sync-home.zsh --home DIR` syncs into an arbitrary home (used by harness).

## Diagnostics
- `zsh-doctor` (modules/PATH/stale-config), `zsh-profile` (startup profiling), `zsh-recompile`, `zsh-rebuild-completions`, `node-doctor` (read-only mise/node/npm/pnpm resolution).

## Shortcuts
- Headroom: `hr-{lms,init}-{start,stop,restart,status,health,logs}`, `headroom-deploy <action> [profile] [-v]`.
- Colima: `colima-start|stop|status`, `colima-setup` (runs `scripts/setup-colima-docker.sh`).
- Secrets: `with_secrets {ai|github|services} <cmd>`; add key: `security add-generic-password -a "$USER" -s NAME -w`.
- AI clients with secrets: `claude-local`, `codex-local`, `goose-local`, `cherry-local`.

## Darwin notes
- BSD userland: `sed -i ''` (not `sed -i`), `stat -f` (not `-c`); in zsh prefer `zstat` from `zsh/stat`.
