# TODOs

Status: active
Updated: 2026-11-20

Deliberate follow-up work for the dotfiles repository. Keep items concrete, scoped and verifiable. Record finished work in [`CHANGELOG.md`](CHANGELOG.md) and remove it from here.

## Node globals

Checked on 2026-11-20. `pnpm ls -g` is empty, and npm's global prefix (`~/.local/share/npm`) holds `bash-language-server`, `prettier`, `typescript` and four Markdown libraries.

- [ ] Decide who owns global Node CLIs. `AGENTS.md` says pnpm (`PNPM_HOME`), but today every global package is installed with npm. Either reinstall `bash-language-server` and `prettier` with `pnpm add -g` and remove the npm copies, or update `AGENTS.md` to match reality. Then document the install and upgrade workflow.
- [ ] Move `typescript` (7.0.2) out of the npm globals into the `devDependencies` of the projects that use it.
- [ ] Move `highlight.js`, `markdown-it`, `markdown-it-checkbox`, `markdown-it-emoji` and `markdown-it-footnote` out of the npm globals. They're libraries, so a global install does nothing unless something imports them. Find the consumer first.
- [ ] Delete the stray `pnpm-lock.yaml` and empty `node_modules/` at the repo root. There's no `package.json`, and neither is tracked. Then fix the lockfile rule in `AGENTS.md`, which currently names `pnpm-lock.yaml`.
- [ ] Create a tracked non-secret npm config under `config/npm/` and add its mapping to `scripts/sync-home.zsh`. First move npm publishing credentials out of the file into Keychain-backed loading.

## Python tools (pipx)

- [ ] Repair the broken pipx launchers, then confirm `pipx list` reports none:
  - `fonttools`: `fonttools`, `pyftmerge`, `pyftsubset`, `ttx`
  - `statmake`
  - `mcp-obsidian`

  `pipx reinstall <package>` is the usual fix.

## `~/.local/bin`

`local/bin/` in this repo syncs to `~/.local/bin`, so know what's there before tracking anything.

- [ ] Remove or reinstall `mcporter`. Its link points at `~/.local/lib/node_modules/mcporter`, which no longer exists.
- [ ] Identify which project or package installed `container-use` (and its `cu` link), `hermes`, `junie` and `omo`. The other entries from the July inventory are accounted for: `cua-driver` (CuaDriver.app), `hf` (`~/.hf-cli`), `lazycodex-executor-verify` (omo Codex plugin), `mcp-bridge` (PromptHub), `supercoder` (`~/.local/supercoder`).

## Node runtime

- [ ] Bring `~/.config/mise/config.toml` into `config/mise/` with a mapping in `scripts/sync-home.zsh`.
- [ ] Extend `node-doctor` only when new runtime providers or project pin formats are adopted. Keep it read-only.

## Shell

- [ ] Stop tools from re-creating `~/.zshrc`. Installers keep appending to it (most recently zshellcheck's `fpath` line and a Headroom env block), even though Zsh never reads it with `ZDOTDIR` set. At minimum, have `zsh-doctor` warn when `~/.zshrc` exists, so stray settings get noticed and moved into the repo.
- [ ] Decide whether `sync-home.zsh` should delete stale `.zwc` files in the installed tree, or leave them to `init.zsh`'s recompile.
- [ ] Review `apps.d/` modules for stale paths. Move one-off machine state into documented setup steps.
