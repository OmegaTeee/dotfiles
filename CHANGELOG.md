# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/). This repo isn't versioned, so entries collect under `[Unreleased]` until a dated section is cut.

## [Unreleased]

### Added
- **Command presence check**: `scripts/check-commands.zsh` verifies that every autoloaded function in `config/zsh/functions/` resolves and starts with `#autoload`, and that every alias defined in `core/`, `apps.d/` and `plugins.d/` exists after startup, including the generated `hr-<profile>-<action>` Headroom aliases. Expected names are read from the config itself, so new functions and aliases are covered without editing the check. Aliases whose names are built from variables outside `20-headroom.zsh` fail the check until it is taught about them. `test-in-colima.zsh` now runs it in place of a hard-coded check of three functions and two aliases.
- **Lint script**: `scripts/lint.zsh` runs `zsh -n` on every zsh file (including autoload functions and the zsh completion in `core/65-completions-ast-grep.sh`) and `shellcheck` on `scripts/*.sh`. It replaces the hand-written command list in the agent docs.
- **CI workflows**, matching the PromptHub repo: `.github/workflows/ci.yml` runs the lint script, a whitespace check on pull requests, and the full `test-in-colima.zsh` harness against the runner's Docker (`COLIMA_TEST_CONTEXT=default`). `.github/workflows/labeler.yml` with `.github/labeler.yml` labels pull requests by area, and `.github/dependabot.yml` keeps the actions updated weekly.
- **Copilot review and commit-message instructions**: `.github/review-instructions.md` holds a review checklist that puts renames and moves first: leftover call sites, completions, alias arrays, sync mappings, test checks, docs and settings paths. `.github/commit-message-instructions.md` sets the commit style. `.vscode/settings.json` already pointed at that file, but it didn't exist. `github.copilot.chat.reviewSelection.instructions` now points at the review checklist.
- **Serena onboarding memories** in `.serena/memories/` (`core`, `tech_stack`, `conventions`, `suggested_commands`, `task_completion`).
- **This changelog.**

### Changed
- **`test-in-colima.zsh` syntax step** now also checks autoload functions and `core/*.sh`.
- **Agent guidance consolidated in `AGENTS.md`**: fixed stale pre-XDG `.config/zsh/...` paths, moved the general tool guidance (Headroom, RTK, ast-grep, difft, scc) out of `CLAUDE.md`, and added a "where changes go" table, the rules that are easy to break, and a Serena section stating that it only covers bash files. `CLAUDE.md` now imports `AGENTS.md` with `@AGENTS.md` and keeps only Claude-specific notes.
- **`.github/copilot-instructions.md` rewritten**: it no longer recommends Serena for zsh code, follows `AGENTS.md`, and has a short review checklist. The Source Control "review changes" command reads this file, not the review-instructions setting.
- **`README.md` rewritten for clarity**, with the same sections. The testing section now describes the full command check, and a new continuous integration section was added.

- **`TODOs.md` refreshed** against the live system on 2026-11-20. Removed the finished install-method items (done by `sync-home.zsh`) and the validation-entry-point item (done by `scripts/lint.zsh` and CI). Added the still-relevant items from the July `docs/plans/CLI-MIGRATION-INVENTORY.md`, after checking each one: npm globals, broken pipx launchers, `~/.local/bin` provenance. Also added a new item about tools re-creating `~/.zshrc`.

- **VS Code workspace**: `.vscode/mcp.json` is now a symlink to a root `.mcp.json`, which defines the PromptHub bridge server. The token comes from `${env:PH_API_TOKEN}`, not from the file. Settings add Claude Code preferences and a Markdown preview stylesheet (`docs/markdown.css`). `.vscode/extensions.json` is reformatted.
- **`home/zshenv`** shebang is now `#!/usr/bin/env zsh`.

### Removed
- **`docs/plans/CLI-MIGRATION-INVENTORY.md`**: a July 2026 snapshot. Its still-valid items moved to `TODOs.md`.
- **Tracked `.DS_Store` files** (`.serena/`, `docs/`, `home/`). `.gitignore` already excluded them; these were committed before that rule.
- **`config/zsh/themes/`**: an unused symlink into the versioned Homebrew path `Cellar/powerlevel10k/1.20.0`, which would have broken on the next `brew upgrade`, and a byte-identical copy of Homebrew's `powerlevel10k.zsh-theme`. Nothing loaded either. `core/90-prompt.zsh` sources the theme from `/opt/homebrew/share/powerlevel10k`, which Homebrew repoints on upgrade.

### Fixed
- **XDG completions load**: `core/60-completions.zsh` now adds `${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions` to `fpath`. Installers that follow XDG put completions there (zshellcheck's adds `_zshellcheck`), but their usual `fpath+=` line goes into `~/.zshrc`, which this setup never reads. Run `zsh-rebuild-completions` once so the cached completion dump picks up new entries.
