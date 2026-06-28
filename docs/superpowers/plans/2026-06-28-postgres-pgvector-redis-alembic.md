# Postgres + pgvector + Redis + Alembic Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a PostgreSQL (pgvector) + Redis backing layer to `acute-api` with Docker Compose for local infra and Alembic for async migrations.

**Architecture:** Infra-only Docker Compose provisions Postgres 17 (pgvector) and Redis 8 locally; the FastAPI app keeps running on the host. A thin `app/db/` package owns an async SQLAlchemy engine, session factory, declarative `Base`, and a Redis client factory. Alembic shares the app's `DATABASE_URL` and `Base.metadata` for async autogenerate. The baseline migration enables the pgvector extension.

**Tech Stack:** FastAPI, SQLAlchemy 2.0 (async) + asyncpg, Alembic, redis-py (asyncio), pgvector, Docker Compose, Postgres 17 (`pgvector/pgvector:pg17`), Redis 8 (`redis:8-alpine`).

## Global Constraints

- Database name: `acute-db`; database user: `acute-user` (owns the DB → full privileges, no extra GRANTs).
- Images: `pgvector/pgvector:pg17` and `redis:8-alpine` (latest stable).
- DB driver/URL scheme: `postgresql+asyncpg://...`; Redis URL: `redis://...`.
- All DB access is async (async engine, `async_sessionmaker`, async `env.py`).
- Baseline migration enables pgvector only — no domain tables.
- Connection URLs must NOT be hardcoded in `alembic.ini`; they come from `app.core.config.settings`.
- Compose scope is infra-only — do NOT containerise the FastAPI app.
- **No git repository** is present at the repo root. Wherever a step says "Commit", treat it as a checkpoint: stop, confirm the verification output, and move on. Do not run `git` commands unless a repo is later initialised.
- All commands run from `acute-api/` unless stated otherwise. Use the project venv (`pip install -e ".[dev]"`).

---

### Task 1: Add dependencies

**Files:**
- Modify: `acute-api/pyproject.toml`

**Interfaces:**
- Consumes: nothing.
- Produces: importable packages `sqlalchemy`, `asyncpg`, `alembic`, `redis`, `pgvector` for all later tasks.

- [ ] **Step 1: Add runtime dependencies**

Edit the `dependencies` array in `acute-api/pyproject.toml` to add the five entries (keep existing entries):

```toml
[project]
name = "acute-api"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.32.0",
    "httpx>=0.27.0",
    "pydantic>=2.9.0",
    "pydantic-settings>=2.6.0",
    "python-dotenv>=1.0.0",
    "sqlalchemy[asyncio]>=2.0",
    "asyncpg>=0.30",
    "alembic>=1.13",
    "redis>=5.0",
    "pgvector>=0.3",
]
```

- [ ] **Step 2: Install**

Run: `pip install -e ".[dev]"`
Expected: completes successfully; `sqlalchemy`, `asyncpg`, `alembic`, `redis`, `pgvector` resolve.

- [ ] **Step 3: Verify imports**

Run: `python -c "import sqlalchemy, asyncpg, alembic, redis, pgvector; print(sqlalchemy.__version__)"`
Expected: prints a `2.x` version, no ImportError.

- [ ] **Step 4: Checkpoint** — confirm the install/import output above before proceeding.

---

### Task 2: Extend config with DATABASE_URL and REDIS_URL

**Files:**
- Modify: `acute-api/app/core/config.py`
- Test: `acute-api/tests/test_config.py`

**Interfaces:**
- Consumes: existing `Settings` / `settings` from `app.core.config`.
- Produces: `settings.DATABASE_URL: str`, `settings.REDIS_URL: str`.

- [ ] **Step 1: Write the failing test**

Create `acute-api/tests/test_config.py`:

```python
from app.core.config import settings


def test_database_url_is_async_postgres():
    assert settings.DATABASE_URL.startswith("postgresql+asyncpg://")
    assert "acute-db" in settings.DATABASE_URL
    assert "acute-user" in settings.DATABASE_URL


def test_redis_url_present():
    assert settings.REDIS_URL.startswith("redis://")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_config.py -v`
Expected: FAIL with `AttributeError: 'Settings' object has no attribute 'DATABASE_URL'`.

- [ ] **Step 3: Add the settings**

Edit `acute-api/app/core/config.py` to add the two fields inside `Settings` (before `model_config`):

```python
    DATABASE_URL: str = (
        "postgresql+asyncpg://acute-user:acute-pass@localhost:5432/acute-db"
    )
    REDIS_URL: str = "redis://localhost:6379/0"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_config.py -v`
Expected: both tests PASS.

- [ ] **Step 5: Checkpoint** — confirm green output.

---

### Task 3: Database session package

**Files:**
- Create: `acute-api/app/db/__init__.py`
- Create: `acute-api/app/db/base.py`
- Create: `acute-api/app/db/session.py`
- Test: `acute-api/tests/db/__init__.py`, `acute-api/tests/db/test_session.py`

