# Colima and Docker

This guide starts the operating notes for local Colima and Docker use. The
larger migration inventory is in
[`CLI-MIGRATION-INVENTORY.md`](../../CLI-MIGRATION-INVENTORY.md).

## Ownership boundary

| Area | Owner |
| --- | --- |
| macOS host | Colima, Docker client, Docker contexts, VS Code, Keychain-backed secrets, Metal/local model servers. |
| Colima VM | Linux container runtime and Compose services. |
| Devcontainer | Project runtimes, dependencies, compilers, linters, tests, and project CLIs. |
| Project repository | `.devcontainer/`, Dockerfile, lockfiles, `packageManager`, `pyproject.toml`, and other project metadata. |

Keep host control-plane tools on macOS. Do not copy the host PATH or global CLI
directories into devcontainers. Install only the tools that the project
metadata needs.

## Shell functions

| Function | Command |
| --- | --- |
| `colima-start` | `colima start "$@"` |
| `colima-status` | `colima status "$@"` |
| `colima-stop` | `colima stop "$@"` |

These wrappers intentionally pass arguments through to Colima. Use standard
Colima flags when you need CPU, memory, architecture, or runtime changes.

## Auto-start behavior

`.config/zsh/apps.d/10-colima.zsh` can start Colima when you enter the project
root. It is off by default.

```zsh
export ZSH_AUTO_START_COLIMA=1
```

`COLIMA_PROJECT_ROOT` defaults to `PROJECT_FOLDER`. Set it only when the
automatic start boundary must be different.

## Common checks

```zsh
colima-status
docker context show
docker ps
docker compose version
```

If Docker commands fail, check `colima-status` first. Then verify the active
Docker context. Do not fix a Docker context problem by installing project tools
globally on the host.

## Devcontainer guidance

Use a project-owned `.devcontainer/` directory when a repository needs a
container. Put project runtimes and package-manager versions in that project.

For host services that intentionally stay on macOS, use explicit endpoints from
the container:

```json
{
  "remoteEnv": {
    "OPENAI_BASE_URL": "http://host.docker.internal:8787/v1",
    "LM_STUDIO_API_URL": "http://host.docker.internal:1234/v1"
  }
}
```

Do not pass secrets through this file. Use a project-specific secret plan and
keep credentials out of Git.

## Common pitfalls

- Do not install `colima` inside application containers.
- Do not bind-mount the complete host PATH into a devcontainer.
- Do not rely on host global `node_modules`, Python virtual environments, or
  caches from a project container.
- Do not add a second lockfile to hide a missing project dependency.
- Do not move Metal/local model binaries into Linux containers. Expose a host
  HTTP service when the project needs them.
