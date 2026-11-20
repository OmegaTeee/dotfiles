# dotfiles: a lightweight Zsh setup with an XDG layout

A small Zsh configuration for macOS that keeps `$HOME` clean. It follows the [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/latest/) layout and uses no plugin manager: no Oh My Zsh, zinit or antidote.

- **Clean `$HOME`.** Config lives in `~/.config`, data and state in `~/.local`. The only Zsh file in `$HOME` is `~/.zshenv`.
- **Fast startup.** Modules are compiled to `.zwc` bytecode as they change, and commands load only when first used. Startup takes about 10 ms.
- **Drop-in modules.** Put a file in `core/`, `apps.d/` or `plugins.d/` and it loads. No registration needed.
- **Secrets only when needed.** API keys come from the macOS Keychain, only for the one command that needs them.
- **Test before you apply.** `colima-test` runs the whole setup in a throwaway Linux container first.

> [!IMPORTANT]
> This repo is a **staging copy**. Editing files here does not change your live shell. Changes go live only when you run [`scripts/sync-home.zsh`](scripts/sync-home.zsh).

## Making a change

```zsh
cd ~/workspaces/dotfiles
# 1. Edit files in the repo.
colima-test                        # 2. Test in a throwaway container.
./scripts/sync-home.zsh --dry-run  # 3. Preview what would change on this Mac.
./scripts/sync-home.zsh            # 4. Apply. Replaced files are backed up first.
exec zsh && zsh-doctor             # 5. Reload and check.
```

On the very first run `colima-test` isn't installed yet, so use `zsh scripts/test-in-colima.zsh` instead.

## What goes where

| Repo path                             | Installed to                      | How                                        |
| ------------------------------------- | --------------------------------- | ------------------------------------------ |
| `home/zshenv`                         | `~/.zshenv`                       | Single file. Sets `XDG_*` and `ZDOTDIR`.   |
| `config/zsh/`                         | `~/.config/zsh/` (`$ZDOTDIR`)     | The whole folder is replaced.              |
| `config/colima/<profile>/colima.yaml` | `~/.colima/<profile>/colima.yaml` | Only if that profile already exists.       |
| `local/bin/*`                         | `~/.local/bin/`                   | Individual files.                          |
| `macos/LaunchAgents/*.plist`          | `~/Library/LaunchAgents/`         | Then reloaded with `launchctl`. macOS only. |
| `scripts/`, `docs/`                   | Not installed                     | Sync and test tools, user manuals.         |

The repo has no hidden folders for config (`home/zshenv` rather than `.zshenv`, `config/` rather than `.config/`), so everything shows up in Finder and your editor. [`home/README.md`](home/README.md) explains what may sit directly in `$HOME` and what must never be committed.

### What the sync script does

- **Skips** anything that's already identical, so running it again with no changes does nothing.
- **Backs up** whatever it replaces to `~/.local/state/dotfiles/backups/<epoch>/`, keeping each file's path relative to `$HOME`.
- **Retires** `~/.zshrc` and `~/.zprofile` into that backup. Once `ZDOTDIR` is set, Zsh never reads them.
- **Leaves Colima alone** apart from `colima.yaml`. VM disks and sockets are untouched. After `colima.yaml` changes, restart the VM: `colima stop -p <p> && colima start -p <p>`.

> [!WARNING]
> Because `~/.config/zsh` is replaced as a whole, anything you add there by hand gets moved into the backup on the next sync. Make the change in the repo instead. Your history is safe: it lives in `~/.local/state/zsh/history`.

### Runtime files

| What              | Path                                 |
| ----------------- | ------------------------------------ |
| Shell history     | `~/.local/state/zsh/history`         |
| Completion cache  | `~/.cache/zsh/zcompdump-<version>`   |
| Compiled modules  | `~/.config/zsh/**/*.zwc` (generated) |
| Sync backups      | `~/.local/state/dotfiles/backups/`   |
| Prompt config     | `~/.config/zsh/.p10k.zsh`            |

## How a shell starts

```text
~/.zshenv                    sets XDG_* and ZDOTDIR=~/.config/zsh
~/.config/zsh/.zprofile      login shells only: sources ~/.profile
~/.config/zsh/.zshrc         instant prompt, starts the startup timer
  └─ init.zsh                the loader
       ├─ core/*.zsh         environment, PATH, mise, options, secrets, autoload, completions, prompt
       ├─ apps.d/*.zsh       per-tool setup: npm, pnpm, Colima, Headroom, PromptHub, AI clients …
       └─ plugins.d/*.plugin.zsh
```

Files in each folder load in name order, so the numeric prefixes set the order. For each file, `init.zsh` recompiles its `.zwc` if it's out of date, sources it, and records whether it loaded, compiled or failed. `zsh-doctor` shows the results.

> [!TIP]
> A module counts as **failed** if its last command returns non-zero. Write optional steps as `if [[ -d … ]]; then …; fi`, not `[[ -d … ]] && …`, which fails whenever the folder is missing.

## Testing in Colima

`colima-test` (the same as `zsh scripts/test-in-colima.zsh`):

1. Copies your working tree, including uncommitted changes, into an `ubuntu:24.04` container on the `colima-linux-vm` Docker context. It skips `.git`, `node_modules` and `home/headroom`.
2. Runs `sync-home.zsh --home /tmp/home` twice. The second run must change nothing.
3. Syntax-checks every module and function with `zsh -n`, then starts an interactive login shell. It requires zero failed modules and the right `ZDOTDIR` and `HISTFILE`.
4. Checks that every function in `functions/` and every alias the modules define is present ([`scripts/check-commands.zsh`](scripts/check-commands.zsh)). New functions and aliases are picked up automatically.
5. Checks that the test home contains only `.zshenv`, `.config`, `.local`, `.cache` and `.colima`.

