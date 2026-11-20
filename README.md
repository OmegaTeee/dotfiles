# dotfiles: Zsh Lite Framework, XDG layout

A small Zsh setup for macOS that keeps `$HOME` clean. It follows the [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/latest/) layout, and it doesn't use a plugin manager: no Oh My Zsh, zinit or antidote.

- **XDG layout**: config lives in `~/.config`, data and state in `~/.local`. The only Zsh file in `$HOME` is `~/.zshenv`.
- **Nothing hidden in the repo**: the repo uses no dot-named folders (`config/`, `local/`, `macos/`, `home/zshenv`), so everything shows up in Finder and the IDE.
- **Test before applying**: `colima-test` runs the whole setup in a throwaway Linux container on Colima.
- **Automatic module discovery**: drop a file into `core/`, `apps.d/` or `plugins.d/` and it loads.
- **Incremental `.zwc` compilation** and **autoloaded functions** keep startup around 10 ms.
- **Lazy secrets**: API keys come from the macOS Keychain only for the one command that needs them.
- **Headroom deploy shortcuts**: `hr-lms-restart`, `headroom-deploy health init`, and so on.

> [!IMPORTANT]
> This repo is a **staging copy**. Editing files here doesn't change your live shell. Changes go live only when you run [`scripts/sync-home.zsh`](scripts/sync-home.zsh).

## Workflow

```zsh
cd ~/workspaces/dotfiles
# 1. edit files in the repo
colima-test                        # 2. test in a throwaway container on Colima
./scripts/sync-home.zsh --dry-run  # 3. preview what would change on this Mac
./scripts/sync-home.zsh            # 4. apply (replaced files are backed up first)
exec zsh && zsh-doctor             # 5. check
```

> [!NOTE]
> On the first run, `colima-test` is not yet installed, so call `zsh scripts/test-in-colima.zsh` directly.

## Repository layout and where it goes

| Repo path                              | Installed to                         | How                               |
| -------------------------------------- | ------------------------------------ | --------------------------------- |
| `home/zshenv`                          | `~/.zshenv`                          | file (sets `XDG_*` and `ZDOTDIR`) |
| `config/zsh/`                          | `~/.config/zsh/` (= `$ZDOTDIR`)      | whole folder replaced             |
| `config/colima/<profile>/colima.yaml`  | `~/.colima/<profile>/colima.yaml`    | file, only if that profile exists |
| `local/bin/*`                          | `~/.local/bin/`                      | individual files                  |
| `macos/LaunchAgents/*.plist`           | `~/Library/LaunchAgents/`            | file, then reloaded with `launchctl` (macOS only) |
| `scripts/`                             | not installed                        | sync and test tools               |
| `docs/user-manuals/`                   | not installed                        | how-to guides                     |

The sync script:

- **skips** any target that's already identical, so a re-run with nothing changed does nothing.
- **backs up** anything it replaces to `~/.local/state/dotfiles/backups/<epoch>/`, keeping each file's path relative to home.
- **retires** `~/.zshrc` and `~/.zprofile` into that backup, because Zsh never reads them once `ZDOTDIR` is set.
- does **not** touch Colima's VM disks or sockets. Only `colima.yaml` is managed. After it changes, restart with `colima stop -p <p> && colima start -p <p>`.

> [!WARNING]
> `~/.config/zsh` is replaced as a whole folder. Anything you put there by hand ends up in the backup, so put it in the repo instead. History is safe: it lives in `~/.local/state/zsh/history`.

### Where runtime files end up

| What                   | Path                                |
| ---------------------- | ----------------------------------- |
| Shell history          | `~/.local/state/zsh/history`        |
| Completion dump        | `~/.cache/zsh/zcompdump-<version>`  |
| Compiled modules       | `~/.config/zsh/**/*.zwc` (generated) |
| Sync backups           | `~/.local/state/dotfiles/backups/`  |
| p10k config            | `~/.config/zsh/.p10k.zsh`           |

## How a shell starts

```text
~/.zshenv                      XDG_* vars, ZDOTDIR=~/.config/zsh
~/.config/zsh/.zprofile        login shells: sources ~/.profile
~/.config/zsh/.zshrc           p10k instant prompt, start timing
  └─ init.zsh                  loader
       ├─ core/*.zsh           environment, PATH, mise, options, secrets, autoload, completions, prompt
       ├─ apps.d/*.zsh         per-tool setup (npm, pnpm, colima, headroom, prompthub, AI clients …)
       └─ plugins.d/*.plugin.zsh
```

Inside each folder, files load in lexical order, so numeric prefixes set the order. For each file, `init.zsh` recompiles the `.zwc` if it's stale, sources the file, and records the outcome in `ZSH_LOADED_MODULES`, `ZSH_COMPILED_MODULES` or `ZSH_FAILED_MODULES`. `zsh-doctor` reports from these.

> [!TIP]
> A module counts as **failed** when its last command returns non-zero. Write optional steps as `if [[ -d … ]]; then …; fi`, not `[[ -d … ]] && …`.

## Testing in Colima

