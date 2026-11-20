# Conventions

## Placement
- Env vars -> `core/10-environment.zsh`; PATH -> `core/20-path.zsh` (keep zsh `typeset -U path` uniqueness); mise activation -> `core/25-mise.zsh`.
- New tool behavior -> NEW numbered module `apps.d/NN-tool.zsh`; don't grow an unrelated module. Plugins -> `plugins.d/NN-name.plugin.zsh` (suffix required).
- Bigger logic -> autoloaded function file `config/zsh/functions/<name>` (no extension).
- Headroom profile shorthands -> `HEADROOM_PROFILE_ALIASES` in `apps.d/20-headroom.zsh`.
- Numeric prefixes define load order.

## Style
- Autoload function files start with `#autoload` then `emulate -L zsh` (plus `setopt` locals as needed).
- Internal helpers prefixed `_zsh_` / leading underscore.
- `.editorconfig`: 2-space indent, LF, final newline for sh/zsh/yml.
- Comments explain WHY for non-obvious workarounds; no restating code.
- `.zwc` files are generated — never edit or commit.
- Repo intentionally has no dot-named dirs (`config/`, `local/`, `macos/`, `home/zshenv`) so files show in Finder/IDE.