**Interfaces:**
- Consumes: `settings.DATABASE_URL` from Task 2.
- Produces:
  - `app.db.base.Base` — a `DeclarativeBase` subclass (target metadata for Alembic).
  - `app.db.session.engine` — `AsyncEngine`.
  - `app.db.session.SessionLocal` — `async_sessionmaker[AsyncSession]`.
  - `app.db.session.get_db()` — async generator yielding `AsyncSession` (FastAPI dependency).

- [ ] **Step 1: Write the failing test**

Create `acute-api/tests/db/__init__.py` (empty) and `acute-api/tests/db/test_session.py`:

```python
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession

from app.db.base import Base
from app.db.session import SessionLocal, engine, get_db


def test_engine_is_async():
    assert isinstance(engine, AsyncEngine)


def test_base_has_metadata():
    assert hasattr(Base, "metadata")


async def test_get_db_yields_async_session():
    gen = get_db()
    session = await gen.__anext__()
    assert isinstance(session, AsyncSession)
    await gen.aclose()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/db/test_session.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'app.db'`.

- [ ] **Step 3: Implement the package**

Create `acute-api/app/db/__init__.py` (empty).

Create `acute-api/app/db/base.py`:

```python
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Declarative base; all ORM models subclass this.

    Alembic autogenerate targets ``Base.metadata``.
    """
```

Create `acute-api/app/db/session.py`:

```python
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings

engine: AsyncEngine = create_async_engine(settings.DATABASE_URL, future=True)

SessionLocal = async_sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with SessionLocal() as session:
        yield session
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/db/test_session.py -v`
Expected: all three tests PASS (no live DB needed — engine creation is lazy).

- [ ] **Step 5: Checkpoint** — confirm green output.

---

### Task 4: Redis client factory

**Files:**
- Create: `acute-api/app/db/redis.py`
- Test: `acute-api/tests/db/test_redis.py`

**Interfaces:**
- Consumes: `settings.REDIS_URL` from Task 2.
- Produces: `app.db.redis.get_redis()` — returns a `redis.asyncio.Redis` client built from `REDIS_URL`.

- [ ] **Step 1: Write the failing test**

Create `acute-api/tests/db/test_redis.py`:

```python
from redis.asyncio import Redis

from app.db.redis import get_redis


def test_get_redis_returns_async_client():
    client = get_redis()
    assert isinstance(client, Redis)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/db/test_redis.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'app.db.redis'`.

- [ ] **Step 3: Implement the factory**

Create `acute-api/app/db/redis.py`:

```python
from redis.asyncio import Redis

from app.core.config import settings


def get_redis() -> Redis:
    """Build an async Redis client from settings.REDIS_URL."""
    return Redis.from_url(settings.REDIS_URL, decode_responses=True)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/db/test_redis.py -v`
Expected: PASS (no live Redis needed — `from_url` does not connect eagerly).

- [ ] **Step 5: Checkpoint** — confirm green output.

---

### Task 5: Docker Compose for Postgres (pgvector) + Redis

**Files:**
- Create: `acute-api/docker-compose.yml`

**Interfaces:**
- Consumes: `POSTGRES_PASSWORD` env var (from `.env`, added in Task 8).
- Produces: running `db` (port 5432) and `redis` (port 6379) services matching the URLs in `settings`.

- [ ] **Step 1: Write the compose file**

Create `acute-api/docker-compose.yml`:

```yaml
services:
  db:
    image: pgvector/pgvector:pg17
    container_name: acute-db
    environment:
      POSTGRES_DB: acute-db
      POSTGRES_USER: acute-user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-acute-pass}
    ports:
      - "5432:5432"
    volumes:
      - acute-pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U acute-user -d acute-db"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:8-alpine
    container_name: acute-redis
    command: ["redis-server", "--appendonly", "yes"]
    ports:
      - "6379:6379"
    volumes:
      - acute-redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  acute-pgdata:
  acute-redisdata:
```

- [ ] **Step 2: Validate the compose file**

Run: `docker compose -f docker-compose.yml config`
Expected: prints the resolved config with no errors.

- [ ] **Step 3: Start services**

Run: `docker compose up -d`
Expected: `db` and `redis` containers start.

- [ ] **Step 4: Verify both services are healthy**

Run: `docker compose ps`
Expected: both `acute-db` and `acute-redis` show `(healthy)`. (Allow ~10–20s; re-run if still starting.)

- [ ] **Step 5: Verify Redis responds**

Run: `docker compose exec redis redis-cli ping`
Expected: `PONG`.

- [ ] **Step 6: Checkpoint** — confirm both services healthy and Redis `PONG`.

---

### Task 6: Initialise Alembic with an async environment

**Files:**
- Create: `acute-api/alembic.ini`
- Create: `acute-api/alembic/env.py`
- Create: `acute-api/alembic/script.py.mako`
- Create: `acute-api/alembic/versions/` (directory)

**Interfaces:**
- Consumes: `settings.DATABASE_URL` (Task 2), `Base.metadata` (Task 3).
- Produces: a working async Alembic environment; `alembic` CLI runs against `acute-db`.

- [ ] **Step 1: Scaffold the async template**

Run: `alembic init -t async alembic`
Expected: creates `alembic/` (with `env.py`, `script.py.mako`, `versions/`) and `alembic.ini`.

