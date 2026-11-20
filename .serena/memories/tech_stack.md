# Tech stack

- Zsh (macOS `/bin/zsh`); scripts use `#!/bin/zsh` + `set -euo pipefail` + `emulate -L zsh`. Only real bash file: `scripts/setup-colima-docker.sh`. `config/zsh/core/65-completions-ast-grep.sh` is a zsh `#compdef` completion despite its `.sh` extension (shellcheck/bash LSP misread it).
- Prompt: powerlevel10k vendored at `config/zsh/themes/powerlevel10k`; config `config/zsh/.p10k.zsh`.
- Runtime: Homebrew provides `mise`; mise manages Node (`core/25-mise.zsh`). pnpm owns global Node CLIs via `PNPM_HOME`; npm kept only as compat/publish prefix. Don't add a second lockfile (repo has `pnpm-lock.yaml`).
- `~/.config/mise/config.toml` and npm config intentionally NOT in repo yet (deferred migration).
- Testing: Colima Docker context `colima-linux-vm`, image `ubuntu:24.04` (overridable via `COLIMA_TEST_CONTEXT`, `COLIMA_TEST_IMAGE`). macOS-only bits (Keychain, launchctl, brew) skipped on Linux.
- Linters via Homebrew: `shellcheck`, `shfmt` — bash files only.
- Integrations configured in `apps.d/`: headroom proxy profiles (`init-visualval` :8787, `visualval-lmstudio` :8788), PromptHub (`$PROMPTHUB_HOME`=`~/.local/share/prompthub`), llama.cpp, goose, AI clients.
