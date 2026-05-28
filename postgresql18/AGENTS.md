# postgresql18 App

A thin wrapper around the official [`postgres:18`](https://hub.docker.com/_/postgres) Docker image. Integrates PostgreSQL 18 into the HA Supervisor lifecycle with native backup support, SSL/TLS, and a structured configuration schema.

## Architecture

- **Dockerfile**: pulls the upstream `postgres:${BUILD_VERSION}` image, installs `jq`, and copies in `run.sh`.
- **run.sh**: reads `/var/lib/postgresql/options.json` (see note below), writes the password securely to `/run/secrets/postgres-password`, sets env vars, builds `-c` flags, and `exec`s `docker-entrypoint.sh postgres`.
- **Volume**: `data` maps to `/var/lib/postgresql` (PG18's volume root). The actual cluster lives at `/var/lib/postgresql/18/docker`. The Supervisor writes `options.json` to `/var/lib/postgresql/options.json`.

## Non-Standard options.json Path

Because the `data` map is mounted at `/var/lib/postgresql` (not the default `/data`), the Supervisor writes `options.json` to `/var/lib/postgresql/options.json`. `run.sh` explicitly reads from this path.

## Configuration Schema

| Option | Type | Default | Notes |
|---|---|---|---|
| `postgres_user` | `str` | `postgres` | Set at initdb; read-only after first start |
| `postgres_password` | `password` | _(required)_ | Written to `/run/secrets/`; never in process env |
| `postgres_db` | `str` | `""` | Empty → defaults to `postgres_user` |
| `initdb_args` | `str` | `--data-checksums` | Passed to `initdb` on first start only |
| `ssl` | `bool` | `false` | Copies cert/key from `/ssl/`; enforces TLSv1.2+ |
| `ssl_certfile` | `str` | `fullchain.pem` | Certificate filename in `/ssl/` |
| `ssl_keyfile` | `str` | `privkey.pem` | Private key filename in `/ssl/` |
| `extra_args` | `[str]` | `[]` | `-c key=value` flags passed to the `postgres` binary |

## Ports

- `5432/tcp`: PostgreSQL wire protocol. Defaults to host port 5432. Users can change or disable in the app's _Network_ settings.

## Key Implementation Details

- **Password security**: password is written to `/run/secrets/postgres-password` (mode 400) and passed via `POSTGRES_PASSWORD_FILE`. The raw password is never exported as an environment variable.
- **Docker entrypoint**: `exec docker-entrypoint.sh postgres [args]` ensures the upstream entrypoint's `initdb` logic and signal handling run correctly. Do NOT `exec postgres` directly.
- **SSL key ownership**: after copying the key, `chown postgres:postgres` is applied so the postgres process (uid 999) can read it.
- **addon_config**: `/config/postgresql.conf` and `/config/pg_hba.conf` are detected at startup and passed via `-c config_file=` / `-c hba_file=`. Host path: `/addon_configs/local_postgresql18/`.
- **`init: false`**: The postgres image manages its own process; Docker's default init must be disabled.
- **`backup: cold`**: HA stops the app for the duration of a snapshot. The entire `/var/lib/postgresql` volume (cluster + options.json) is captured consistently.

## Version Updates

`.github/workflows/update-postgresql18.yaml` polls the Docker Hub tags API weekly for new `18.x` tags, bumps `version` in `config.yaml` and `ARG BUILD_VERSION` in `Dockerfile`, and opens a PR. Review and merge — the build workflow publishes the new image on merge to `main`.
