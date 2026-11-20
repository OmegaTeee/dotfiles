# Commit message instructions

- First line: imperative mood, at most 72 characters, no trailing period. Example: `Move dotfiles to an XDG layout with a Colima test harness`.
- Optionally start with an area prefix when it helps: `Docs:`, `Refactor:`, `Fix:`, `Zsh:`, `Colima:`, `Headroom:`.
- Describe what changed for the user of the shell, not which lines moved.
- If the change needs more explanation, leave a blank line, then a short body of bullets. Mention any rename, so the old name can be found later, and anything the user must do after syncing (for example, restart Colima).
- Never include secret values, tokens or Keychain contents.