Nothing is written to the VM or your Mac, and the container is removed afterwards. Start the VM first with `colima start -p linux-vm`. To use a different context or image, set `COLIMA_TEST_CONTEXT` or `COLIMA_TEST_IMAGE`. macOS-only parts (Keychain, `launchctl`, Homebrew) are skipped on Linux.

For the quick static checks alone (zsh syntax and shellcheck), run `zsh scripts/lint.zsh`.

### Continuous integration

GitHub Actions runs the same checks on every push and pull request to `main` ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)): `scripts/lint.zsh`, a whitespace check, and the full `test-in-colima.zsh` harness on the runner's own Docker. Pull requests are also labeled by the areas they touch ([`.github/labeler.yml`](.github/labeler.yml)), and Dependabot keeps the workflow actions up to date. The setup matches the PromptHub repo's.

## Commands

### Shell maintenance

| Command                   | What it does                                                         |
| ------------------------- | -------------------------------------------------------------------- |
| `zsh-doctor`              | Shows `ZDOTDIR`, the history file, module status and `PATH` problems. Also warns when the shell is running an older copy of the config. |
| `zsh-profile`             | Restarts Zsh with startup profiling on                               |
| `zsh-recompile`           | Deletes every `.zwc` file and restarts                               |
| `zsh-rebuild-completions` | Rebuilds the completion cache                                        |
| `restart-zsh`             | Runs `exec zsh`                                                      |

### Headroom

| Command                                   | What it does                                                    |
| ----------------------------------------- | --------------------------------------------------------------- |
| `hr-lms-{start,stop,restart,status}`      | `headroom install <action>` for the `visualval-lmstudio` profile (port 8788) |
| `hr-init-{start,stop,restart,status}`     | The same for the `init-visualval` profile (port 8787)           |
| `hr-lms-health`, `hr-init-health`         | One-line health check                                           |
| `hr-lms-logs`, `hr-init-logs`             | Follows the profile's log                                       |
| `headroom-deploy <action> [profile] [-v]` | The general form, with tab completion for actions and profiles  |

To add a profile, add a shorthand to `HEADROOM_PROFILE_ALIASES` in [`apps.d/20-headroom.zsh`](config/zsh/apps.d/20-headroom.zsh). That file also holds the non-secret `HEADROOM_*` defaults that `headroom install apply` used to append to `~/.zshrc`. If you run `apply` again, copy any new values into it by hand.

Headroom's own state in `~/.headroom` (databases, logs, deploy scripts containing tokens) never goes in this repo.

### Colima and Docker

| Command                                    | What it does                                                  |
| ------------------------------------------ | ------------------------------------------------------------- |
| `colima-test`                              | Tests the dotfiles in a throwaway container (see above)       |
| `colima-start`, `colima-stop`, `colima-status` | Pass-throughs to `colima`                                 |
| `colima-setup`                             | Installs or repairs Docker and Colima (`scripts/setup-colima-docker.sh`) |

### Node

`node-doctor` shows how mise, Node, npm and pnpm resolve, without changing anything. See [Node package management](docs/user-manuals/node-package-management.md).

### AI clients

`claude-local`, `codex-local`, `goose-local` and `cherry-local` (Cherry Studio) start each app with its API keys loaded, through `with_secrets ai`.

### PromptHub

`prompthub-keys`, `prompthub-router`, `prompthub-router-stop`, `prompthub-health` and `prompthub-logs`. PromptHub lives in `$PROMPTHUB_HOME` (`~/.local/share/prompthub`).

## Secrets

Secrets are stored in the macOS Keychain as generic passwords under your user account. They load for a single command, in a subshell, and are never exported into your shell:

```zsh
with_secrets ai       claude          # LM Studio, Hugging Face, OpenRouter and other AI keys
with_secrets github   gh auth status
with_secrets services npm run deploy
```

To add a secret, store it with `security add-generic-password -a "$USER" -s NAME -w`, then map it in [`core/40-secrets.zsh`](config/zsh/core/40-secrets.zsh). See the [secrets quick start](docs/user-manuals/secrets-quick-start.md).

## Extending

| To add…           | Create                                                                    |
| ----------------- | ------------------------------------------------------------------------- |
| A tool            | `config/zsh/apps.d/80-my-tool.zsh` for env, `PATH` and aliases            |
| A bigger command  | `config/zsh/functions/my-command`, starting with `#autoload` and `emulate -L zsh` |
| A plugin          | `config/zsh/plugins.d/30-name.plugin.zsh`                                 |
| An app's config   | `config/<app>/…`, plus a mapping line in `scripts/sync-home.zsh` if the app reads `~/.config/<app>` |
| A login agent     | A plist in `macos/LaunchAgents/`                                          |

Then run `colima-test`, followed by `sync-home.zsh`.

## Further reading

- [Functions overview](docs/user-manuals/functions-overview.md)
- [Node package management](docs/user-manuals/node-package-management.md)
- [Colima and Docker](docs/user-manuals/colima-docker.md)
- [Secrets quick start](docs/user-manuals/secrets-quick-start.md)
- [`AGENTS.md`](AGENTS.md): instructions for coding agents working in this repo
