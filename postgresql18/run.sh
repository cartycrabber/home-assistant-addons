#!/bin/bash
set -euo pipefail

OPTIONS=/var/lib/postgresql/options.json

if [ ! -f "$OPTIONS" ]; then
    echo "ERROR: Options file not found at $OPTIONS" >&2
    exit 1
fi

# Explicit environment variables
POSTGRES_USER=$(jq -r '.postgres_user // "postgres"' "$OPTIONS")
POSTGRES_PASSWORD=$(jq -r '.postgres_password' "$OPTIONS")
POSTGRES_DB=$(jq -r '.postgres_db // ""' "$OPTIONS")
INITDB_ARGS=$(jq -r '.initdb_args // ""' "$OPTIONS")
SSL=$(jq -r '.ssl // false' "$OPTIONS")
SSL_CERTFILE=$(jq -r '.ssl_certfile // "fullchain.pem"' "$OPTIONS")
SSL_KEYFILE=$(jq -r '.ssl_keyfile // "privkey.pem"' "$OPTIONS")

# Docker secret for password
mkdir -p /run/secrets
chmod 700 /run/secrets
printf '%s' "$POSTGRES_PASSWORD" > /run/secrets/postgres-password
chmod 400 /run/secrets/postgres-password
unset POSTGRES_PASSWORD

export POSTGRES_PASSWORD_FILE=/run/secrets/postgres-password

[ -n "$POSTGRES_USER" ] && export POSTGRES_USER
[ -n "$POSTGRES_DB" ] && export POSTGRES_DB
[ -n "$INITDB_ARGS" ] && export POSTGRES_INITDB_ARGS="$INITDB_ARGS"

# Build -c args array
EXTRA_C_ARGS=()
while IFS= read -r arg; do
    [ -n "$arg" ] && EXTRA_C_ARGS+=("-c" "$arg")
done < <(jq -r '.extra_args[]? | select(.name != null and .name != "" and .value != null and .value != "") | "\(.name)=\(.value)"' "$OPTIONS")

# ── SSL configuration ─────────────────────────────────────────────────────────
if [ "$SSL" = "true" ]; then
    # Reject path separators to prevent traversal outside /ssl
    [[ "$SSL_CERTFILE" == */* ]] && { echo "ERROR: ssl_certfile must be a bare filename, not a path: $SSL_CERTFILE" >&2; exit 1; }
    [[ "$SSL_KEYFILE"  == */* ]] && { echo "ERROR: ssl_keyfile must be a bare filename, not a path: $SSL_KEYFILE" >&2; exit 1; }

    CERT_SRC="/ssl/${SSL_CERTFILE}"
    KEY_SRC="/ssl/${SSL_KEYFILE}"

    [ ! -f "$CERT_SRC" ] && { echo "ERROR: SSL cert not found: $CERT_SRC" >&2; exit 1; }
    [ ! -f "$KEY_SRC"  ] && { echo "ERROR: SSL key not found: $KEY_SRC" >&2; exit 1; }

    SSL_DIR=/var/lib/postgresql/ssl
    mkdir -p "$SSL_DIR"
    cp "$CERT_SRC" "$SSL_DIR/server.crt"
    cp "$KEY_SRC"  "$SSL_DIR/server.key"
    chown postgres:postgres "$SSL_DIR/server.crt" "$SSL_DIR/server.key"
    chmod 600 "$SSL_DIR/server.key"

    EXTRA_C_ARGS+=(
        "-c" "ssl=on"
        "-c" "ssl_cert_file=$SSL_DIR/server.crt"
        "-c" "ssl_key_file=$SSL_DIR/server.key"
        "-c" "ssl_min_protocol_version=TLSv1.2"
    )
    echo "INFO: SSL/TLS enabled (cert: $CERT_SRC)"
fi

# ── Optional custom config files from addon_config ────────────────────────────
[ -f /config/postgresql.conf ] && EXTRA_C_ARGS+=("-c" "config_file=/config/postgresql.conf")
[ -f /config/pg_hba.conf ]     && EXTRA_C_ARGS+=("-c" "hba_file=/config/pg_hba.conf")

# ── Start PostgreSQL ──────────────────────────────────────────────────────────
echo "INFO: Starting PostgreSQL as user: $POSTGRES_USER"
exec docker-entrypoint.sh postgres "${EXTRA_C_ARGS[@]}"
