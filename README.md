# 🧱 Python Service Scaffold

[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-inverted-border-orange.json)](https://github.com/copier-org/copier)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Minimal Python service generator. Only selected blocks appear in the output — no hidden architecture, no magic.

## Agentic Development

Every generated project includes an `AGENTS.md` — a machine-readable description of the project's architecture, conventions, and layer boundaries. This makes the codebase immediately navigable by AI coding agents (Claude Code, Codex, Cursor, etc.) without any manual setup.

## Blocks

| Type | Options |
|---|---|
| **runtimes** | CLI (default), HTTP (FastAPI), Stream (FastStream + Redis) |
| **integrations** | PostgreSQL, Redis |
| **components** | Telegram bot (aiogram), Jinja2 templating |
| **features** | users (requires PostgreSQL) |
| **tooling** | tests, pre-commit |

## Generated Structure

Example: HTTP + PostgreSQL + users feature.

```
my_service/
├── AGENTS.md                        # architecture context for AI agents
├── Dockerfile
├── Makefile
├── compose.yaml
├── pyproject.toml
├── alembic/                         # present when PostgreSQL is enabled
│   ├── env.py
│   └── versions/
│       └── 0001_create_users_table.py
├── my_service/
│   ├── settings.py
│   ├── dto/                         # shared data-transfer objects (e.g. pagination)
│   ├── features/
│   │   └── users/
│   │       ├── dto.py               # use-case input/output shapes
│   │       ├── protocols.py         # interfaces this feature depends on
│   │       └── use_cases/
│   ├── infra/
│   │   ├── db/                      # SQLAlchemy session, UoW, base repo, models
│   │   ├── logging/
│   │   ├── metrics/
│   │   ├── redis/                   # present when Redis is enabled
│   │   └── templating/              # present when templating is enabled
│   ├── protocols/                   # shared cross-layer interfaces
│   │   ├── db/
│   │   ├── redis/
│   │   └── templating/
│   └── runtimes/
│       ├── cli/
│       ├── http/                    # FastAPI app, routers, schemas, lifecycle
│       │   ├── dependencies/
│       │   ├── exc_handlers/
│       │   ├── middlewares/
│       │   ├── routers/
│       │   └── schemas/
│       ├── stream/                  # present when Stream runtime is enabled
│       └── tg_bot/                  # present when Telegram bot is enabled
└── tests/
    ├── conftest.py
    ├── e2e/                         # HTTP API behavior
    ├── integration/                 # infrastructure-backed checks (testcontainers)
    ├── unit/                        # isolated component checks
    └── support/                     # shared fixtures and helpers
```

## Quick Start

```bash
copier copy gh:awtb/python-service-scaffold my-service
cd my-service
```

## Common Variants

| Variant | HTTP | TG | Stream | Redis | PG | Users |
|---|---|---|---|---|---|---|
| CLI only | — | — | — | — | — | — |
| HTTP + PostgreSQL | ✓ | — | — | — | ✓ | opt |
| HTTP + Telegram | ✓ | ✓ | — | — | — | — |
| Stream + Redis | — | — | ✓ | ✓ | — | — |

<details>
<summary>Example commands</summary>

```bash
# CLI only
copier copy \
  -d project_slug='cli-service' \
  -d include_http_runtime=false \
  -d include_postgresql_integration=false \
  gh:awtb/python-service-scaffold cli-service

# HTTP + PostgreSQL + users
copier copy \
  -d project_slug='users-service' \
  -d include_http_runtime=true \
  -d include_postgresql_integration=true \
  -d include_users_feature=true \
  gh:awtb/python-service-scaffold users-service
```
</details>

## Defaults

Enabled by default: CLI runtime, HTTP runtime, tests.  
Everything else is opt-in.

## Versioning

The scaffold itself is versioned with SemVer.

- The current scaffold version lives in `VERSION`
- Release tags should use the `vX.Y.Z` format
- `make version` prints the current scaffold version

When you want to generate a project from a specific scaffold release, pin the tag explicitly:

```bash
copier copy --vcs-ref v0.1.0 gh:awtb/python-service-scaffold my-service
```

## Tests

Scoped into `e2e/`, `integration/`, `unit/`, `support/`. PostgreSQL tests use a disposable testcontainer. DB setup prefers `alembic upgrade head` when real revisions exist, otherwise falls back to metadata-based schema creation.

For scaffold development: `make check-template`, `make test-rendered`.
