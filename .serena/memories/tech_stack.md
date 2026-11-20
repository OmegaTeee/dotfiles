# Tech stack

- Zsh (macOS `/bin/zsh`); scripts use `#!/bin/zsh` + `set -euo pipefail` + `emulate -L zsh`. Only real bash file: `scripts/setup-colima-docker.sh`. `config/zsh/core/65-completions-ast-grep.sh` is a zsh `#compdef` completion despite its `.sh` extension (shellcheck/bash LSP misread it).
- Prompt: powerlevel10k from Homebrew, sourced in `core/90-prompt.zsh` via the unversioned `/opt/homebrew/share/powerlevel10k` path (never a `Cellar/<version>` path). Nothing vendored in the repo; user config is `config/zsh/.p10k.zsh`.
- Runtime: Homebrew provides `mise`; mise manages Node and pnpm (`core/25-mise.zsh`). `PNPM_HOME=~/.local/share/pnpm`, npm prefix `~/.local/share/npm`; pnpm bin precedes npm bin on PATH. Intended: pnpm owns global CLIs; actual (2026-11): globals are all npm — see `TODOs.md`.
- Repo has no Node project (no package.json); a root `pnpm-lock.yaml`/`node_modules/` are untracked strays.
- `~/.config/mise/config.toml` and npm config intentionally NOT in repo yet (deferred migration).
- Testing: Colima Docker context `colima-linux-vm`, image `ubuntu:24.04` (overridable via `COLIMA_TEST_CONTEXT`, `COLIMA_TEST_IMAGE`); CI uses `COLIMA_TEST_CONTEXT=default`. macOS-only bits (Keychain, launchctl, brew) skipped on Linux.
- Linters: `shellcheck`, `shfmt` (bash only), `zshellcheck` (zsh linter, `~/.local/bin`; used by the VS Code rewdy.zshellcheck extension, not yet in lint.zsh/CI).
- Completions: `core/60-completions.zsh` adds Homebrew site-functions and XDG `~/.local/share/zsh/site-functions`; dump is cached (`compinit -C`), so new completions need `zsh-rebuild-completions`.
- Integrations configured in `apps.d/`: headroom proxy profiles (`init-visualval` :8787, `visualval-lmstudio` :8788), PromptHub (`$PROMPTHUB_HOME`=`~/.local/share/prompthub`), llama.cpp, goose, AI clients.
