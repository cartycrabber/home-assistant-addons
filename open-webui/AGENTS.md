# open-webui App

A thin wrapper around the official [`ghcr.io/open-webui/open-webui`](https://github.com/open-webui/open-webui) image. No custom application logic — the app exists solely to integrate Open WebUI into the HA supervisor lifecycle and surface its configuration through the HA UI.

## Architecture

- **Dockerfile**: pulls the upstream image pinned to `BUILD_VERSION` and copies in `run.sh`.
- **run.sh**: reads `/app/backend/data/options.json` (see note below), exports each `env_vars` entry as an environment variable, then `exec`s the upstream `start.sh`.
- **Volume**: `data` maps to `/app/backend/data` (not the default `/data`). This means the supervisor-written `options.json` is at `/app/backend/data/options.json`, not `/data/options.json`.

## Configuration Schema

The only user-facing option is a list of environment variables:

```yaml
options:
  env_vars: []
schema:
  env_vars:
    - name: str
      value: str
```

All Open WebUI tunables are passed through this list. See the [upstream env reference](https://docs.openwebui.com/reference/env-configuration) for available variables. Note that `PersistentConfig` variables are only applied on first startup.

## Ingress & Ports

- Ingress is always enabled; Open WebUI is accessible from the HA sidebar without any extra configuration.
- Direct host-port access is opt-in: the `8080/tcp` port mapping defaults to `null` (disabled). Users set a port number in the app's _Network_ settings to enable external access.

## Version Updates

`.github/workflows/update-open-webui.yaml` automatically opens PRs bumping `version` in `config.yaml` and `ARG BUILD_VERSION` in `Dockerfile` when a new upstream release is published. Review and merge these PRs; the build workflow publishes the new image on merge to `main`.
