# Task completion

Run from repo root after shell changes (same as AGENTS.md "Validation"; CI runs the same scripts):
```zsh
zsh scripts/lint.zsh   # zsh -n on all zsh files incl. functions + core/*.sh; shellcheck scripts/*.sh only
git diff --check
colima-test            # full harness; requires `colima start -p linux-vm`
```
- `colima-test` includes `scripts/check-commands.zsh`: every `functions/*` must autoload and start with `#autoload`; every literal `alias name=` in core/apps.d/plugins.d must exist. Computed alias names (built from variables) outside `20-headroom.zsh` fail the check until the script is taught about them.
- CI (`.github/workflows/ci.yml`) runs lint + the harness with `COLIMA_TEST_CONTEXT=default` on ubuntu-latest.
- Add user-visible changes under `## [Unreleased]` in `CHANGELOG.md` (Keep a Changelog, bold-title entries).
- Report if `colima-test` couldn't run (VM down) rather than claiming it passed. If you start Colima to test, stop it afterwards.
- Don't run `sync-home.zsh` (live apply) unless the user asks; a dry-run is fine.
- Package-manager changes: verify effective commands/prefixes in a fresh shell (`node-doctor`).
- Preserve unrelated working-tree changes; check `git status --short` first.
