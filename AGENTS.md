# AGENTS.md

## Project scope

This repository contains a small, plain-Zsh configuration framework for the
local macOS environment. The tracked tree is the source of truth for shell
configuration; the active installation currently lives at `~/.config/zsh/`.

## Repository conventions

- Numeric filename prefixes define load order.
- `core/` contains shared environment, PATH, options, secrets, completions,
  integrations, and prompt setup.
- `apps.d/` contains application-specific environment and hooks.
- `plugins.d/` contains optional plugin modules.
- `functions/` contains autoloaded commands.
- Adjacent `.zwc` files are generated Zsh bytecode. Do not edit or commit them.
- Preserve unrelated working-tree changes and inspect `git status --short`
  before making focused edits.

## Editing guidance

- Keep environment variables in `.config/zsh/core/10-environment.zsh`.
- Keep PATH changes in `.config/zsh/core/20-path.zsh` and preserve unique Zsh
  `path`/`PATH` handling.
- Keep runtime-manager activation in `.config/zsh/core/25-mise.zsh`.
- Keep Node and package-manager diagnostics in the autoloaded
  `.config/zsh/functions/node-doctor` function.
- Use a new numbered module for new application or integration behavior rather
  than expanding an unrelated module.
- Explain why non-obvious workarounds exist; avoid comments that only restate
  the code.
- The active `~/.config/zsh/` tree is currently copy-installed. Do not assume
  a repository edit changes the live shell until it is synchronized and
  verified.

## Secrets and generated state

- Never commit API keys, npm tokens, passwords, or other credentials.
- `core/40-secrets.zsh` provides lazy macOS Keychain access through
  `with_secrets` and `secret_export`.
- Keep caches, logs, global package directories, and generated launchers out
  of the repository.
- Homebrew provides the `mise` executable; mise manages the active Node
  runtime. pnpm owns global Node CLI packages through `PNPM_HOME`, while npm
  retains its compatibility/publishing prefix.
- npm configuration migration is intentionally deferred. A future tracked
  npm config must contain only non-secret settings; publishing credentials
  belong in Keychain or an equivalent secret mechanism.
- The current global mise config at `~/.config/mise/config.toml` is also
  intentionally outside the repository until the later symlink/config migration.

## Validation

Run these checks after shell changes:

```zsh
zsh -n ~/.zshrc ~/.config/zsh/init.zsh \
  ~/.config/zsh/core/*.zsh \
  ~/.config/zsh/apps.d/*.zsh \
  ~/.config/zsh/plugins.d/*.plugin.zsh
zsh-doctor
git diff --check
```

For package-manager changes, verify the effective commands and prefixes in a
fresh shell. Project package-manager selection follows the repository lockfile;
do not introduce a second lockfile to solve a shell configuration problem.

When running shell commands in this workspace, use the local `rtk` command
prefix where available, as documented by the workspace instructions.
