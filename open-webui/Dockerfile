# BUILD_VERSION is automatically injected by the HA builder from config.yaml version.
# For local builds: docker build --build-arg BUILD_VERSION=0.9.5 .
ARG BUILD_VERSION=0.9.5
FROM ghcr.io/open-webui/open-webui:${BUILD_VERSION}

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]

LABEL \
    org.opencontainers.image.title="Home Assistant App: Open WebUI" \
    org.opencontainers.image.description="Self-hosted AI platform with Ollama and OpenAI API support." \
    org.opencontainers.image.source="https://github.com/cartycrabber/home-assistant-addons" \
    org.opencontainers.image.licenses="Apache License 2.0"