`colima-test` (or `scripts/test-in-colima.zsh`):

1. Streams the working tree, including uncommitted changes, into an `ubuntu:24.04` container on the `colima-linux-vm` Docker context. It skips `.git`, `node_modules` and `home/headroom`.
2. Runs `sync-home.zsh --home /tmp/home` twice. The second run must change nothing.
3. Runs `zsh -n` on every module, starts an interactive login shell, and requires 0 failed modules, the right `ZDOTDIR` and `HISTFILE`, and all functions and aliases present.
4. Checks that the sandbox home contains only `.zshenv`, `.config`, `.local`, `.cache` and `.colima`.

Nothing on the VM or your Mac is written, and the container is removed afterwards. You can override the defaults with `COLIMA_TEST_CONTEXT` and `COLIMA_TEST_IMAGE`. macOS-only pieces (Keychain, `launchctl`, Homebrew) are skipped on Linux.

## Commands

### Shell maintenance

| Command                   | What it does                                                       |
| ------------------------- | ------------------------------------------------------------------ |
| `zsh-doctor`              | Shows ZDOTDIR, history file, module load and compile state, PATH issues |
| `zsh-profile`             | Restarts Zsh with startup profiling on                             |
| `zsh-recompile`           | Deletes every `.zwc` file and restarts                             |
| `zsh-rebuild-completions` | Rebuilds the completion dump                                       |
| `restart-zsh`             | `exec zsh`                                                         |

### Headroom deployments

| Command                                       | What it does                                         |
| --------------------------------------------- | ---------------------------------------------------- |
| `hr-lms-{start,stop,restart,status}`          | `headroom install <action> --profile visualval-lmstudio` (:8788) |
| `hr-init-{start,stop,restart,status}`         | same for `init-visualval` (:8787)                    |
| `hr-lms-health` / `hr-init-health`            | One-line health check from the profile's `health_url` |
| `hr-lms-logs` / `hr-init-logs`                | Follows the profile's `runner.log`                   |
| `headroom-deploy <action> [profile] [-v]`     | The general form. Tab completion covers actions and profiles |

To add a profile, add a shorthand to `HEADROOM_PROFILE_ALIASES` in [`apps.d/20-headroom.zsh`](config/zsh/apps.d/20-headroom.zsh). The non-secret `HEADROOM_*` defaults that `headroom install apply` used to append to `~/.zshrc` now live in that file. If you run `apply` again, copy any new values there by hand.

Headroom's own state (`~/.headroom`: databases, logs, deploy scripts with embedded tokens) never goes in this repo.

### Colima and Docker

| Command                                           | What it does                          |
| ------------------------------------------------- | ------------------------------------- |
| `colima-test`                                     | Tests the dotfiles in a throwaway container (see above) |
| `colima-start` / `colima-stop` / `colima-status`  | Pass-throughs to `colima …`           |
| `colima-setup`                                    | Reinstalls or repairs Docker and Colima (`scripts/setup-colima-docker.sh`) |

### Node toolchain

`node-doctor` shows how mise, Node, npm and pnpm resolve. It's read-only. See [Node package management](docs/user-manuals/node-package-management.md).

### AI clients with secrets loaded

`claude-local`, `codex-local`, `goose-local` and `cherry-local` (Cherry Studio) each run their app through `with_secrets ai …`.

### PromptHub

`prompthub-keys`, `prompthub-router`, `prompthub-router-stop`, `prompthub-health` and `prompthub-logs`. PromptHub lives in `$PROMPTHUB_HOME` (`~/.local/share/prompthub`).

## Secrets

Secrets live in the macOS Keychain, as generic passwords under your user account. They are loaded per command, in a subshell:

```zsh
with_secrets ai       claude          # LM Studio, HF, OpenRouter, … keys
with_secrets github   gh auth status
with_secrets services npm run deploy
```

No token is ever exported from a module. To add one, run `security add-generic-password -a "$USER" -s NAME -w`, then map it in `core/40-secrets.zsh`. See [Secrets quick start](docs/user-manuals/secrets-quick-start.md).

## Extending

- **New tool:** `config/zsh/apps.d/80-my-tool.zsh` for env, PATH and aliases. Put bigger logic in `config/zsh/functions/my-tool`, starting with `#autoload` and `emulate -L zsh`.
- **New plugin:** `config/zsh/plugins.d/30-name.plugin.zsh`.
- **New app config:** `config/<app>/…`. If the app reads from `~/.config/<app>`, add one mapping line to `scripts/sync-home.zsh`.
- **New login agent:** drop the plist into `macos/LaunchAgents/`.

Then run `colima-test`, followed by `sync-home.zsh`.

## Docs

- [Functions overview](docs/user-manuals/functions-overview.md)
- [Node package management](docs/user-manuals/node-package-management.md)
- [Colima Docker](docs/user-manuals/colima-docker.md)
- [Secrets quick start](docs/user-manuals/secrets-quick-start.md)
- [`home/README.md`](home/README.md): what may sit directly in `$HOME`, and what must never be committed
