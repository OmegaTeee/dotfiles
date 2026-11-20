# Core

Plain-Zsh framework for macOS, XDG layout, no plugin manager. Repo = STAGING copy; live shell changes only after `scripts/sync-home.zsh`.
Canonical agent guidance is `AGENTS.md` (CLAUDE.md just imports it via `@AGENTS.md`); keep the two from diverging.

## Source map (repo -> installed)
- `home/zshenv` -> `~/.zshenv` (sets XDG_*, ZDOTDIR=~/.config/zsh). Only zsh file allowed in $HOME.
- `config/zsh/` -> `~/.config/zsh/` — WHOLE TREE REPLACED on sync; hand edits in target get moved to backup.
- `config/colima/<profile>/colima.yaml` -> `~/.colima/<profile>/` (only if profile exists; VM disks untouched).
- `local/bin/*` -> `~/.local/bin/`; `macos/LaunchAgents/*.plist` -> `~/Library/LaunchAgents/` (+ launchctl reload).
- `scripts/` (sync + test tools) and `docs/user-manuals/` are not installed.
- New app reading `~/.config/<app>` needs a mapping line in `scripts/sync-home.zsh`.

## Startup chain
`.zshenv` -> `$ZDOTDIR/.zprofile` (login; sources ~/.profile) -> `.zshrc` (p10k instant prompt, timing) -> `init.zsh` loads `core/*.zsh`, `apps.d/*.zsh`, `plugins.d/*.plugin.zsh` in lexical order.
- `init.zsh` recompiles stale adjacent `.zwc`, sources, records into `ZSH_LOADED_MODULES` / `ZSH_COMPILED_MODULES` / `ZSH_FAILED_MODULES`; `zsh-doctor` reports these.
- `ZSH_CONFIG_INODE` detects a shell running a pre-sync config copy (sync makes a new inode; mtimes are preserved so can't be used).

## Invariants
- A module "fails" if its LAST command returns non-zero -> write optional steps as `if [[ ... ]]; then ...; fi`, never `[[ ... ]] && ...` as a final line.
- Secrets: macOS Keychain only, loaded per-command via `with_secrets <group> cmd` (`core/40-secrets.zsh`). Never export tokens from a module; never commit credentials. `~/.headroom` state never enters the repo.
- History lives in `~/.local/state/zsh/history`; sync backups in `~/.local/state/dotfiles/backups/<epoch>/`.
- Serena: project name is `dotfiles` (same as folder and GitHub repo; the old `~/code/dotfiles` clone was retired 2026-11-20). Only the bash LSP is active, so symbol tools work on `.sh` files only, not `.zsh` or extensionless autoload functions.
- `.github/copilot-instructions.md` overstates Serena's zsh coverage; trust `AGENTS.md`.

## Further memories
- Languages, tools, runtime managers: `mem:tech_stack`
- Module placement, naming, autoload function format: `mem:conventions`
- Daily commands (test harness, sync, diagnostics, headroom/colima shortcuts): `mem:suggested_commands`
- Checks required before declaring a change done: `mem:task_completion`
