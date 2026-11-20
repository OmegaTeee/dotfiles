# Copilot instructions

This repo is a plain-Zsh configuration for macOS with an XDG layout. The full agent guide is [`AGENTS.md`](../AGENTS.md); these are the points that matter most when suggesting or reviewing code.

## Key facts

- **The repo is a staging copy.** `scripts/sync-home.zsh` installs it: `config/zsh/` replaces `~/.config/zsh/` as a whole, and `home/zshenv` becomes `~/.zshenv`. Edit files in the repo, never in `~/.config/zsh/`.
- **Almost all code is zsh, not bash.** This includes `core/65-completions-ast-grep.sh`, despite its extension. Don't suggest bash-only syntax, and don't "fix" zsh syntax such as `${(k)array}`, `${0:A:h}` or `*(.)` glob qualifiers into bash. The only bash file is `scripts/setup-colima-docker.sh`.
- **Load order comes from numeric filename prefixes** in `config/zsh/core/`, `apps.d/` and `plugins.d/`. Plugins must end in `.plugin.zsh`.
- **Autoloaded commands** live in `config/zsh/functions/<name>` (no extension) and start with `#autoload`, then `emulate -L zsh`.

## Where changes go

Under `config/zsh/`: environment variables in `core/10-environment.zsh`, PATH in `core/20-path.zsh`, mise in `core/25-mise.zsh`, secret mappings in `core/40-secrets.zsh`. A new tool gets its own numbered `apps.d/NN-tool.zsh` rather than growing an unrelated module.

## Don't

- Don't end a module with `[[ … ]] && …`. A module whose last command returns non-zero is marked as failed. Use `if [[ … ]]; then …; fi`.
- Don't export tokens from a module or hard-code a secret. Secrets load per command with `with_secrets <group> <cmd>` from the macOS Keychain.
- Don't edit or commit `.zwc` files. They're generated.
- Don't add a second package-manager lockfile. The repo uses `pnpm-lock.yaml`.

## When reviewing changes

Report real problems only, most serious first, each with file, line and a concrete fix. Check these first:

1. **Renames, moves and deletions.** Search the repo for the old name and flag every leftover: call sites, completions (`compdef`, `#compdef`), alias arrays such as `HEADROOM_PROFILE_ALIASES`, mappings in `scripts/sync-home.zsh`, the `whence -w` check in `scripts/test-in-colima.zsh`, docs (`README.md`, `AGENTS.md`, `docs/user-manuals/`), and `"file"` paths in `.vscode/settings.json`.
2. **Load order.** A module that uses something defined by a module that loads later (`core/` loads before `apps.d/`, which loads before `plugins.d/`, and lower numbers load first).
3. **Module failure.** A last command that can return non-zero.
4. **Secrets and generated files.** Exported tokens, hard-coded keys, or `.zwc` files in the diff.
5. **Docs out of sync.** A new or changed command or path that `README.md` or `AGENTS.md` doesn't mention.

The full checklist is [`review-instructions.md`](review-instructions.md).

## Checking a change

```zsh
zsh scripts/lint.zsh
colima-test
```

CI runs both on every pull request. `AGENTS.md` has the details.

## Serena

Serena's symbol tools only understand bash, so they work on `scripts/setup-colima-docker.sh` and nothing else. Use text search for the zsh files.
