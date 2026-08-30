# Home configuration tree

`home/` mirrors selected paths below the real home directory. It contains only portable, non-secret, human-maintained configuration.

## Add an application

1. Confirm the application's documented configuration path.
2. Copy only the settings file or small configuration directory into the matching path below `home/`.
3. Remove credentials, caches, logs, databases, downloaded models, and generated state.
4. Link that one path with the helper.

For example, a configuration stored at `~/.config/example-app/config.toml` belongs at `home/.config/example-app/config.toml`:

```zsh
scripts/link-home-path.zsh .config/example-app/config.toml
```

The helper moves an existing live path to a timestamped backup before creating the symbolic link. It refuses broad roots such as `.config`, `.local`, `.colima`, and `.ssh`.

## What belongs here

- `home/.config/<app>/`: XDG-style application configuration.
- `home/.<app>/`: legacy application configuration when the application requires it.
- `home/.local/share/<app>/`: only a small, portable setting file when the application stores configuration there.

Do not add secrets, credential stores, package caches, extension directories, application databases, logs, Docker contexts, or generated runtime state. Keep those at their application-managed live paths.

## Current managed paths

### Colima (Docker VM)

- `.colima/linux-vm/colima.yaml`: non-secret Colima VM settings, including the `~/code` mount.
- `Library/LaunchAgents/com.colima.plist`: per-user Colima daemon service definition.

Link with: `scripts/link-home-path.zsh .colima/linux-vm/colima.yaml` and `scripts/link-home-path.zsh Library/LaunchAgents/com.colima.plist`

### Headroom (Context Compression Proxy)

- `.headroom/default/.claude/settings.local.json`: Claude Code settings for Headroom execution context.
- `.headroom/default/.codex/config.toml`: Codex configuration for Headroom execution context.
- `.headroom/default/.codex/hooks.json`: Codex hooks configuration for Headroom execution context.
- `Library/LaunchAgents/com.headroom.default.plist`: per-user Headroom proxy service definition.

Generated state (databases, logs, deployment artifacts, client contexts) remains application-managed at:
- `~/.headroom/ccr_store.db*` — compression cache
- `~/.headroom/logs/` — proxy logs
- `~/.headroom/deploy/` — deployment state
- `~/.headroom/clients/` — client sessions

Link with:
```zsh
scripts/link-home-path.zsh .headroom/default/.claude/settings.local.json
scripts/link-home-path.zsh .headroom/default/.codex/config.toml
scripts/link-home-path.zsh .headroom/default/.codex/hooks.json
scripts/link-home-path.zsh Library/LaunchAgents/com.headroom.default.plist
```

### Serena (Code Intelligence & Semantic Tools)

Project-level configuration is tracked in `.serena/`:
- `project.yml`: Language server configuration, workspace folders, ignore patterns, modes.
- `memories/`: Code context and conventions for this project.

Generated state remains application-managed at:
- `~/.serena/cache/` — language server caches
- `~/.serena/logs/` — operation logs
- `~/.serena/hook_data/` — hook execution data
- `~/.serena/language_servers/` — LSP runtime state
- `~/.serena/contexts/` — cached symbol contexts

No symlinking required; Serena loads `project.yml` directly from the project root.

### RTK (Rust Token Killer)

RTK is configured via Claude Code hooks in `~/.claude/settings.json` and requires no separate configuration file. Token optimization works transparently through bash command interception.

No symlinking required.
