# CLI Migration Inventory

Snapshot: 2026-07-27 on the local macOS host.

This inventory records CLI ownership and the intended boundary between the
macOS host, Colima, and VS Code Dev Containers. It inventories package-manager
roots and directly installed Homebrew formulae rather than every transitive
helper binary in `/opt/homebrew/bin`.

## Integration boundary

| Boundary | Keep here | Do not copy blindly |
| --- | --- | --- |
| macOS host | Colima, Docker client/context, VS Code, Homebrew, Keychain-backed secrets, Metal/local model servers | Project virtual environments, project `node_modules`, host-specific caches |
| Colima/Docker host | Linux containers, Compose services, devcontainer workloads | macOS-only `colima` or Metal binaries inside application containers |
| Devcontainer | Project runtime, lockfile-selected package manager, compilers, linters, test tools, project CLIs | Host global CLI inventory and host credentials |
| Project metadata | `packageManager`, lockfiles, `pyproject.toml`, Dockerfile, `devcontainer.json` | A second lockfile or a global tool used to hide missing project dependencies |

There is currently no `devcontainer.json` or `devcontainer.jsonc` under
`/Users/visualval/code`. The first migration should therefore establish the
container contract rather than bind-mount the host's complete PATH.

## Runtime and package-manager inventory

| Tool or root | Current state | Integration point |
| --- | --- | --- |
| `mise` | Homebrew executable, 2026.7.14 | Host shell; use a container feature or Dockerfile runtime for projects |
| Node | mise-managed 24.18.0 | Devcontainer per project; do not rely on host Node |
| npm | Node-bundled 11.16.0; prefix `~/.npm-global` | Project package manager only when the project uses `package-lock.json`; publishing compatibility on host |
| pnpm | `PNPM_HOME`, 11.17.0 | Project lockfile-selected version inside the devcontainer; global Node CLIs only on host |
| Python | PromptHub app venv is selected in the current shell | Project venv and dependencies inside the devcontainer |
| `uv` | Homebrew executable | Host tool management; use `uv` inside Python project containers when reproducibility requires it |
| `pipx` | Homebrew executable; exposes `~/.local/bin` | Host-only utility isolation; project Python tools belong in the container |
| Bun | `~/.bun/bin/bun`, `bunx` | Project-local only when a repository explicitly selects Bun |
| Rust | Homebrew/user Rust toolchain under `~/.cargo/bin` | Devcontainer only for Rust projects |
| Go | Homebrew 1.26.5 | Devcontainer only for Go projects |
| .NET | Homebrew dotnet 10.0.302 | Devcontainer only for .NET projects |

`/Users/visualval/code/cherry/package.json` declares `packageManager` as
`pnpm@10.27.0`, so its devcontainer must use pnpm 10.27.0 even though the
host's global pnpm is 11.17.0.

## Node CLI packages

### npm global root

Current direct packages under `~/.npm-global`:

- `@earendil-works/pi-coding-agent` 0.80.3 — personal agent; host by default,
  container only when a project task explicitly invokes it.
- `@google/gemini-cli` 0.50.0 — host or agent container, depending on where
  authentication and the working tree live.
- `@qwen-code/qwen-code` 0.19.8 — host for local model workflows; container
  only when the model endpoint is reachable through the container boundary.
- `acpx` 0.12.0 — host/agent tooling; install in a container only if the
  container invokes ACP peers.
- `cline` 3.0.38 — normally VS Code/host integration; not a base image tool.
- `typescript` 6.0.3 — move to each project's `devDependencies` and invoke
  through the project package manager.

The remaining global npm packages are libraries (`highlight.js`, `markdown-it`,
and its checkbox, emoji, and footnote extensions). They should not be treated
as globally available project dependencies; add them to the consuming project.

### pnpm bin directory

`~/Library/pnpm/bin` currently exposes these launcher names:

