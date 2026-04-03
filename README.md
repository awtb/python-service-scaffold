# 🧱 Python Service Scaffold

Minimal scaffold for small Python services.

This repository generates projects from explicit building blocks instead of one large fixed template. The goal is to start small, keep the generated code understandable, and let each service grow by adding only the blocks it actually needs.

## What This Scaffold Is For

Use this scaffold when you want a service that is:

- small at the start
- explicit in structure
- easy to strip down
- easy to extend
- understandable without scaffold internals

This scaffold is not a framework and not a runtime plugin system. It is generation-time composition.

## Mental Model

A generated project is assembled from a few block types:

- runtimes: ways to run the service, such as CLI, HTTP, or stream
- integrations: infrastructure such as PostgreSQL or Redis
- components: optional adapters such as templating or Telegram bot support
- features: ready-to-use business slices such as the sample users package
- tooling: project-level setup such as generated tests or pre-commit

The main rule is composition over magic. If a block is not selected, it should not appear in the generated codebase.

## Blocks vs Packages

There are two different views of the scaffold:

1. The block view answers: what was selected when the project was generated?
2. The package view answers: where does code live inside the generated project?

Examples:

- the HTTP runtime is a block, and its code lives under `runtimes/http/`
- the Redis integration is a block, and its code usually lives under `infra/redis/` plus `protocols/redis/`
- the templating component is a block, and its code usually lives under `infra/templating/` plus `protocols/templating/`
- the users feature is a block, and its code lives under `features/users/`

So:

- blocks describe what is included
- packages describe where the included code is placed

## Current Blocks

The scaffold currently supports:

- CLI runtime, included by default
- HTTP runtime with FastAPI
- Telegram bot webhook component with aiogram, requires HTTP runtime
- stream runtime with FastStream, requires Redis
- Redis integration
- PostgreSQL integration
- users feature package, requires PostgreSQL
- templating component with an async Jinja adapter
- generated tests
- pre-commit setup

## Generated Structure

Generated projects use a small, predictable layout:

- `runtimes/` for entrypoints and transport-specific wiring
- `features/` for business capabilities
- `infra/` for technical adapters and integration code
- `dto/` for shared data-transfer objects such as pagination
- `protocols/` for interfaces between layers
- `tests/` for grouped unit, integration, and end-to-end checks, when tests are enabled

These packages are not separate block types. They are the fixed structure used to place whatever blocks were enabled.

The placement rule is:

- runtime-specific code stays in `runtimes/`
- business logic stays in `features/`
- infrastructure code stays in `infra/`
- shared data shapes stay in `dto/`
- shared interfaces stay in `protocols/`
- feature-local use-case data should live in `dto.py`
- feature-local interfaces should live in `protocols.py`

Within a feature package, prefer:

- `dto.py` for use-case input/output data that crosses feature boundaries
- `protocols.py` for feature-local interfaces

Keep the separation strict:

- DTOs represent request/response shapes at the use-case boundary
- protocols represent collaborator behavior that the use case depends on
- use cases are the place where DTOs and protocols meet

This scaffold does not generate a separate business `models` layer by default. Persistence models stay under `infra/db/models/`, transport schemas stay under runtime packages, and application data shapes live in DTOs.

## Quick Start

Generate a project directly from GitHub with Copier:

```bash
copier copy gh:awtb/python-service-scaffold my-service
```

Or with the full Git URL:

```bash
copier copy https://github.com/awtb/python-service-scaffold.git my-service
```

Then move into the generated project:

```bash
cd my-service
```

## Useful Render Variants

Common variants at a glance:

| Variant | HTTP | TG Bot | Stream | Redis | PostgreSQL | Users | Templating | Tests |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CLI only | no | no | no | no | no | no | no | optional |
| HTTP + PostgreSQL | yes | no | no | no | yes | optional | no | yes |
| HTTP + Telegram | yes | yes | no | no | no | no | no | yes |
| Stream + Redis | no | no | yes | yes | no | no | no | yes |
| Templating only | no | no | no | no | no | no | yes | yes |

Two full examples:

Render a minimal CLI-only service:

```bash
copier copy \
  -d project_slug='cli-service' \
  -d package_name='cli_service' \
  -d include_http_runtime=false \
  -d include_tg_bot_runtime=false \
  -d include_stream_runtime=false \
  -d include_redis_integration=false \
  -d include_postgresql_integration=false \
  -d include_users_feature=false \
  -d include_templating_component=false \
  -d include_tests=false \
  gh:awtb/python-service-scaffold \
  cli-service
```

Render an HTTP service with PostgreSQL and the users feature:

```bash
copier copy \
  -d project_slug='users-service' \
  -d package_name='users_service' \
  -d include_http_runtime=true \
  -d include_tg_bot_runtime=false \
  -d include_stream_runtime=false \
  -d include_redis_integration=false \
  -d include_postgresql_integration=true \
  -d include_users_feature=true \
  -d include_templating_component=false \
  -d include_tests=true \
  gh:awtb/python-service-scaffold \
  users-service
```

Use the matrix above to toggle only the flags you need for other variants.

## Template Defaults

The default Copier flow currently enables:

- CLI runtime
- HTTP runtime
- generated tests

And leaves these opt-in:

- Telegram bot
- stream runtime
- Redis
- PostgreSQL
- users feature
- templating
- pre-commit

Generated tests are enabled by default and can be disabled with `include_tests=false`.

## Generated Test Suite

When tests are enabled, generated projects organize them by scope:

- `tests/e2e/` for HTTP API behavior
- `tests/integration/` for infrastructure-backed checks
- `tests/unit/` for isolated component checks
- `tests/support/` for shared fixtures and test-only helpers

Current generated coverage is intentionally small:

- HTTP runtime e2e checks when HTTP is enabled
- users API e2e checks when `http + postgresql integration + users feature` are enabled
- PostgreSQL integration check when PostgreSQL is enabled
- templating unit check when the templating component is enabled

PostgreSQL-backed tests use a disposable testcontainer. During test database setup, the generated fixture prefers `alembic upgrade head` when real Alembic revisions exist, and otherwise falls back to metadata-based schema creation.

Telegram-specific and stream-specific generated tests are intentionally not included right now.

## Maintainer Workflow

This repository includes a few helper targets for working on the scaffold itself:

- `make render` renders one project variant into `examples/generated/<project-slug>`
- `make test-rendered` renders a variant and runs that generated project's `make test`
- `make compose-config-rendered` renders a variant and validates `compose.yaml`
- `make check-template` runs the default render plus several predefined render variants
- `make clean-generated` removes rendered examples under `examples/generated/`

Example:

```bash
make test-rendered \
  PROJECT_SLUG='users-service' \
  PACKAGE_NAME='users_service' \
  INCLUDE_HTTP_RUNTIME=true \
  INCLUDE_POSTGRESQL_INTEGRATION=true \
  INCLUDE_USERS_FEATURE=true \
  INCLUDE_TESTS=true
```

## Design Intent

The scaffold tries to keep a generated service easy to reason about:

- shared bootstrap is small
- runtime code is isolated
- integrations are explicit
- scaffolded code is easy to delete or replace
- no hidden architecture is required to understand the project
