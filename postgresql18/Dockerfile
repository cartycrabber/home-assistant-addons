# BUILD_VERSION is automatically injected by the HA builder from config.yaml version.
# For local builds: docker build --build-arg BUILD_VERSION=18.4 .
ARG BUILD_VERSION=18.4
FROM postgres:${BUILD_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=5 \
    CMD pg_isready || exit 1

CMD ["/run.sh"]

LABEL \
    org.opencontainers.image.title="Home Assistant App: PostgreSQL 18" \
    org.opencontainers.image.description="PostgreSQL 18 database server." \
    org.opencontainers.image.source="https://github.com/cartycrabber/home-assistant-addons" \
    org.opencontainers.image.licenses="PostgreSQL License"