```text
claude  claude-agent-acp  clean-room-skill  codex  copilot  firecrawl
gemini  gsd  gsd-cli  gsd-pi  opencode  openupm  openupm-cli  pi pi-ai
pi-subagents  pn  pnpm  pnpx  pnx  qwen
```

The declared pnpm global project currently contains only
`obsidian-companion-mcp-workspace@0.0.0`. The `codex`, `pi`, and pnpm-managed
`opencode` launchers point at missing store-link targets and fail directly;
they are stale launchers, not usable installations. Homebrew `opencode` 1.18.5
is healthy, and the npm `pi` 0.80.3 installation is healthy.

Treat the remaining launcher names as candidates until each is re-established
through a declared package install. Do not copy this directory into a
devcontainer.

### Node migration rule

Use pnpm for host-global Node CLIs after repairing its global state. Remove
duplicate npm installations only after the pnpm command works and its version
is recorded. Keep project CLIs such as TypeScript in the project manifest.

## Python and ML CLI inventory

### uv tools

- `aider-chat` 0.86.2 → host or project-specific agent container.
- `mlx-lm` 0.31.3 → macOS host only when using Apple Metal/MPS.
- `openhands` 1.16.0 → host by default; containerize only as an agent service.
- `serena-agent` 1.5.3 → host for repository analysis, or a devcontainer when
  the language server and source tree are both container-local.

OpenHands currently resolves through `~/uv-tools` and is healthy. Its startup
emits an Authlib deprecation warning, which is an application warning rather
than a PATH or installation failure.

### pipx tools

Directly managed packages include:

- `comfy-cli` 1.7.3
- `gftools` 0.9.995 and its FontTools ecosystem
- `mcp-obsidian` 0.2.2
- `mcp-server-fetch` 2025.4.7
- `ramalama` 0.23.0
- `ufo2ft` 3.7.1 and related font packages
- supporting packages such as `booleanoperations`, `defcon`, `fontparts`,
  `fonttools`, `statmake`, and `mcp-obsidian-tools`

These are host-oriented tools or specialized build containers, not a default
application devcontainer payload. `pipx list` reports broken or unexpected
launchers for FontTools, `mcp-obsidian`, and `statmake`; repair those separately
before depending on them in automation.

The current user bin also contains ML/Vision tools from a vllm-metal virtual
environment, including `vllm`, `mlx_lm`, `mlx_vlm`, `transformers`, `datasets-cli`,
`accelerate`, `torchrun`, `uvicorn`, and supervisor commands. These require a
dedicated host/ML image decision; they should not be placed in a general
devcontainer.

Additional user-bin entries needing explicit provenance before migration
include `container-use`, `cu`, `cua-driver`, `hermes`, `hf`, `junie`,
`lazycodex-executor-verify`, `mcp-bridge`, `mcporter`, `omo` and its
`omo-*` helpers, `supercoder`, and `tiny-agents`. Keep these on the host until
their owning project or package is identified; do not treat presence in
`~/.local/bin` as evidence that a container should inherit them.

## Homebrew host inventory

Directly installed Homebrew leaves relevant to the migrations include:

```text
acpica aider llmfit memo headroom autojump autotrace bash-completion@2
block-goose-cli boost-python3 bundler-completion chrome-cli cmake
cmake-language-server cmake-lint code-cli colima cython ddgr direnv docker
docker-buildx docker-compose dockerfile-language-server dotenvx dotnet
draw-things-cli fd fontforge ftgl gem-completion gh git github-mcp-server go
hermes-agent hf jq lcdf-typetools krunkit libvncserver lockrun ks
mlx-lm llama-swap ollama open-completion openai-whisper opencode
```

Host-only or host-first assignments:

- `colima`, `docker`, `docker-buildx`, `docker-compose`, `limactl`, and related
  Lima helpers — host control plane for VS Code Dev Containers.
