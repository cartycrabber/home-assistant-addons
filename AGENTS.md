# Home Assistant Apps Repository

A personal collection of Home Assistant apps (formerly known as addons), published publicly. Each app lives in its own subdirectory and has a companion `AGENTS.md` with app-specific context.

## Priorities

1. **Privacy & Security** — apps run self-hosted; no data should leave the local network unintentionally. Sensitive config values must not be stored in plain text where avoidable.
2. **Reliability** — apps should start cleanly, fail loudly with useful log output, and degrade gracefully.
3. **Convenience** — minimize friction for the user; prefer sensible defaults and ingress access over manual port configuration.

## App Structure

Every app follows the standard HA app layout:

```
<app-slug>/
  config.yaml        # HA app manifest (name, version, slug, schema, ports, ingress, image)
  Dockerfile         # Builds the app image; typically a thin wrapper on an upstream image
  run.sh             # Entrypoint: bridges /data/options.json → env vars → upstream start script
  CHANGELOG.md       # Version history
  DOCS.md            # User-facing documentation shown in the HA UI
  README.md          # GitHub-facing summary
  translations/
    en.yaml          # Config option labels/descriptions for the HA UI
  icon.png
  logo.png
```

## Build & CI

- Images are published to `ghcr.io/cartycrabber/app-<slug>` via GitHub Actions.
- The `image` key in `config.yaml` must reference this registry path. Comment it out during local development so the supervisor builds locally instead, but don't forgot to uncomment it before committing.
- `BUILD_VERSION` is injected by the HA builder from `config.yaml`'s `version` field; the Dockerfile must accept it as an `ARG`.
- Bump `version` in `config.yaml` and update `CHANGELOG.md` before merging to `main` — the build workflow tags and pushes on merge.
- `dependabot.yaml` and per-app update workflows keep upstream image versions current; review auto-update PRs before merging.

## Local Development

- Dev environment: the `.devcontainer.json` devcontainer with `ha` CLI and a local Supervisor instance.
- VSCode tasks (`.vscode/tasks.json`) cover Install, Start, and Rebuild+Start for each app.
- Run `supervisor_run` to start the local HA instance (or use the "Start Home Assistant" task).
