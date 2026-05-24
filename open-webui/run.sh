#!/bin/bash
set -e

OPTIONS=/app/backend/data/options.json

if [ ! -f "$OPTIONS" ]; then
    echo "WARNING: No options file found at $OPTIONS, using open-webui's defaults"
else
    # --- Set environment variables from options ---

    while IFS= read -r entry; do
        [ -z "$entry" ] && continue

        key="${entry%%=*}"
        value="${entry#*=}"

        if [ -z "$value" ]; then
            echo "WARNING: Skipping env_var with empty value: $key"
            continue
        fi

        echo "INFO: Setting env var: $key"
        export "$key=$value"
    done < <(jq -r '.env_vars[]? | "\(.name)=\(.value // "")"' "$OPTIONS")
fi

# Run the open-webui start script
cd /app/backend
exec bash start.sh
