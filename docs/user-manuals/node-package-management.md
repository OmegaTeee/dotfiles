# Node package management

This guide explains how to install Node.js project dependencies in this Zsh framework.

Short rule:
- Use `mise` to select the Node.js runtime.
- Use the project lockfile to select the package manager.
- Use pnpm for global Node CLI tools.
- Use npm for compatibility publishing.

## Quick start

From a project directory:

```zsh
node-doctor
```

Then install dependencies with the manager the project already uses:

| Project file | Command |
| --- | --- |
| `pnpm-lock.yaml` | `pnpm install` |
| `package-lock.json` | `npm install` or `npm ci` |
| `yarn.lock` | `yarn install` |
| `bun.lock` or `bun.lockb` | `bun install` |

If `package.json` has a `packageManager` field, follow it. For example:

```json
{
  "packageManager": "pnpm@10.27.0"
}
```

means the project expects pnpm `10.27.0`.

## How `mise` fits in

Homebrew provides the `mise` executable on this machine. `mise` selects the active Node.js runtime after the base PATH is ready.

Relevant files:
- `.config/zsh/apps.d/10-npm-env.zsh` sets `NPM_CONFIG_PREFIX`.
- `.config/zsh/apps.d/11-npm-path.zsh` adds the npm global bin directory.
- `.config/zsh/apps.d/20-pnpm-env.zsh` sets `PNPM_HOME`.
- `.config/zsh/apps.d/21-pnpm-path.zsh` adds the pnpm bin directory.
- `.config/zsh/apps.d/23-pnpm-post-mise.zsh` restores pnpm shims after `mise` rewrites PATH.
- `.config/zsh/core/25-mise.zsh` runs `mise activate zsh`.
- `.config/zsh/functions/node-doctor` reports the active runtime and package-manager paths.
- `scripts/sync-zsh-home.zsh` refreshes the installed home shell config from the repo.

Use a project runtime pin when a project needs a specific Node version:

```toml
# mise.toml
[tools]
node = "24"
```

Then run:

```zsh
mise install
node-doctor
```

## Choosing install commands

Use project files first. This avoids mixed lockfiles and mismatched dependency trees.

### pnpm project

```zsh
pnpm install
pnpm run dev
```

For repeatable CI-style installs:

```zsh
pnpm install --frozen-lockfile
```

### npm project

```zsh
npm install
npm run dev
```

For repeatable CI-style installs:

```zsh
npm ci
```

### One-off tools

Prefer `pnpm dlx` for one-off Node tools the project does not need to keep:

```zsh
pnpm dlx some-tool --help
```

If a project needs a tool repeatedly, add it to `devDependencies`:

```zsh
pnpm add -D typescript
```

Or, for npm projects:

```zsh
npm install -D typescript
```

## Global CLI tools

Use pnpm for host-global Node CLI packages:

```zsh
pnpm add -g some-cli
```

Do not treat global packages as project dependencies. If a project imports a library or runs a CLI in scripts, add it to the project's `package.json`.

Use npm global installs only when a tool specifically needs npm behavior or when you are publishing packages:

```zsh
npm publish
```

## Devcontainers

In a devcontainer, install the project's own runtime dependencies. Do not copy host `node_modules`, `PNPM_HOME`, npm global packages, or host PATH into the container.

For a pnpm project, a typical `.devcontainer/devcontainer.json` command is:

```json
{
  "postCreateCommand": "pnpm install --frozen-lockfile"
}
```

If a project declares `packageManager: "pnpm@10.27.0"`, make the container use that pnpm version.

## Troubleshooting

Start with:

```zsh
node-doctor
```

Check values:

| Check | Good result |
| --- | --- |
| `mise` | Present and activated. |
| `node` | Comes from the selected `mise` runtime. |
| `pnpm` | Resolves from `PNPM_HOME/bin`. |
| `npm prefix` | Stays separate for compatibility publishing. |
| Project pins | Match `mise.toml`, `.node-version`, `.nvmrc`, or `packageManager`. |

## Common pitfalls

- Do not add a second lockfile to fix an install error.
- Do not install TypeScript, Vite, ESLint, or test runners globally for a project. Add `devDependencies`.
- Do not use host global packages inside devcontainers.
- Do not bypass `mise` with a separate Node version manager.
- Do not assume a stale global launcher PATH problem. Inspect the launcher target before you change PATH.