- `code`, `code-insiders` — host VS Code integration.
- `mise`, `gh`, `git`, `git-lfs`, `direnv`, `fzf`, `rg`, `fd`, `jq`, and `yq` —
  host conveniences; install container copies only when project workflows use
  them.
- `opencode`, `block-goose-cli`, `hermes-agent`, `github-mcp-server`, `hf`,
  `aider`, and `llmfit` — host agent tools unless a specific agent image owns
  their configuration.
- `ollama`, `mlx-lm`, `openai-whisper`, `llama*`, and Draw Things tools — keep
  on the host when they use macOS services or Metal; expose an HTTP endpoint to
  containers instead of moving the binary.
- `fontforge`, ImageMagick, Ghostscript, PDF, WebP, and font utilities — use a
  specialized build/image container when a project needs reproducibility.

## Zsh application integrations

Existing modules already define useful migration boundaries:

| Module | Current integration | Devcontainer guidance |
| --- | --- | --- |
| `apps.d/10-colima.zsh` | Optional host-side Colima startup under `~/code` | Keep on host; VS Code owns container attach/build lifecycle |
| `apps.d/20-headroom.zsh` | Host proxy at `127.0.0.1:8787` | Use `host.docker.internal` from containers and pass only non-secret endpoint settings |
| `apps.d/30-llama-cpp.zsh` | Apple Metal llama.cpp binaries | Host service; containers call a host endpoint |
| `apps.d/40-goose.zsh` | Host ACP wrappers under `~/prompthub/clients/goose` | Keep host wrappers unless the agent image owns ACP clients |
| `apps.d/50-prompthub.zsh` | Host PromptHub venv/router at port 9090 | Prefer a Compose service or dedicated container; do not bind the host venv |
| `apps.d/60-vault-writer.zsh` | Host wrappers using local secrets | Keep host-side; never copy Keychain access into a container image |
| `apps.d/70-ai-clients.zsh` | Host model/API defaults | Translate loopback endpoints to `host.docker.internal` inside containers |

The framework also exposes host workflow commands such as `zsh-doctor`,
`node-doctor`, `zsh-recompile`, `zsh-rebuild-completions`, `restart-zsh`,
`colima-start`, `colima-stop`, `colima-status`, `headroom-codex`,
`headroom-claude`, `headroom-doctor`, `codex-local`, `claude-local`,
`goose-local`, and `prompthub-keys`. These are shell/workstation controls, not
devcontainer dependencies. Recreate their underlying project actions inside
the container only when a project needs them, rather than copying the Zsh
autoload directory into the image.

## Devcontainer starting point

For a project such as Cherry, use a project-owned `.devcontainer/` directory
with a Dockerfile or feature that installs the project runtime. The important
properties are:

```json
{
  "name": "project-dev",
  "build": { "dockerfile": "Dockerfile" },
  "remoteEnv": {
    "OPENAI_BASE_URL": "http://host.docker.internal:8787/v1",
    "LM_STUDIO_API_URL": "http://host.docker.internal:1234/v1"
  },
  "postCreateCommand": "pnpm install --frozen-lockfile"
}
```

The Dockerfile should install Node 24 and activate the project's declared
pnpm version (`10.27.0` for Cherry). Add Python, Rust, Go, or .NET only when
the project manifest requires them. Keep `colima`, `docker`, `code`, Keychain
helpers, and host model servers outside the image.

## Migration order

1. Repair or remove stale pnpm launchers; make the declared pnpm global state
   authoritative.
2. Correct PATH precedence so pnpm does not lose to the npm compatibility bin.
3. Add a per-project `.devcontainer/devcontainer.json` and Dockerfile.
4. Install runtimes from project metadata and dependencies from the lockfile.
5. Expose only required host services through `host.docker.internal`.
6. Add project-specific CLIs to manifests or the image, then remove reliance on
   host globals.
7. Validate with VS Code's Dev Containers extension, `docker context show`,
   `docker compose config`, and the project's own test commands.
