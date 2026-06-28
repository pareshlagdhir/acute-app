# Design: Postgres + pgvector + Redis + Alembic for `acute-api`

**Date:** 2026-06-28
**Status:** Approved
**Scope:** `acute-api/` (FastAPI backend)

## Goal

Add a persistence and caching layer to the currently-stateless `acute-api`
service: a PostgreSQL database (vector-AI ready via pgvector), a Redis instance,
local infrastructure via Docker Compose, and Alembic database migrations wired to
an async SQLAlchemy stack.

## Decisions

| Decision | Choice |
| --- | --- |
| Compose scope | Infra only (DB + Redis). FastAPI app continues to run on the host via uvicorn. |
| ORM / DB layer | SQLAlchemy 2.0 async + `asyncpg` driver. |
| Vector support | pgvector on Postgres (`CREATE EXTENSION vector`). |
| Image versions | Latest stable: Postgres 17 (`pgvector/pgvector:pg17`), Redis 8 (`redis:8-alpine`). |
| Baseline migration | Enable pgvector extension only. No domain tables yet. |
| Database name | `acute-db` |
| Database user | `acute-user` (owns `acute-db`, therefore holds full privileges on it). |

## Architecture

The FastAPI app gains a thin `app/db/` package that owns the async SQLAlchemy
engine, session factory, declarative base, and a Redis client factory. Alembic
lives at `acute-api/alembic/` and shares the same `DATABASE_URL` and
`Base.metadata` so autogenerate stays consistent with the app's models. Docker
Compose provisions the two backing services locally; the app connects to them
over `localhost`.

```
acute-api/
├── docker-compose.yml          # db (pgvector/pg17) + redis (8-alpine)
├── alembic.ini                 # URL sourced from settings/env, not hardcoded
├── alembic/
│   ├── env.py                  # async env, imports Base.metadata
│   ├── script.py.mako
│   └── versions/
│       └── 0001_enable_pgvector.py
└── app/
    ├── core/config.py          # + DATABASE_URL, REDIS_URL
    └── db/
        ├── __init__.py
        ├── base.py             # DeclarativeBase
        ├── session.py          # async engine + async_sessionmaker + get_db dep
        └── redis.py            # Redis client factory from REDIS_URL
```

## Components

### Docker Compose (`acute-api/docker-compose.yml`)

Two services, infrastructure only.

- **`db`** — image `pgvector/pgvector:pg17` (Postgres 17 with the `vector`
  extension available).
  - Env: `POSTGRES_DB=acute-db`, `POSTGRES_USER=acute-user`,
    `POSTGRES_PASSWORD` (from `.env`).
  - Port `5432:5432`.
  - Named volume `acute-pgdata` mounted at `/var/lib/postgresql/data`.
  - Healthcheck: `pg_isready -U acute-user -d acute-db`.
  - Because `acute-user` is created as the owner of `acute-db`, it already holds
    full privileges on that database; `CREATE EXTENSION` succeeds as DB owner. No
    extra `GRANT` statements required.
- **`redis`** — image `redis:8-alpine` (latest stable).
  - Port `6379:6379`.
  - Named volume `acute-redisdata` with AOF persistence (`--appendonly yes`).
  - Healthcheck: `redis-cli ping`.
  - Serves as the vector-AI-ready cache/queue layer; durable vector storage lives
    in pgvector.

### Dependencies (`pyproject.toml`)

Add to main `dependencies`:

- `sqlalchemy[asyncio]>=2.0`
- `asyncpg>=0.30`
- `alembic>=1.13`
- `redis>=5.0`
- `pgvector>=0.3`

No new dev dependencies required.

### Config (`app/core/config.py`)

Add settings:

- `DATABASE_URL: str` — default
  `postgresql+asyncpg://acute-user:acute-pass@localhost:5432/acute-db`.
- `REDIS_URL: str` — default `redis://localhost:6379/0`.

### Database package (`app/db/`)

- `base.py` — `Base(DeclarativeBase)`. Future models subclass this; Alembic reads
  `Base.metadata` for autogenerate.
- `session.py` — `create_async_engine(DATABASE_URL)`, `async_sessionmaker`, and an
  async `get_db()` FastAPI dependency yielding a session.
- `redis.py` — factory returning a `redis.asyncio.Redis` client built from
  `REDIS_URL`.

### Alembic

- Initialised at `acute-api/alembic/` with an **async** `env.py` that builds the
  async engine from `settings.DATABASE_URL` and uses `Base.metadata` as the target
  metadata for autogenerate.
- `alembic.ini` keeps the URL out of the file; `env.py` reads it from settings.
- Baseline migration `0001_enable_pgvector`:
  - upgrade: `op.execute("CREATE EXTENSION IF NOT EXISTS vector")`
  - downgrade: `op.execute("DROP EXTENSION IF EXISTS vector")`

### Env + docs

- `.env.example` — add `POSTGRES_PASSWORD`, `DATABASE_URL`, `REDIS_URL`.
- `CLAUDE.md` — add dev commands: `docker compose up -d` to start infra, and
  `alembic upgrade head` to apply migrations.

## Data Flow

1. `docker compose up -d` starts Postgres (with pgvector available) and Redis.
2. `alembic upgrade head` connects via the async engine and enables the `vector`
   extension on `acute-db`.
3. The FastAPI app, running on the host, obtains DB sessions through `get_db` and a
   Redis client through the `redis.py` factory, using `localhost` URLs.

## Error Handling

- Compose healthchecks gate readiness; the DB is not marked healthy until
  `pg_isready` passes.
- The async engine surfaces connection errors to callers; no swallowing.
- The baseline migration is idempotent (`IF NOT EXISTS` / `IF EXISTS`).

## Testing / Verification

- `docker compose up -d` then `docker compose ps` shows both services healthy.
- `alembic upgrade head` succeeds; `\dx` in `acute-db` lists the `vector`
  extension.
- `alembic downgrade -1` removes the extension cleanly.
- Existing pytest suite continues to pass (no behavioural change to OTP/health
  endpoints).

## Out of Scope (YAGNI)

- Containerising the FastAPI app itself.
- Any domain tables or models (added per-feature later).
- Redis Stack / RediSearch vector indexing (pgvector covers durable vectors).
- Production deployment configuration, secrets management, connection pooling
  tuning.
