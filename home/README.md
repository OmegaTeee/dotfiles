# home/

This folder holds only the files that must sit **directly in `$HOME`**. With the XDG layout, that's just one file:

| Repo file     | Installed as | Why it can't move                                                   |
| ------------- | ------------ | ------------------------------------------------------------------- |
| `home/zshenv` | `~/.zshenv`  | Zsh always reads `~/.zshenv`. It sets `XDG_*` and `ZDOTDIR=~/.config/zsh`. |

It is stored without the leading dot so it shows up in Finder and the IDE. `scripts/sync-home.zsh` installs it under the dotted name.

## Where everything else goes

| Kind of config                     | Repo folder            | Installed to              |
| ---------------------------------- | ---------------------- | ------------------------- |
| App config (XDG)                   | `config/<app>/`        | `~/.config/<app>/`        |
| Colima VM settings                 | `config/colima/<profile>/colima.yaml` | `~/.colima/<profile>/colima.yaml` |
| Personal scripts                   | `local/bin/`           | `~/.local/bin/`           |
| Login agents (macOS)               | `macos/LaunchAgents/`  | `~/Library/LaunchAgents/` |

Add a mapping to `scripts/sync-home.zsh` when a new top-level folder is needed.

## Never commit

Secrets, credential stores, caches, databases, logs, VM disks, Docker contexts, or generated state. Those stay at the paths their apps manage, for example:

- `~/.headroom/`: Headroom databases, logs, deploy scripts (they contain tokens), `copilot_auth.json`.
- `~/.colima/` (except `colima.yaml`): VM disks and sockets.
- `~/.serena/`: Serena caches. The project config is in this repo's `.serena/project.yml`.

`home/headroom` may exist locally as a convenience symlink to `~/.headroom`. It is gitignored. Keep it that way.
