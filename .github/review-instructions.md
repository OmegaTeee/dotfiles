# Code review instructions

Review changes to this Zsh dotfiles repo. Report only real problems, most serious first. Skip style nitpicks that `.editorconfig` already covers.

## Renames and moves (check these first)

When a function, alias, variable, file or folder is renamed, moved or deleted, search the whole repo for the old name and flag every place that still uses it:

- Call sites in other modules and in `config/zsh/functions/`.
- Completion definitions (`compdef`, `#compdef` lines, `_name` completion functions).
- Alias tables built from arrays, for example `HEADROOM_PROFILE_ALIASES` in `apps.d/20-headroom.zsh`.
- File mappings in `scripts/sync-home.zsh` and the exclude list in `scripts/test-in-colima.zsh`.
- The `whence -w` function check in `scripts/test-in-colima.zsh`.
- Docs: the command tables in `README.md`, the file paths in `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` and `docs/user-manuals/`.
- Settings that point at files, such as `.vscode/settings.json` entries with a `"file"` key.

## Changes that are easy to miss

- **Module failure:** a module whose last command returns non-zero is recorded as failed. Flag a final `[[ … ]] && …` or any last command that can fail when something optional is missing.
- **Load order:** a module that uses a variable, function or PATH entry set by a module that loads later (higher numeric prefix, or a later folder: `core/` loads before `apps.d/`, which loads before `plugins.d/`).
- **Bash in zsh files:** bash-only syntax in `.zsh` files or autoload functions, and zsh syntax "fixed" into bash. `core/65-completions-ast-grep.sh` is zsh.
- **Autoload functions** missing `#autoload` or `emulate -L zsh`, or leaking variables because a `local` is missing.
- **Secrets:** tokens exported from a module, hard-coded keys, or secret values printed.
- **Generated files:** `.zwc` files or caches added to the commit.
- **Staging rule:** code that writes straight into `~/.config/zsh`, which the next sync replaces.
- **Docs out of sync:** a new or changed command, path or option that `README.md` or `AGENTS.md` doesn't mention.

## Output

For each finding, give the file and line, what's wrong, and the concrete fix. If you find nothing, say so.
