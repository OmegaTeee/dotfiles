# User manuals

This directory contains short manuals for the local Zsh framework. The manuals
explain how to use the configuration. They do not contain credentials,
machine-local secret values, caches, or generated state.

## Manuals

- [Functions overview](user-manuals/functions-overview.md) - Command index for
  autoloaded Zsh functions.
- [Colima and Docker](user-manuals/colima-docker.md) - Local Docker host,
  Colima, and devcontainer operating notes.
- [Secrets quick start](user-manuals/secrets-quick-start.md) - Store, update,
  load, and remove environment secrets from macOS Keychain.

## Documentation rules

- Keep examples safe to copy.
- Use service names, never real secret values.
- Update a manual when a referenced Zsh function changes.
- Keep project-specific setup in the project repository.