- [ ] **Step 2: Remove the hardcoded URL from alembic.ini**

In `acute-api/alembic.ini`, find the `sqlalchemy.url = ...` line and set it empty (the URL is injected from settings in `env.py`):

```ini
sqlalchemy.url =
```

- [ ] **Step 3: Wire env.py to settings and Base.metadata**

Replace the relevant parts of `acute-api/alembic/env.py` so the config URL and target metadata come from the app. After the existing imports, add:

```python
from app.core.config import settings
from app.db.base import Base

# Import models here as they are added so autogenerate sees them.

config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)
target_metadata = Base.metadata
```

Ensure `target_metadata = None` (the scaffold default) is removed/replaced by the line above, and that both `run_migrations_offline()` and `run_migrations_online()` reference `target_metadata`.

- [ ] **Step 4: Verify Alembic loads the environment**

Run: `alembic current`
Expected: connects and prints no current revision (empty) without errors. Requires the `db` service from Task 5 to be running.

- [ ] **Step 5: Checkpoint** — confirm `alembic current` connects cleanly.

---

### Task 7: Baseline migration — enable pgvector

**Files:**
- Create: `acute-api/alembic/versions/0001_enable_pgvector.py`

**Interfaces:**
- Consumes: the Alembic environment from Task 6.
- Produces: revision `0001` that enables/removes the `vector` extension on `acute-db`.

- [ ] **Step 1: Generate an empty revision**

Run: `alembic revision -m "enable pgvector"`
Expected: creates a file under `alembic/versions/`. Rename it to `0001_enable_pgvector.py` and set `revision = "0001"`, `down_revision = None`.

- [ ] **Step 2: Write the migration body**

Set the `upgrade`/`downgrade` functions in `acute-api/alembic/versions/0001_enable_pgvector.py`:

```python
from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")


def downgrade() -> None:
    op.execute("DROP EXTENSION IF EXISTS vector")
```

- [ ] **Step 3: Apply the migration**

Run: `alembic upgrade head`
Expected: applies revision `0001` with no errors.

- [ ] **Step 4: Verify the extension exists**

Run: `docker compose exec db psql -U acute-user -d acute-db -c "\dx"`
Expected: the listing includes a row for `vector`.

- [ ] **Step 5: Verify downgrade is clean**

Run: `alembic downgrade -1` then `docker compose exec db psql -U acute-user -d acute-db -c "\dx"`
Expected: downgrade succeeds; `vector` no longer listed. Then re-apply: `alembic upgrade head`.

- [ ] **Step 6: Checkpoint** — confirm `\dx` lists `vector` after final `upgrade head`.

---

### Task 8: Update .env.example and CLAUDE.md

**Files:**
- Modify: `acute-api/.env.example`
- Modify: `shield/CLAUDE.md`

**Interfaces:**
- Consumes: nothing.
- Produces: documented env vars and dev commands. No code dependency.

- [ ] **Step 1: Extend .env.example**

Append to `acute-api/.env.example`:

```dotenv
# Postgres (Docker Compose) — acute-user owns acute-db
POSTGRES_PASSWORD=acute-pass
DATABASE_URL=postgresql+asyncpg://acute-user:acute-pass@localhost:5432/acute-db

# Redis (Docker Compose)
REDIS_URL=redis://localhost:6379/0
```

- [ ] **Step 2: Add dev commands to CLAUDE.md**

In `shield/CLAUDE.md`, under the `### FastAPI Backend (acute-api/)` section, add a subsection after **Setup**:

````markdown
**Local infrastructure (Postgres + Redis):**
```bash
docker compose up -d            # start Postgres (pgvector) + Redis
docker compose ps               # check health
alembic upgrade head            # apply DB migrations (enables pgvector)
docker compose down             # stop services (add -v to wipe data)
```
````

- [ ] **Step 3: Verify docs render**

Run: `python -c "print(open('.env.example').read())"`
Expected: shows the new env vars.

- [ ] **Step 4: Checkpoint** — confirm the docs include the new vars and commands.

---

### Task 9: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Full test suite passes**

Run: `pytest`
Expected: all tests pass — existing OTP/health tests plus the new config/db/redis tests; no regressions.

- [ ] **Step 2: Infra + migration end-to-end**

Run: `docker compose up -d && alembic upgrade head && docker compose exec db psql -U acute-user -d acute-db -c "\dx"`
Expected: services healthy, migration applied, `vector` extension listed.

- [ ] **Step 3: Checkpoint** — confirm all of the above, then the feature is complete.

---

## Self-Review Notes

- **Spec coverage:** Compose (Task 5), deps (Task 1), config (Task 2), `app/db/` session+base (Task 3), redis factory (Task 4), Alembic async env (Task 6), baseline pgvector migration (Task 7), env+docs (Task 8), verification (Task 9). All spec sections mapped.
- **Placeholders:** none — all steps contain concrete code/commands.
- **Type consistency:** `Base`, `engine`, `SessionLocal`, `get_db`, `get_redis`, `settings.DATABASE_URL`, `settings.REDIS_URL`, revision `0001` used consistently across tasks.
