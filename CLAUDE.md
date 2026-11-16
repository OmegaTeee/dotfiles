## Serena-specific notes

Serena is configured as a project-aware symbol-index tool with LSP-backed semantic understanding.

Your current project config already shows the expected pattern:

- `language_backend: LSP`
- `language_servers: [bash]`

This means Serena is configured to work with Bash LSP support in this dotfiles repo. That is appropriate for shell-heavy work, but it is not equivalent to a full Zsh LSP.

### Serena hooks are important

The config files you saved show the pattern of lifecycle hooks:

- `PreToolUse`
- `SessionStart`
- `Stop`

This is a strong signal that Serena is meant to be used as a policy layer, not only as a search/index tool.

General Serena hook pattern:

- remind/check activation before tool use
- activate project at session start
- clean up session state when the session ends

This fits a workflow where the AI agent starts in a known project context and respects the user’s local environment rules.

### Useful Serena practice

- Let Serena manage project context when the repo is active.
- Do not rely on text-only search when a symbol-level lookup is appropriate.
- Use bash as the active language server for shell-heavy config repos.
- Keep a `project.yml` for each project and a shared global config for defaults.
