# TODOs

Status: active  
Updated: 2026-07-26

This list tracks deliberate follow-up work for the dotfiles repository. Keep
items concrete, scoped, and verifiable.

## Configuration ownership

- [ ] Decide on an idempotent installation method for the active Zsh tree:
  explicit symlinks managed by a small script versus a tool such as GNU Stow.
  Prefer the approach that preserves existing files with dated backups.
- [ ] Update `README.md` once the installation method is chosen; document
  source paths, symlink targets, rollback, and verification.
- [ ] Compare the tracked Zsh tree with `~/.config/zsh/` before converting any
  files to symlinks. Preserve local-only files and user edits.

## npm and pnpm

- [ ] Create a tracked non-secret npm configuration under
  `.config/npm/`, then decide whether `~/.npmrc` should link to it.
- [ ] Move npm authentication out of file-based configuration before creating
  that symlink; use macOS Keychain-backed loading for publishing credentials.
- [ ] Inventory pnpm global CLI packages and document the intended install and
  upgrade workflow under `PNPM_HOME`.
- [ ] Document the lockfile policy: `pnpm-lock.yaml` selects pnpm,
  `package-lock.json` selects npm, and project-specific configuration remains
  with the project.

## Node runtime

- [ ] Move the global `~/.config/mise/config.toml` into the repository and/or
  manage it with an explicit symlink after the configuration migration plan is
  chosen.
- [ ] Extend `node-doctor` only when new runtime providers or project pin
  formats are intentionally adopted; keep it read-only and diagnostic.

## Quality and maintenance

- [ ] Add a small, repeatable validation entry point for Zsh syntax checks,
  `zsh-doctor`, and repository hygiene checks.
- [ ] Decide whether generated `.zwc` files should remain ignored only or be
  removed from existing local installations during bootstrap.
- [ ] Review application modules for stale paths and move one-off machine
  state into documented setup steps where appropriate.

## Completed baseline

- [x] Homebrew provides mise, and mise manages the active Node runtime.
- [x] Node 24.18.0 is installed and selected through mise.
- [x] npm retains the `~/.npm-global` compatibility prefix.
- [x] pnpm is installed under `PNPM_HOME` and `pnpm help` succeeds.
- [x] `node-doctor` reports runtime paths, prefixes, project pins, and
  duplicate Node candidates.
- [x] Secret-loading helpers use macOS Keychain rather than committing tokens.
