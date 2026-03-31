# 🧱 Python service scaffold

Minimal scaffold for Python services.

This project generates small service templates from explicit building blocks.

It is designed to keep the starting point predictable, easy to understand, and easy to strip down.

## Goals

- small baseline
- explicit composition
- isolated runtime code
- optional integrations
- minimal boilerplate

## Baseline

The baseline generated project is intentionally small. It includes the package layout, CLI entrypoint, shared settings, logging setup, and the common `features`, `models`, `protocols`, and `infra` packages.

With plain `copier copy .`, the default baseline also enables the HTTP runtime. PostgreSQL, the users feature, and pre-commit remain opt-in.

## Current Template

The current template exposes these blocks:

- CLI runtime, included by default
- HTTP runtime with FastAPI, optional in the template and enabled in Copier defaults
- Telegram bot component with aiogram webhook handling, optional and requires HTTP runtime
- stream runtime with FastStream, optional and requires Redis integration
- Redis integration, optional
- PostgreSQL integration, optional
- users feature package, optional and requires PostgreSQL
- pre-commit setup, optional

The mental model also includes presets and structure rules, but the concrete switches in the current template are the runtime, integration, and feature blocks above.

## Structure

A generated project is organized around a few small, explicit packages:

- `runtimes/` contains entrypoints and runtime-specific wiring. A runtime is a way to run the service, such as the CLI runtime or the HTTP runtime.
- `features/` contains business capabilities. Feature code should hold use cases and domain-facing contracts rather than transport details.
- `infra/` contains infrastructure adapters and shared technical concerns, such as logging and optional database access.
- `models/` contains shared business models used across features and runtimes.
- `protocols/` contains interfaces and contracts between business code and infrastructure.

Optional parts are added only when selected:

- `infra/redis/` is included when the Redis block is enabled.
- `infra/db/` and `alembic/` are included when the PostgreSQL block is enabled.
- `features/users/` is included when the users block is enabled.
- `runtimes/http/` is included when the HTTP runtime is enabled.
- `runtimes/tg_bot/` is included when the Telegram bot component is enabled with the HTTP runtime.
- `runtimes/stream/` is included when the stream runtime and Redis block are enabled together.
- `tests/` contains checks for the blocks that were rendered into the project.

The main rule is separation of concerns: runtime code stays in runtimes, business code stays in features, and infrastructure remains explicit and replaceable.

## Usage

Render a project with Copier:

```bash
copier copy .
```

Or render the example project with the repo `Makefile`:

```bash
make render
```

The generated example is written to `examples/generated/health-service/` by default.
