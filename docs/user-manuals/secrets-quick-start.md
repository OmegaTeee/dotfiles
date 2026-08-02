# Secrets quick start

This framework stores secret values in the macOS login Keychain. It loads them
only when a command needs them. Do not put secret values in `.zshrc`,
`.config/zsh`, `.npmrc`, `devcontainer.json`, shell history, or this manual.

## How the lookup works

The function in `.config/zsh/core/40-secrets.zsh` uses two Keychain fields:

- Account: the current macOS user, from `$USER`.
- Service: the exact service name passed to `secret_export`.

The service name is usually the same as the environment variable name. A few
entries use a different service name. Use the table below as the source of
truth.

## Profiles

`with_secrets` supports four profiles:

| Profile | Required entry | Optional entries | Extra exports |
| --- | --- | --- | --- |
| `github` | `GITHUB_API_KEY`, `GITHUB_PAT` | none | `GITHUB_PERSONAL_ACCESS_TOKEN`, `GITHUB_PAT_TOKEN` from `GITHUB_PAT` |
| `ai` | `PH_API_TOKEN` | `LM_API_TOKEN`, `HUGGINGFACE_API_KEY`, `OPENROUTER_KEY`, `LMSTUDIO_API_KEY`, `OLLAMA_API_KEY`, `GROQ_API_KEY`, `MISTRAL_API_KEY`, `GEMINI_API_KEY` | `OPENAI_API_KEY`, `HF_TOKEN`, `LMSTUDIO_TOKEN` |
| `services` | none | `OPENCLAW_GATEWAY_TOKEN`, `DISCORD_BOT_API_KEY`, `DISCORD_BOT_TOKEN`, `DISCORD_CLIENT_ID`, `PARALLEL_API_KEY`, `CLOUDFLARE_AUTHTOKEN`, `PUBLIC_CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`, `NETLIFY_AUTH_TOKEN` | none |
| `all` | none; the profile loaders are best-effort | all entries from the three profiles | all profile exports |

The `ai` profile uses these service-to-variable mappings:

| Environment variable | Keychain service |
| --- | --- |
| `PH_API_TOKEN` | `PH_API_TOKEN` |
| `LM_API_TOKEN` | `LM_API_TOKEN` |
| `HUGGINGFACE_API_KEY` | `HUGGINGFACE_API_KEY` |
| `OPENROUTER_API_KEY` | `OPENROUTER_KEY` |
| `LM_STUDIO_API_KEY` | `LMSTUDIO_API_KEY` |
| `OLLAMA_API_KEY` | `OLLAMA_API_KEY` |
| `GROQ_API_KEY` | `GROQ_API_KEY` |
| `MISTRAL_API_KEY` | `MISTRAL_API_KEY` |
| `GEMINI_API_KEY` | `GEMINI_API_KEY` |

The service name and variable name differ for `OPENROUTER_API_KEY`,
`LM_STUDIO_API_KEY`, and the service entries listed in the profile table.

## Add or update a secret

Open a fresh Zsh shell so the functions are available, then enter the value
without placing it in the command line:

```zsh
read -r -s 'secret_value?Secret value: '
print
security add-generic-password \
  -a "$USER" \
  -s "PH_API_TOKEN" \
  -w "$secret_value" \
  -U
unset secret_value
```

Replace `PH_API_TOKEN` with the required Keychain service name. The `-U` flag
updates an existing item or adds it when no matching item exists.

Use a unique service name for a new variable. Do not reuse a service name for
two unrelated credentials.

## Verify an entry without printing it

Check only the exit status. This confirms that the Keychain item exists without
writing its value to the terminal:

```zsh
if security find-generic-password \
  -a "$USER" \
  -s "PH_API_TOKEN" \
  >/dev/null 2>&1; then
  print 'Keychain entry exists'
else
  print -u2 'Keychain entry is missing'
fi
```

To test a loaded variable without displaying it:

```zsh
secret_export PH_API_TOKEN PH_API_TOKEN
[[ -n "$PH_API_TOKEN" ]] && print 'Secret loaded'
unset PH_API_TOKEN
```

Do not use `security ... -w`, `printenv`, `env`, or `echo` to display a secret
while troubleshooting.

## Run one command with secrets

`with_secrets` loads the selected profile in a child process. The variables are
available to the command, then disappear when the command exits:

```zsh
with_secrets github gh auth status
with_secrets ai codex --version
with_secrets services ./scripts/check-services.zsh
with_secrets all ./scripts/publish.zsh
```

This is the preferred pattern for commands that do not need a persistent shell
environment. The parent shell does not receive the exported values.

Use `secret_export` only when a value must be available in the current shell:

```zsh
secret_export NETLIFY_AUTH_TOKEN NETLIFY_AUTH_TOKEN
netlify deploy
unset NETLIFY_AUTH_TOKEN
```

## Remove or rotate a secret

First revoke the old token at its provider. Then replace it with the update
command above, or delete the Keychain item when the variable is no longer
needed:

```zsh
security delete-generic-password \
  -a "$USER" \
  -s "OLD_SERVICE_NAME"
```

Run the verification check after the change. A missing optional entry is normal
for profiles that do not use that service. A missing required entry stops the
`github` or `ai` profile command. The `all` profile is best-effort and continues
when an individual profile entry is missing.

## Non-secret environment variables

Keep non-secret defaults in `.config/zsh/core/10-environment.zsh`. Keep PATH
changes in `.config/zsh/core/20-path.zsh`. After an edit:

1. Synchronize the copy-installed tree under `~/.config/zsh/`.
2. Start a fresh Zsh shell.
3. Run `zsh-doctor`.
4. Check the effective value with a non-secret command such as `print
   "$PROJECT_FOLDER"`.

Never use this workflow to store API keys, passwords, npm tokens, or private
certificates. Use Keychain or the secret store provided by the target service.

## Devcontainer note

Do not copy the macOS Keychain or `.config/zsh/core/40-secrets.zsh` into a
container. A devcontainer should receive only the secrets that its task needs,
through the VS Code or CI secret mechanism. Host services can use
`host.docker.internal`, but credentials must remain outside the image and
source tree.
