# Zsh Lite Framework

A small plain-Zsh configuration with:

- automatic module discovery
- incremental `.zwc` compilation
- autoloaded functions
- `plugins.d/`
- application-specific configuration files
- lazy secret and command wrappers
- mise-based Node runtime activation
- `zsh-doctor`
- `node-doctor`

It does not require Oh My Zsh or another plugin manager.

## Layout

```text
~/.config/zsh/
├── init.zsh
├── core/
├── apps.d/
├── plugins.d/
├── functions/
└── cache/
```

## User manuals

Short operating guides are stored under [`docs/`](docs/). Start with the
[secrets quick start](docs/user-manuals/secrets-quick-start.md) for Keychain
entries and environment variables.

Core modules, app modules, and plugin files are discovered automatically in
lexical order. Use numeric prefixes to control ordering.

## Install

```zsh
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
cp .zshrc ~/.zshrc

mkdir -p ~/.config/zsh
cp -R .config/zsh/. ~/.config/zsh/

exec zsh
```

## Commands

```zsh
zsh-doctor
node-doctor
zsh-recompile
zsh-rebuild-completions
restart-zsh

colima-start
colima-stop
colima-status

headroom-codex
headroom-claude
headroom-doctor

codex-local
claude-local
goose-local

prompthub-keys
```

## Add an application

Create a dedicated file:

```text
~/.config/zsh/apps.d/80-my-tool.zsh
```

Use it for lightweight environment variables, PATH entries, aliases, and hook
registration. Put larger command implementations in separate autoload files:

```text
~/.config/zsh/functions/my-tool-command
```

No manual registration is required. Restart Zsh.

## Add a plugin

Drop a file into:

```text
~/.config/zsh/plugins.d/20-navigation.plugin.zsh
```

It will be discovered automatically on the next shell start.

## Compilation

Every discovered module is compiled into:

```text
the adjacent module.zsh.zwc file
```

A module is recompiled only when its source is newer than its adjacent `.zwc`.
This follows Zsh's native compiled-file lookup behavior.
Autoloaded functions are not parsed until first invocation.

Force a rebuild:

```zsh
zsh-recompile
```

## Validate

```zsh
zsh -n ~/.zshrc ~/.config/zsh/init.zsh \
  ~/.config/zsh/core/*.zsh \
  ~/.config/zsh/apps.d/*.zsh \
  ~/.config/zsh/plugins.d/*.plugin.zsh

exec zsh
zsh-doctor
```

## Notes

- `.p10k.zsh` remains separate and is not compiled.
- Secrets remain lazy.
- Homebrew provides `mise`; `mise` owns the active Node runtime.
- pnpm owns global Node CLI packages through `PNPM_HOME`; npm remains the
  compatibility and publishing interface.
- VS Code shell integration is not manually spawned by default.
- `typeset -U` keeps PATH and FPATH unique.
