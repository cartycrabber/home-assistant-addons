# Home Assistant App: Open WebUI

Open WebUI is a self-hosted AI platform that provides a web interface for
interacting with large language models. It supports Ollama (for local models)
and any OpenAI-compatible API, and runs entirely on your own hardware.

## Requirements

Open WebUI needs at least one LLM backend to be useful:

- **Ollama** (recommended for local models): install the Ollama Home Assistant
  app or run Ollama on another machine on your network
- **OpenAI-compatible API**: any provider that implements the OpenAI API
  (OpenAI, Anthropic via proxy, Groq, local LM Studio, etc.)

## Accessing the UI

**Home Assistant sidebar** — Check "Show in sidebar" to access Open WebUI from
within Home Assistant.

**Direct port access** — disabled by default. To expose Open WebUI directly on
a host port for access from outside your HA instance, set a port number
in the app configuration under _Network_. Leave it empty (null) to keep it
disabled.

## Configuration

### Environment Variables

Many Open-WebUI settings can be configured via the _Environment Variables_ list.
Note that some variables (marked `PersistentConfig` in the docs) are only read
on the first startup. For the full list of available variables see:
https://docs.openwebui.com/reference/env-configuration

Common examples:

```
OLLAMA_BASE_URL=http://homeassistant.local:11434
WEBUI_ADMIN_EMAIL=admin@example.com
ENABLE_SIGNUP=false
OPENAI_API_BASE_URL=https://api.openai.com/v1
OPENAI_API_KEY=!secret open_api_key
```

> **Security note**: values in the _Environment Variables_ list are visible in
> plain text in the HA UI. For sensitive values use HA's [`secrets.yaml`](https://www.home-assistant.io/docs/configuration/secrets/) and
> reference them with `!secret` in the app configuration.
