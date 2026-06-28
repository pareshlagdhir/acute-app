# Doctor Onboarding — Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the FastAPI backend for doctor onboarding: session auth after MSG91 OTP, a doctor profile with education/speciality/experience/working-hours sub-resources, a shared hospital master, seeded catalogs, and a server-computed profile-completion percentage.

**Architecture:** Resource-oriented REST (Approach A). One aggregate read `GET /doctors/me` returns the doctor, all sub-collections, and completion; dedicated CRUD endpoints handle each sub-resource. A JWT minted at login carries the doctor id; a `get_current_doctor` dependency guards and scopes every `/doctors/me/*` route. SQLAlchemy 2.0 async models, one Alembic migration with catalog seed data.

**Tech Stack:** FastAPI, SQLAlchemy 2.0 (async), Alembic, PyJWT, Pydantic v2, pytest + pytest-asyncio + respx, aiosqlite (tests only).

## Global Constraints

- Python `>=3.11`; FastAPI `>=0.115`; SQLAlchemy `[asyncio] >=2.0`; Pydantic `>=2.9`.
- All routes mounted under `settings.API_V1_STR` (`/api/v1`).
- Use the existing `MSG91Service.verify_otp_token` for token verification — do not call MSG91 elsewhere.
- Secrets (`JWT_SECRET`, `MSG91_AUTHKEY`) come only from settings/`.env`; never log or echo them.
- Models subclass `app.db.base.Base`; use `sqlalchemy.Uuid` PKs and timezone-aware `created_at`/`updated_at`.
- Every async DB endpoint depends on `app.db.session.get_db`.
- TDD: write the failing test first, watch it fail, implement minimally, watch it pass, commit. Run `pytest` from `acute-api/`.
- Keep doc files in `acute-api/doc/v1/` in sync with new endpoints.

---

## File Structure

- `app/core/config.py` (modify) — add `JWT_SECRET`, `JWT_ALG`, `JWT_EXP_DAYS`.
- `app/core/security.py` (create) — `create_access_token`, `decode_access_token`.
- `app/api/deps.py` (create) — `get_current_doctor` dependency.
- `app/models/__init__.py` (create) — import all models for Alembic.
- `app/models/doctor.py`, `education.py`, `speciality.py`, `hospital.py`, `experience.py`, `working_hours.py`, `catalog.py` (create) — one aggregate per file.
- `app/services/profile.py` (create) — pure `compute_completion`.
- `app/schemas/auth.py`, `doctor.py`, `education.py`, `speciality.py`, `hospital.py`, `experience.py`, `working_hours.py`, `catalog.py` (create).
- `app/api/v1/endpoints/auth.py`, `doctors.py`, `educations.py`, `specialities.py`, `experiences.py`, `working_hours.py`, `hospitals.py`, `catalog.py` (create).
- `app/api/v1/router.py` (modify) — mount new routers.
- `alembic/versions/0002_doctor_onboarding.py` (create) — tables + catalog seed.
- `alembic/env.py` (modify) — import models package.
- `tests/conftest.py` (modify) — in-memory DB engine, `get_db` override, JWT helpers.
- `tests/api/v1/test_*.py` (create) — per-endpoint tests.
- `doc/v1/auth.md`, `doctors.md`, `hospitals.md`, `catalog.md` (create).

---

### Task B1: Dependencies, JWT settings, and security helpers

**Files:**
- Modify: `acute-api/pyproject.toml`
- Modify: `acute-api/app/core/config.py`
- Create: `acute-api/app/core/security.py`
- Test: `acute-api/tests/test_security.py`

**Interfaces:**
- Produces: `create_access_token(subject: str, *, expires_delta: timedelta | None = None) -> str`; `decode_access_token(token: str) -> str` (returns the subject / doctor id, raises `InvalidTokenError` on failure).
- Settings gain `JWT_SECRET: str`, `JWT_ALG: str = "HS256"`, `JWT_EXP_DAYS: int = 30`.

- [ ] **Step 1: Add dependencies**

In `pyproject.toml`, add `"pyjwt>=2.9.0"` to `dependencies`, and `"aiosqlite>=0.20.0"` to `[project.optional-dependencies].dev`. Then run:

```bash
cd acute-api && pip install -e ".[dev]"
```

- [ ] **Step 2: Add JWT settings**

In `app/core/config.py`, add inside `Settings` (after `MSG91_VERIFY_URL`):

```python
    JWT_SECRET: str = "change-me-in-env"
    JWT_ALG: str = "HS256"
    JWT_EXP_DAYS: int = 30
```

- [ ] **Step 3: Write the failing test**

Create `tests/test_security.py`:

```python
import pytest
from jwt import InvalidTokenError

from app.core.security import create_access_token, decode_access_token


def test_roundtrip_returns_subject() -> None:
    token = create_access_token("doctor-123")
    assert decode_access_token(token) == "doctor-123"


def test_decode_rejects_garbage() -> None:
    with pytest.raises(InvalidTokenError):
        decode_access_token("not-a-token")
```

- [ ] **Step 4: Run test to verify it fails**

Run: `pytest tests/test_security.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'app.core.security'`.

- [ ] **Step 5: Implement `security.py`**

Create `app/core/security.py`:

```python
from datetime import datetime, timedelta, timezone

import jwt

from app.core.config import settings


def create_access_token(subject: str, *, expires_delta: timedelta | None = None) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(days=settings.JWT_EXP_DAYS)
    )
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALG)


def decode_access_token(token: str) -> str:
    payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALG])
    subject = payload.get("sub")
    if not subject:
        raise jwt.InvalidTokenError("missing subject")
    return str(subject)
```

- [ ] **Step 6: Run test to verify it passes**

Run: `pytest tests/test_security.py -v`
Expected: PASS (2 passed).

- [ ] **Step 7: Commit**

```bash
git add pyproject.toml app/core/config.py app/core/security.py tests/test_security.py
git commit -m "feat(api): add JWT settings and token helpers"
```

---

### Task B2: ORM models and Alembic migration with catalog seed

**Files:**
- Create: `acute-api/app/models/__init__.py` and `doctor.py`, `catalog.py`, `education.py`, `speciality.py`, `hospital.py`, `experience.py`, `working_hours.py`
- Modify: `acute-api/alembic/env.py`
- Create: `acute-api/alembic/versions/0002_doctor_onboarding.py`
- Modify: `acute-api/tests/conftest.py`
- Test: `acute-api/tests/test_models.py`

**Interfaces:**
- Produces ORM classes: `Doctor`, `DegreeCatalog`, `SpecialityCatalog`, `DoctorEducation`, `DoctorSpeciality`, `Hospital`, `DoctorExperience`, `WorkingHour`.
- `Doctor` relationships (all `lazy="selectin"`): `educations`, `specialities`, `experiences`. `DoctorExperience.working_hours`. `DoctorExperience.hospital`.
- conftest produces fixtures: `db_session`, `client` (with `get_db` overridden), `auth_headers` factory, and `make_doctor`.

- [ ] **Step 1: Write the models**

Create `app/models/doctor.py`:

```python
import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Doctor(Base):
    __tablename__ = "doctors"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    mobile: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    first_name: Mapped[str | None] = mapped_column(String(100))
    middle_name: Mapped[str | None] = mapped_column(String(100))
    last_name: Mapped[str | None] = mapped_column(String(100))
    email: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    educations: Mapped[list["DoctorEducation"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )
    specialities: Mapped[list["DoctorSpeciality"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )
    experiences: Mapped[list["DoctorExperience"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )

    from app.models.education import DoctorEducation  # noqa: E402,F401
    from app.models.experience import DoctorExperience  # noqa: E402,F401
    from app.models.speciality import DoctorSpeciality  # noqa: E402,F401
```

Create `app/models/catalog.py`:

```python
import uuid

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class DegreeCatalog(Base):
    __tablename__ = "degree_catalog"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), unique=True, index=True)


class SpecialityCatalog(Base):
    __tablename__ = "speciality_catalog"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), unique=True, index=True)
```

Create `app/models/education.py`:

```python
import uuid

from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DoctorEducation(Base):
    __tablename__ = "doctor_educations"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    doctor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctors.id", ondelete="CASCADE"), index=True
    )
    degree: Mapped[str] = mapped_column(String(100))
    registration_number: Mapped[str] = mapped_column(String(100))
    institution: Mapped[str | None] = mapped_column(String(255))
    year_of_completion: Mapped[int | None] = mapped_column(Integer)

    doctor: Mapped["Doctor"] = relationship(back_populates="educations")  # noqa: F821
```

Create `app/models/speciality.py`:

```python
import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DoctorSpeciality(Base):
    __tablename__ = "doctor_specialities"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    doctor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctors.id", ondelete="CASCADE"), index=True
    )
    name: Mapped[str] = mapped_column(String(100))

    doctor: Mapped["Doctor"] = relationship(back_populates="specialities")  # noqa: F821
```

Create `app/models/hospital.py`:

```python
import uuid

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Hospital(Base):
    __tablename__ = "hospitals"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(255), index=True)
    type: Mapped[str] = mapped_column(String(20), default="hospital")  # hospital | clinic
    city: Mapped[str | None] = mapped_column(String(120))
    address: Mapped[str | None] = mapped_column(String(500))
    created_by: Mapped[uuid.UUID | None] = mapped_column(default=None)
```

Create `app/models/experience.py`:

```python
import uuid
from datetime import date

from sqlalchemy import Boolean, Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DoctorExperience(Base):
    __tablename__ = "doctor_experiences"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    doctor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctors.id", ondelete="CASCADE"), index=True
    )
    hospital_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("hospitals.id"), index=True)
    designation: Mapped[str | None] = mapped_column(String(120))
    start_date: Mapped[date | None] = mapped_column(Date)
    end_date: Mapped[date | None] = mapped_column(Date)
    is_current: Mapped[bool] = mapped_column(Boolean, default=False)

    doctor: Mapped["Doctor"] = relationship(back_populates="experiences")  # noqa: F821
    hospital: Mapped["Hospital"] = relationship(lazy="selectin")  # noqa: F821
    working_hours: Mapped[list["WorkingHour"]] = relationship(
        back_populates="experience", cascade="all, delete-orphan", lazy="selectin"
    )

    from app.models.working_hours import WorkingHour  # noqa: E402,F401
```

Create `app/models/working_hours.py`:

```python
import uuid
from datetime import time

from sqlalchemy import ForeignKey, Integer, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class WorkingHour(Base):
    __tablename__ = "working_hours"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    experience_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctor_experiences.id", ondelete="CASCADE"), index=True
    )
    day_of_week: Mapped[int] = mapped_column(Integer)  # 0=Mon .. 6=Sun
    start_time: Mapped[time] = mapped_column(Time)
    end_time: Mapped[time] = mapped_column(Time)

    experience: Mapped["DoctorExperience"] = relationship(  # noqa: F821
        back_populates="working_hours"
    )
```

Create `app/models/__init__.py`:

```python
from app.models.catalog import DegreeCatalog, SpecialityCatalog
from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.models.experience import DoctorExperience
from app.models.hospital import Hospital
from app.models.speciality import DoctorSpeciality
from app.models.working_hours import WorkingHour

__all__ = [
    "DegreeCatalog",
    "SpecialityCatalog",
    "Doctor",
    "DoctorEducation",
    "DoctorExperience",
    "Hospital",
    "DoctorSpeciality",
    "WorkingHour",
]
```

- [ ] **Step 2: Wire models into Alembic**

In `alembic/env.py`, replace the comment line `# Import models here as they are added so autogenerate sees them.` with:

```python
import app.models  # noqa: F401  (registers all tables on Base.metadata)
```

- [ ] **Step 3: Rewrite the test conftest for an in-memory DB**

Replace `tests/conftest.py` with:

```python
import uuid
from collections.abc import AsyncGenerator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

import app.models  # noqa: F401  (register tables)
from app.api.deps import get_current_doctor  # noqa: F401  (import path exists after B3)
from app.core.security import create_access_token
from app.db.base import Base
from app.db.session import get_db
from app.main import app
from app.models.doctor import Doctor


@pytest.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with maker() as session:
        app.dependency_overrides[get_db] = lambda: _yield(session)
        yield session
        app.dependency_overrides.pop(get_db, None)
    await engine.dispose()


async def _yield(session: AsyncSession):
    yield session


@pytest.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac


@pytest.fixture
async def make_doctor(db_session: AsyncSession):
    async def _make(mobile: str = "919999999999", **kwargs) -> Doctor:
        doctor = Doctor(id=uuid.uuid4(), mobile=mobile, **kwargs)
        db_session.add(doctor)
        await db_session.commit()
        await db_session.refresh(doctor)
        return doctor

    return _make


@pytest.fixture
def auth_headers():
    def _headers(doctor: Doctor) -> dict[str, str]:
        token = create_access_token(str(doctor.id))
        return {"Authorization": f"Bearer {token}"}

    return _headers
```

Note: the `from app.api.deps import get_current_doctor` import is satisfied by Task B3; if running B2 in isolation, remove that line and restore it in B3.

- [ ] **Step 4: Write the failing migration test**

Create `tests/test_models.py`:

```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.doctor import Doctor


async def test_can_persist_and_load_doctor(db_session: AsyncSession) -> None:
    db_session.add(Doctor(mobile="911234567890", first_name="Asha", last_name="Rao"))
    await db_session.commit()
    rows = (await db_session.execute(select(Doctor))).scalars().all()
    assert len(rows) == 1
    assert rows[0].mobile == "911234567890"
```

- [ ] **Step 5: Run test to verify it fails, then passes**

Run: `pytest tests/test_models.py -v`
Expected first run: FAIL if any import/model error. Fix until: PASS (1 passed). This validates `Base.metadata.create_all` builds every table.

- [ ] **Step 6: Author the Alembic migration with seed data**

Create `alembic/versions/0002_doctor_onboarding.py`:

```python
"""doctor onboarding tables + catalog seed

Revision ID: 0002_doctor_onboarding
Revises: 0001_enable_pgvector
Create Date: 2026-06-28
"""
import uuid

import sqlalchemy as sa

from alembic import op

revision = "0002_doctor_onboarding"
down_revision = "0001_enable_pgvector"
branch_labels = None
depends_on = None

DEGREES = ["MBBS", "MD", "MS", "DM", "MCh", "DNB", "BDS", "MDS", "DGO", "DA"]
SPECIALITIES = [
    "General Medicine", "Cardiology", "Orthopaedics", "Paediatrics",
    "Gynaecology", "Dermatology", "Neurology", "Oncology", "Radiology",
    "Anaesthesiology", "ENT", "Ophthalmology",
]


def upgrade() -> None:
    op.create_table(
        "doctors",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("mobile", sa.String(20), nullable=False, unique=True),
        sa.Column("first_name", sa.String(100)),
        sa.Column("middle_name", sa.String(100)),
        sa.Column("last_name", sa.String(100)),
        sa.Column("email", sa.String(255)),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_doctors_mobile", "doctors", ["mobile"])

    op.create_table(
        "degree_catalog",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
    )
    op.create_table(
        "speciality_catalog",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
    )
    op.create_table(
        "hospitals",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("type", sa.String(20), nullable=False, server_default="hospital"),
        sa.Column("city", sa.String(120)),
        sa.Column("address", sa.String(500)),
        sa.Column("created_by", sa.Uuid()),
    )
    op.create_index("ix_hospitals_name", "hospitals", ["name"])

    op.create_table(
        "doctor_educations",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("degree", sa.String(100), nullable=False),
        sa.Column("registration_number", sa.String(100), nullable=False),
        sa.Column("institution", sa.String(255)),
        sa.Column("year_of_completion", sa.Integer()),
    )
    op.create_table(
        "doctor_specialities",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
    )
    op.create_table(
        "doctor_experiences",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("hospital_id", sa.Uuid(), sa.ForeignKey("hospitals.id"), nullable=False),
        sa.Column("designation", sa.String(120)),
        sa.Column("start_date", sa.Date()),
        sa.Column("end_date", sa.Date()),
        sa.Column("is_current", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.create_table(
        "working_hours",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("experience_id", sa.Uuid(), sa.ForeignKey("doctor_experiences.id", ondelete="CASCADE"), nullable=False),
        sa.Column("day_of_week", sa.Integer(), nullable=False),
        sa.Column("start_time", sa.Time(), nullable=False),
        sa.Column("end_time", sa.Time(), nullable=False),
    )

    degrees = sa.table("degree_catalog", sa.column("id", sa.Uuid()), sa.column("name", sa.String))
    specialities = sa.table("speciality_catalog", sa.column("id", sa.Uuid()), sa.column("name", sa.String))
    op.bulk_insert(degrees, [{"id": uuid.uuid4(), "name": n} for n in DEGREES])
    op.bulk_insert(specialities, [{"id": uuid.uuid4(), "name": n} for n in SPECIALITIES])


def downgrade() -> None:
    for tbl in (
        "working_hours", "doctor_experiences", "doctor_specialities",
        "doctor_educations", "hospitals", "speciality_catalog",
        "degree_catalog", "doctors",
    ):
        op.drop_table(tbl)
```

- [ ] **Step 7: Apply and verify the migration against Postgres**

Run (Docker Postgres must be up — `docker compose up -d`):

```bash
alembic upgrade head && alembic downgrade -1 && alembic upgrade head
```

Expected: no errors; `degree_catalog` and `speciality_catalog` end up seeded.

- [ ] **Step 8: Commit**

```bash
git add app/models alembic/env.py alembic/versions/0002_doctor_onboarding.py tests/conftest.py tests/test_models.py
git commit -m "feat(api): add onboarding ORM models and migration with catalog seed"
```

---

### Task B3: `get_current_doctor` dependency

**Files:**
- Create: `acute-api/app/api/deps.py`
- Test: `acute-api/tests/test_deps.py`

**Interfaces:**
- Consumes: `decode_access_token` (B1), `Doctor` (B2), `get_db`.
- Produces: `async def get_current_doctor(authorization: str = Header(...), db: AsyncSession = Depends(get_db)) -> Doctor`. Raises `HTTPException(401)` for missing/invalid token or unknown doctor.

- [ ] **Step 1: Write the failing test**

Create `tests/test_deps.py`:

```python
import uuid

from httpx import AsyncClient

# A throwaway route is mounted in the app via deps; we test through /doctors/me later.
# Here we test the decode failure path through a minimal call once /doctors/me exists.


async def test_missing_auth_header_is_401(client: AsyncClient) -> None:
    resp = await client.get("/api/v1/doctors/me")
    assert resp.status_code == 401


async def test_bad_token_is_401(client: AsyncClient) -> None:
    resp = await client.get(
        "/api/v1/doctors/me", headers={"Authorization": "Bearer garbage"}
    )
    assert resp.status_code == 401
```

(These pass once B3 + B4 are both in. If executing strictly per task, run them at the end of B4.)

- [ ] **Step 2: Implement the dependency**

Create `app/api/deps.py`:

```python
import uuid

import jwt
from fastapi import Depends, Header, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.doctor import Doctor


async def get_current_doctor(
    authorization: str | None = Header(default=None),
    db: AsyncSession = Depends(get_db),
) -> Doctor:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.split(" ", 1)[1]
    try:
        subject = decode_access_token(token)
        doctor_id = uuid.UUID(subject)
    except (jwt.InvalidTokenError, ValueError) as exc:
        raise HTTPException(status_code=401, detail="Invalid token") from exc
    doctor = await db.get(Doctor, doctor_id)
    if doctor is None:
        raise HTTPException(status_code=401, detail="Unknown doctor")
    return doctor
```

- [ ] **Step 3: Commit**

```bash
git add app/api/deps.py tests/test_deps.py
git commit -m "feat(api): add get_current_doctor JWT dependency"
```

---

### Task B4: Profile schemas, completion service, and `GET /doctors/me`

**Files:**
- Create: `acute-api/app/services/profile.py`
- Create: `acute-api/app/schemas/doctor.py`, `education.py`, `speciality.py`, `experience.py`, `working_hours.py`
- Create: `acute-api/app/api/v1/endpoints/doctors.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/test_profile_service.py`, `acute-api/tests/api/v1/test_doctors_me.py`

**Interfaces:**
- Produces pure function `compute_completion(doctor: Doctor) -> tuple[int, dict[str, bool]]` returning `(percentage_0_100, {"personal", "education", "speciality", "experience", "working_hours": bool})`.
- Produces `GET /api/v1/doctors/me` → `DoctorMeResponse` with fields `id, mobile, first_name, middle_name, last_name, email, educations[], specialities[], experiences[] (each with working_hours[] and hospital), profile_completion, sections`.
- Schemas later reused by B6–B9.

- [ ] **Step 1: Write the failing completion test**

Create `tests/test_profile_service.py`:

```python
import datetime as dt

from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.models.experience import DoctorExperience
from app.models.speciality import DoctorSpeciality
from app.models.working_hours import WorkingHour
from app.services.profile import compute_completion


def test_empty_profile_is_zero() -> None:
    pct, sections = compute_completion(Doctor(mobile="91x"))
    assert pct == 0
    assert sections == {
        "personal": False, "education": False, "speciality": False,
        "experience": False, "working_hours": False,
    }


def test_each_section_adds_twenty() -> None:
    d = Doctor(mobile="91x", first_name="A", last_name="B")
    d.educations = [DoctorEducation(degree="MBBS", registration_number="R1")]
    d.specialities = [DoctorSpeciality(name="Cardiology")]
    exp = DoctorExperience(hospital_id=None)
    exp.working_hours = [WorkingHour(day_of_week=0, start_time=dt.time(9), end_time=dt.time(17))]
    d.experiences = [exp]
    pct, sections = compute_completion(d)
    assert pct == 100
    assert all(sections.values())
```

- [ ] **Step 2: Run to verify it fails**

Run: `pytest tests/test_profile_service.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'app.services.profile'`.

- [ ] **Step 3: Implement the completion service**

Create `app/services/profile.py`:

```python
from app.models.doctor import Doctor

SECTION_WEIGHT = 20


def compute_completion(doctor: Doctor) -> tuple[int, dict[str, bool]]:
    has_working_hours = any(
        len(exp.working_hours) > 0 for exp in doctor.experiences
    )
    sections = {
        "personal": bool(doctor.first_name and doctor.last_name),
        "education": len(doctor.educations) > 0,
        "speciality": len(doctor.specialities) > 0,
        "experience": len(doctor.experiences) > 0,
        "working_hours": has_working_hours,
    }
    pct = sum(SECTION_WEIGHT for done in sections.values() if done)
    return pct, sections
```

- [ ] **Step 4: Run to verify it passes**

Run: `pytest tests/test_profile_service.py -v`
Expected: PASS (2 passed).

- [ ] **Step 5: Write the response schemas**

Create `app/schemas/working_hours.py`:

```python
import datetime as dt
import uuid

from pydantic import BaseModel, ConfigDict, model_validator


class WorkingHourBase(BaseModel):
    day_of_week: int  # 0=Mon .. 6=Sun
    start_time: dt.time
    end_time: dt.time

    @model_validator(mode="after")
    def _check(self) -> "WorkingHourBase":
        if not 0 <= self.day_of_week <= 6:
            raise ValueError("day_of_week must be 0..6")
        if self.end_time <= self.start_time:
            raise ValueError("end_time must be after start_time")
        return self


class WorkingHourCreate(WorkingHourBase):
    pass


class WorkingHourOut(WorkingHourBase):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
```

Create `app/schemas/education.py`:

```python
import uuid

from pydantic import BaseModel, ConfigDict


class EducationCreate(BaseModel):
    degree: str
    registration_number: str
    institution: str | None = None
    year_of_completion: int | None = None


class EducationUpdate(BaseModel):
    degree: str | None = None
    registration_number: str | None = None
    institution: str | None = None
    year_of_completion: int | None = None


class EducationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    degree: str
    registration_number: str
    institution: str | None
    year_of_completion: int | None
```

Create `app/schemas/speciality.py`:

```python
import uuid

from pydantic import BaseModel, ConfigDict


class SpecialityCreate(BaseModel):
    name: str


class SpecialityOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
```

Create `app/schemas/experience.py`:

```python
import datetime as dt
import uuid

from pydantic import BaseModel, ConfigDict

from app.schemas.working_hours import WorkingHourOut


class HospitalRef(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    type: str
    city: str | None


class ExperienceCreate(BaseModel):
    hospital_id: uuid.UUID
    designation: str | None = None
    start_date: dt.date | None = None
    end_date: dt.date | None = None
    is_current: bool = False


class ExperienceUpdate(BaseModel):
    hospital_id: uuid.UUID | None = None
    designation: str | None = None
    start_date: dt.date | None = None
    end_date: dt.date | None = None
    is_current: bool | None = None


class ExperienceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    designation: str | None
    start_date: dt.date | None
    end_date: dt.date | None
    is_current: bool
    hospital: HospitalRef
    working_hours: list[WorkingHourOut]
```

Create `app/schemas/doctor.py`:

```python
import uuid

from pydantic import BaseModel, ConfigDict, EmailStr

from app.schemas.education import EducationOut
from app.schemas.experience import ExperienceOut
from app.schemas.speciality import SpecialityOut


class DoctorUpdate(BaseModel):
    first_name: str | None = None
    middle_name: str | None = None
    last_name: str | None = None
    email: EmailStr | None = None


class DoctorMeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    mobile: str
    first_name: str | None
    middle_name: str | None
    last_name: str | None
    email: str | None
    educations: list[EducationOut]
    specialities: list[SpecialityOut]
    experiences: list[ExperienceOut]
    profile_completion: int
    sections: dict[str, bool]
```

Note: `EmailStr` requires `email-validator`. Add `"pydantic[email]>=2.9.0"` to `pyproject.toml` dependencies and re-run `pip install -e ".[dev]"`.

- [ ] **Step 6: Write the failing endpoint test**

Create `tests/api/v1/test_doctors_me.py`:

```python
from httpx import AsyncClient


async def test_get_me_returns_profile_with_completion(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor(first_name="Asha", last_name="Rao")
    resp = await client.get("/api/v1/doctors/me", headers=auth_headers(doctor))
    assert resp.status_code == 200
    body = resp.json()
    assert body["mobile"] == doctor.mobile
    assert body["profile_completion"] == 20  # personal complete only
    assert body["sections"]["personal"] is True
    assert body["educations"] == []
```

- [ ] **Step 7: Implement the endpoint and helper**

Create `app/api/v1/endpoints/doctors.py`:

```python
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.doctor import DoctorMeResponse, DoctorUpdate
from app.services.profile import compute_completion

router = APIRouter()


def _serialize(doctor: Doctor) -> DoctorMeResponse:
    pct, sections = compute_completion(doctor)
    return DoctorMeResponse.model_validate(
        {
            **doctor.__dict__,
            "educations": doctor.educations,
            "specialities": doctor.specialities,
            "experiences": doctor.experiences,
            "profile_completion": pct,
            "sections": sections,
        }
    )


@router.get("/me", response_model=DoctorMeResponse, summary="Current doctor profile + completion")
async def get_me(doctor: Doctor = Depends(get_current_doctor)) -> DoctorMeResponse:
    return _serialize(doctor)


@router.patch("/me", response_model=DoctorMeResponse, summary="Update personal information")
async def update_me(
    body: DoctorUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
) -> DoctorMeResponse:
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(doctor, field, value)
    await db.commit()
    await db.refresh(doctor)
    return _serialize(doctor)
```

- [ ] **Step 8: Mount the router**

In `app/api/v1/router.py`, add after the otp include:

```python
from app.api.v1.endpoints.doctors import router as doctors_router
api_v1_router.include_router(doctors_router, prefix="/doctors", tags=["doctors"])
```

- [ ] **Step 9: Run the tests**

Run: `pytest tests/api/v1/test_doctors_me.py tests/test_deps.py -v`
Expected: PASS (test_get_me + the two 401 tests from B3).

- [ ] **Step 10: Commit**

```bash
git add app/services/profile.py app/schemas/doctor.py app/schemas/education.py app/schemas/speciality.py app/schemas/experience.py app/schemas/working_hours.py app/api/v1/endpoints/doctors.py app/api/v1/router.py pyproject.toml tests/test_profile_service.py tests/api/v1/test_doctors_me.py
git commit -m "feat(api): add GET/PATCH /doctors/me with completion"
```

---

### Task B5: `POST /auth/login`

**Files:**
- Create: `acute-api/app/schemas/auth.py`
- Create: `acute-api/app/api/v1/endpoints/auth.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_auth_login.py`

**Interfaces:**
- Consumes: `MSG91Service.verify_otp_token` (returns `OTPVerifyResponse(verified, mobile, message)`), `create_access_token`, `compute_completion`, `Doctor`.
- Produces: `POST /api/v1/auth/login` body `{access_token}` → `LoginResponse(token, token_type="bearer", is_new, onboarding_needed, profile_completion)`. `401` when MSG91 reports `verified is False`.

- [ ] **Step 1: Write the auth schemas**

Create `app/schemas/auth.py`:

```python
from pydantic import BaseModel


class LoginRequest(BaseModel):
    access_token: str


class LoginResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    is_new: bool
    onboarding_needed: bool
    profile_completion: int
```

- [ ] **Step 2: Write the failing tests**

Create `tests/api/v1/test_auth_login.py`:

```python
import httpx
import respx
from httpx import AsyncClient

MSG91_VERIFY_URL = "https://control.msg91.com/api/v5/widget/verifyAccessToken"


async def test_login_new_doctor_creates_record(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "mobile": "919876543210"})
        )
        resp = await client.post("/api/v1/auth/login", json={"access_token": "tok"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["is_new"] is True
    assert body["onboarding_needed"] is True
    assert body["profile_completion"] == 0
    assert body["token"]


async def test_login_existing_doctor_is_not_new(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "mobile": "919876543210"})
        )
        await client.post("/api/v1/auth/login", json={"access_token": "tok"})
        resp = await client.post("/api/v1/auth/login", json={"access_token": "tok"})
    assert resp.json()["is_new"] is False


async def test_login_rejects_invalid_token(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "bad"})
        )
        resp = await client.post("/api/v1/auth/login", json={"access_token": "bad"})
    assert resp.status_code == 401
```

- [ ] **Step 3: Run to verify it fails**

Run: `pytest tests/api/v1/test_auth_login.py -v`
Expected: FAIL — route `/api/v1/auth/login` returns 404.

- [ ] **Step 4: Implement the endpoint**

Create `app/api/v1/endpoints/auth.py`:

```python
import httpx
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import MSG91UnavailableError
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.auth import LoginRequest, LoginResponse
from app.services.msg91 import MSG91Service
from app.services.profile import compute_completion

router = APIRouter()


@router.post("/login", response_model=LoginResponse, summary="Exchange MSG91 token for a session")
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)) -> LoginResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            result = await svc.verify_otp_token(body.access_token)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail=f"MSG91 unreachable: {exc}") from exc

    if not result.verified or not result.mobile:
        raise HTTPException(status_code=401, detail="OTP verification failed")

    existing = (
        await db.execute(select(Doctor).where(Doctor.mobile == result.mobile))
    ).scalar_one_or_none()
    is_new = existing is None
    doctor = existing or Doctor(mobile=result.mobile)
    if is_new:
        db.add(doctor)
        await db.commit()
        await db.refresh(doctor)

    pct, _ = compute_completion(doctor)
    return LoginResponse(
        token=create_access_token(str(doctor.id)),
        is_new=is_new,
        onboarding_needed=pct < 100,
        profile_completion=pct,
    )
```

- [ ] **Step 5: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.auth import router as auth_router
api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])
```

- [ ] **Step 6: Run the tests**

Run: `pytest tests/api/v1/test_auth_login.py -v`
Expected: PASS (3 passed).

- [ ] **Step 7: Commit**

```bash
git add app/schemas/auth.py app/api/v1/endpoints/auth.py app/api/v1/router.py tests/api/v1/test_auth_login.py
git commit -m "feat(api): add POST /auth/login session exchange"
```

---

### Task B6: Catalog search endpoints

**Files:**
- Create: `acute-api/app/schemas/catalog.py`
- Create: `acute-api/app/api/v1/endpoints/catalog.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_catalog.py`

**Interfaces:**
- Produces: `GET /api/v1/catalog/degrees?q=` and `GET /api/v1/catalog/specialities?q=`, each returning `list[CatalogItem(id, name)]`, case-insensitive `name` prefix filter, capped at 50.

- [ ] **Step 1: Write the schema**

Create `app/schemas/catalog.py`:

```python
import uuid

from pydantic import BaseModel, ConfigDict


class CatalogItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
```

- [ ] **Step 2: Write the failing test**

Create `tests/api/v1/test_catalog.py`:

```python
from httpx import AsyncClient


async def test_degrees_seeded_and_searchable(client: AsyncClient) -> None:
    # conftest creates fresh tables but does NOT run the Alembic seed; insert one.
    from app.models.catalog import DegreeCatalog
    from app.db.session import get_db
    from app.main import app

    gen = app.dependency_overrides[get_db]()
    session = await gen.__anext__()
    session.add(DegreeCatalog(name="MBBS"))
    session.add(DegreeCatalog(name="MD"))
    await session.commit()

    resp = await client.get("/api/v1/catalog/degrees", params={"q": "mb"})
    assert resp.status_code == 200
    names = [r["name"] for r in resp.json()]
    assert names == ["MBBS"]
```

- [ ] **Step 3: Run to verify it fails**

Run: `pytest tests/api/v1/test_catalog.py -v`
Expected: FAIL — 404.

- [ ] **Step 4: Implement**

Create `app/api/v1/endpoints/catalog.py`:

```python
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.catalog import DegreeCatalog, SpecialityCatalog
from app.schemas.catalog import CatalogItem

router = APIRouter()


async def _search(db: AsyncSession, model, q: str | None) -> list[CatalogItem]:
    stmt = select(model).order_by(model.name).limit(50)
    if q:
        stmt = stmt.where(model.name.ilike(f"{q}%"))
    rows = (await db.execute(stmt)).scalars().all()
    return [CatalogItem.model_validate(r) for r in rows]


@router.get("/degrees", response_model=list[CatalogItem], summary="Search degree catalog")
async def degrees(q: str | None = None, db: AsyncSession = Depends(get_db)):
    return await _search(db, DegreeCatalog, q)


@router.get("/specialities", response_model=list[CatalogItem], summary="Search speciality catalog")
async def specialities(q: str | None = None, db: AsyncSession = Depends(get_db)):
    return await _search(db, SpecialityCatalog, q)
```

- [ ] **Step 5: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.catalog import router as catalog_router
api_v1_router.include_router(catalog_router, prefix="/catalog", tags=["catalog"])
```

- [ ] **Step 6: Run, then commit**

Run: `pytest tests/api/v1/test_catalog.py -v` → PASS.

```bash
git add app/schemas/catalog.py app/api/v1/endpoints/catalog.py app/api/v1/router.py tests/api/v1/test_catalog.py
git commit -m "feat(api): add catalog search endpoints"
```

---

### Task B7: Hospitals search + create (shared master)

**Files:**
- Create: `acute-api/app/schemas/hospital.py`
- Create: `acute-api/app/api/v1/endpoints/hospitals.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_hospitals.py`

**Interfaces:**
- Produces: `GET /api/v1/hospitals?q=` → `list[HospitalOut]` (ilike contains, cap 50); `POST /api/v1/hospitals` body `HospitalCreate(name, type, city?, address?)` → `HospitalOut`, sets `created_by` to the current doctor. Both require auth.

- [ ] **Step 1: Write the schema**

Create `app/schemas/hospital.py`:

```python
import uuid
from typing import Literal

from pydantic import BaseModel, ConfigDict


class HospitalCreate(BaseModel):
    name: str
    type: Literal["hospital", "clinic"] = "hospital"
    city: str | None = None
    address: str | None = None


class HospitalOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    type: str
    city: str | None
    address: str | None
```

- [ ] **Step 2: Write the failing test**

Create `tests/api/v1/test_hospitals.py`:

```python
from httpx import AsyncClient


async def test_create_then_search_hospital(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    created = await client.post(
        "/api/v1/hospitals",
        json={"name": "Apollo Clinic", "type": "clinic", "city": "Pune"},
        headers=h,
    )
    assert created.status_code == 201
    found = await client.get("/api/v1/hospitals", params={"q": "apollo"}, headers=h)
    assert found.status_code == 200
    assert found.json()[0]["name"] == "Apollo Clinic"


async def test_hospitals_require_auth(client: AsyncClient) -> None:
    assert (await client.get("/api/v1/hospitals")).status_code == 401
```

- [ ] **Step 3: Run to verify it fails**

Run: `pytest tests/api/v1/test_hospitals.py -v`
Expected: FAIL — 404.

- [ ] **Step 4: Implement**

Create `app/api/v1/endpoints/hospitals.py`:

```python
from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.hospital import Hospital
from app.schemas.hospital import HospitalCreate, HospitalOut

router = APIRouter()


@router.get("", response_model=list[HospitalOut], summary="Search shared hospital/clinic master")
async def search_hospitals(
    q: str | None = None,
    db: AsyncSession = Depends(get_db),
    _: Doctor = Depends(get_current_doctor),
):
    stmt = select(Hospital).order_by(Hospital.name).limit(50)
    if q:
        stmt = stmt.where(Hospital.name.ilike(f"%{q}%"))
    rows = (await db.execute(stmt)).scalars().all()
    return [HospitalOut.model_validate(r) for r in rows]


@router.post("", response_model=HospitalOut, status_code=status.HTTP_201_CREATED, summary="Add a hospital/clinic")
async def create_hospital(
    body: HospitalCreate,
    db: AsyncSession = Depends(get_db),
    doctor: Doctor = Depends(get_current_doctor),
):
    hospital = Hospital(**body.model_dump(), created_by=doctor.id)
    db.add(hospital)
    await db.commit()
    await db.refresh(hospital)
    return HospitalOut.model_validate(hospital)
```

- [ ] **Step 5: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.hospitals import router as hospitals_router
api_v1_router.include_router(hospitals_router, prefix="/hospitals", tags=["hospitals"])
```

- [ ] **Step 6: Run, then commit**

Run: `pytest tests/api/v1/test_hospitals.py -v` → PASS.

```bash
git add app/schemas/hospital.py app/api/v1/endpoints/hospitals.py app/api/v1/router.py tests/api/v1/test_hospitals.py
git commit -m "feat(api): add shared hospital master search and create"
```

---

### Task B8: Educations CRUD

**Files:**
- Create: `acute-api/app/api/v1/endpoints/educations.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_educations.py`

**Interfaces:**
- Consumes: `EducationCreate/Update/Out` (B4), `get_current_doctor`.
- Produces: `POST/PATCH/DELETE /api/v1/doctors/me/educations[/{id}]`. POST returns `201 EducationOut`; PATCH returns `EducationOut`; DELETE returns `204`. A record whose `doctor_id` ≠ current doctor yields `404`.

- [ ] **Step 1: Write the failing tests**

Create `tests/api/v1/test_educations.py`:

```python
from httpx import AsyncClient


async def test_add_list_update_delete_education(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor(first_name="A", last_name="B")
    h = auth_headers(doctor)

    created = await client.post(
        "/api/v1/doctors/me/educations",
        json={"degree": "MBBS", "registration_number": "REG-1"},
        headers=h,
    )
    assert created.status_code == 201
    edu_id = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["education"] is True
    assert me.json()["profile_completion"] == 40  # personal + education

    updated = await client.patch(
        f"/api/v1/doctors/me/educations/{edu_id}",
        json={"institution": "AIIMS"},
        headers=h,
    )
    assert updated.json()["institution"] == "AIIMS"

    deleted = await client.delete(f"/api/v1/doctors/me/educations/{edu_id}", headers=h)
    assert deleted.status_code == 204


async def test_cannot_touch_other_doctors_education(client: AsyncClient, make_doctor, auth_headers) -> None:
    owner = await make_doctor(mobile="911111111111")
    other = await make_doctor(mobile="912222222222")
    created = await client.post(
        "/api/v1/doctors/me/educations",
        json={"degree": "MD", "registration_number": "R2"},
        headers=auth_headers(owner),
    )
    edu_id = created.json()["id"]
    resp = await client.delete(
        f"/api/v1/doctors/me/educations/{edu_id}", headers=auth_headers(other)
    )
    assert resp.status_code == 404
```

- [ ] **Step 2: Run to verify it fails**

Run: `pytest tests/api/v1/test_educations.py -v`
Expected: FAIL — 404 on POST route.

- [ ] **Step 3: Implement**

Create `app/api/v1/endpoints/educations.py`:

```python
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.schemas.education import EducationCreate, EducationOut, EducationUpdate

router = APIRouter()


async def _owned(db: AsyncSession, doctor: Doctor, edu_id: uuid.UUID) -> DoctorEducation:
    edu = await db.get(DoctorEducation, edu_id)
    if edu is None or edu.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Education not found")
    return edu


@router.post("", response_model=EducationOut, status_code=status.HTTP_201_CREATED)
async def add_education(
    body: EducationCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = DoctorEducation(doctor_id=doctor.id, **body.model_dump())
    db.add(edu)
    await db.commit()
    await db.refresh(edu)
    return EducationOut.model_validate(edu)


@router.patch("/{edu_id}", response_model=EducationOut)
async def update_education(
    edu_id: uuid.UUID,
    body: EducationUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = await _owned(db, doctor, edu_id)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(edu, field, value)
    await db.commit()
    await db.refresh(edu)
    return EducationOut.model_validate(edu)


@router.delete("/{edu_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_education(
    edu_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = await _owned(db, doctor, edu_id)
    await db.delete(edu)
    await db.commit()
```

- [ ] **Step 4: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.educations import router as educations_router
api_v1_router.include_router(
    educations_router, prefix="/doctors/me/educations", tags=["educations"]
)
```

- [ ] **Step 5: Run, then commit**

Run: `pytest tests/api/v1/test_educations.py -v` → PASS.

```bash
git add app/api/v1/endpoints/educations.py app/api/v1/router.py tests/api/v1/test_educations.py
git commit -m "feat(api): add educations CRUD"
```

---

### Task B9: Specialities CRUD

**Files:**
- Create: `acute-api/app/api/v1/endpoints/specialities.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_specialities.py`

**Interfaces:**
- Produces: `POST /api/v1/doctors/me/specialities` (`201 SpecialityOut`) and `DELETE /api/v1/doctors/me/specialities/{id}` (`204`); `404` for non-owned.

- [ ] **Step 1: Write the failing test**

Create `tests/api/v1/test_specialities.py`:

```python
from httpx import AsyncClient


async def test_add_and_delete_speciality(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    created = await client.post(
        "/api/v1/doctors/me/specialities", json={"name": "Cardiology"}, headers=h
    )
    assert created.status_code == 201
    sid = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["speciality"] is True

    assert (await client.delete(f"/api/v1/doctors/me/specialities/{sid}", headers=h)).status_code == 204
```

- [ ] **Step 2: Run to verify it fails**

Run: `pytest tests/api/v1/test_specialities.py -v` → FAIL (404).

- [ ] **Step 3: Implement**

Create `app/api/v1/endpoints/specialities.py`:

```python
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.speciality import DoctorSpeciality
from app.schemas.speciality import SpecialityCreate, SpecialityOut

router = APIRouter()


@router.post("", response_model=SpecialityOut, status_code=status.HTTP_201_CREATED)
async def add_speciality(
    body: SpecialityCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    row = DoctorSpeciality(doctor_id=doctor.id, name=body.name)
    db.add(row)
    await db.commit()
    await db.refresh(row)
    return SpecialityOut.model_validate(row)


@router.delete("/{spec_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_speciality(
    spec_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    row = await db.get(DoctorSpeciality, spec_id)
    if row is None or row.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Speciality not found")
    await db.delete(row)
    await db.commit()
```

- [ ] **Step 4: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.specialities import router as specialities_router
api_v1_router.include_router(
    specialities_router, prefix="/doctors/me/specialities", tags=["specialities"]
)
```

- [ ] **Step 5: Run, then commit**

Run: `pytest tests/api/v1/test_specialities.py -v` → PASS.

```bash
git add app/api/v1/endpoints/specialities.py app/api/v1/router.py tests/api/v1/test_specialities.py
git commit -m "feat(api): add specialities CRUD"
```

---

### Task B10: Experiences CRUD

**Files:**
- Create: `acute-api/app/api/v1/endpoints/experiences.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_experiences.py`

**Interfaces:**
- Consumes: `ExperienceCreate/Update/Out` (B4), `Hospital` (B2).
- Produces: `POST/PATCH/DELETE /api/v1/doctors/me/experiences[/{id}]`. POST validates `hospital_id` exists (`422` if not). Returns `ExperienceOut` (includes nested `hospital` and empty `working_hours`).

- [ ] **Step 1: Write the failing test**

Create `tests/api/v1/test_experiences.py`:

```python
from httpx import AsyncClient


async def _make_hospital(client, headers) -> str:
    resp = await client.post(
        "/api/v1/hospitals", json={"name": "City Hospital", "type": "hospital"}, headers=headers
    )
    return resp.json()["id"]


async def test_add_update_delete_experience(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    hospital_id = await _make_hospital(client, h)

    created = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": hospital_id, "designation": "Consultant", "is_current": True},
        headers=h,
    )
    assert created.status_code == 201
    assert created.json()["hospital"]["name"] == "City Hospital"
    exp_id = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["experience"] is True

    updated = await client.patch(
        f"/api/v1/doctors/me/experiences/{exp_id}",
        json={"designation": "Senior Consultant"},
        headers=h,
    )
    assert updated.json()["designation"] == "Senior Consultant"

    assert (await client.delete(f"/api/v1/doctors/me/experiences/{exp_id}", headers=h)).status_code == 204


async def test_experience_rejects_unknown_hospital(client: AsyncClient, make_doctor, auth_headers) -> None:
    import uuid
    doctor = await make_doctor()
    resp = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": str(uuid.uuid4())},
        headers=auth_headers(doctor),
    )
    assert resp.status_code == 422
```

- [ ] **Step 2: Run to verify it fails**

Run: `pytest tests/api/v1/test_experiences.py -v` → FAIL (404).

- [ ] **Step 3: Implement**

Create `app/api/v1/endpoints/experiences.py`:

```python
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.experience import DoctorExperience
from app.models.hospital import Hospital
from app.schemas.experience import ExperienceCreate, ExperienceOut, ExperienceUpdate

router = APIRouter()


async def _owned(db: AsyncSession, doctor: Doctor, exp_id: uuid.UUID) -> DoctorExperience:
    exp = await db.get(DoctorExperience, exp_id)
    if exp is None or exp.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Experience not found")
    return exp


@router.post("", response_model=ExperienceOut, status_code=status.HTTP_201_CREATED)
async def add_experience(
    body: ExperienceCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    if await db.get(Hospital, body.hospital_id) is None:
        raise HTTPException(status_code=422, detail="Unknown hospital_id")
    exp = DoctorExperience(doctor_id=doctor.id, **body.model_dump())
    db.add(exp)
    await db.commit()
    await db.refresh(exp)
    return ExperienceOut.model_validate(exp)


@router.patch("/{exp_id}", response_model=ExperienceOut)
async def update_experience(
    exp_id: uuid.UUID,
    body: ExperienceUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    exp = await _owned(db, doctor, exp_id)
    data = body.model_dump(exclude_unset=True)
    if "hospital_id" in data and await db.get(Hospital, data["hospital_id"]) is None:
        raise HTTPException(status_code=422, detail="Unknown hospital_id")
    for field, value in data.items():
        setattr(exp, field, value)
    await db.commit()
    await db.refresh(exp)
    return ExperienceOut.model_validate(exp)


@router.delete("/{exp_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_experience(
    exp_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    exp = await _owned(db, doctor, exp_id)
    await db.delete(exp)
    await db.commit()
```

- [ ] **Step 4: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.experiences import router as experiences_router
api_v1_router.include_router(
    experiences_router, prefix="/doctors/me/experiences", tags=["experiences"]
)
```

- [ ] **Step 5: Run, then commit**

Run: `pytest tests/api/v1/test_experiences.py -v` → PASS.

```bash
git add app/api/v1/endpoints/experiences.py app/api/v1/router.py tests/api/v1/test_experiences.py
git commit -m "feat(api): add experiences CRUD"
```

---

### Task B11: Working-hours endpoints (nested under experience)

**Files:**
- Create: `acute-api/app/api/v1/endpoints/working_hours.py`
- Modify: `acute-api/app/api/v1/router.py`
- Test: `acute-api/tests/api/v1/test_working_hours.py`

**Interfaces:**
- Consumes: `WorkingHourCreate/Out` (B4), `DoctorExperience` ownership.
- Produces: `GET/POST /api/v1/doctors/me/experiences/{exp_id}/working-hours` and `DELETE .../working-hours/{wid}`. POST returns `201 WorkingHourOut`. Ownership of the parent experience enforced (`404`).

- [ ] **Step 1: Write the failing test**

Create `tests/api/v1/test_working_hours.py`:

```python
from httpx import AsyncClient


async def _experience(client, headers) -> str:
    hosp = await client.post(
        "/api/v1/hospitals", json={"name": "Care Clinic", "type": "clinic"}, headers=headers
    )
    exp = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": hosp.json()["id"]},
        headers=headers,
    )
    return exp.json()["id"]


async def test_add_list_delete_working_hours(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    exp_id = await _experience(client, h)

    created = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours",
        json={"day_of_week": 0, "start_time": "09:00:00", "end_time": "13:00:00"},
        headers=h,
    )
    assert created.status_code == 201
    wid = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["working_hours"] is True
    assert me.json()["profile_completion"] == 40  # experience + working_hours

    listed = await client.get(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours", headers=h
    )
    assert len(listed.json()) == 1

    assert (
        await client.delete(
            f"/api/v1/doctors/me/experiences/{exp_id}/working-hours/{wid}", headers=h
        )
    ).status_code == 204


async def test_rejects_end_before_start(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    exp_id = await _experience(client, h)
    resp = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours",
        json={"day_of_week": 0, "start_time": "17:00:00", "end_time": "09:00:00"},
        headers=h,
    )
    assert resp.status_code == 422
```

- [ ] **Step 2: Run to verify it fails**

Run: `pytest tests/api/v1/test_working_hours.py -v` → FAIL (404).

- [ ] **Step 3: Implement**

Create `app/api/v1/endpoints/working_hours.py`:

```python
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.experience import DoctorExperience
from app.models.working_hours import WorkingHour
from app.schemas.working_hours import WorkingHourCreate, WorkingHourOut

router = APIRouter()


async def _owned_experience(db: AsyncSession, doctor: Doctor, exp_id: uuid.UUID) -> DoctorExperience:
    exp = await db.get(DoctorExperience, exp_id)
    if exp is None or exp.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Experience not found")
    return exp


@router.get("", response_model=list[WorkingHourOut])
async def list_working_hours(
    exp_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    rows = (
        await db.execute(select(WorkingHour).where(WorkingHour.experience_id == exp_id))
    ).scalars().all()
    return [WorkingHourOut.model_validate(r) for r in rows]


@router.post("", response_model=WorkingHourOut, status_code=status.HTTP_201_CREATED)
async def add_working_hour(
    exp_id: uuid.UUID,
    body: WorkingHourCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    row = WorkingHour(experience_id=exp_id, **body.model_dump())
    db.add(row)
    await db.commit()
    await db.refresh(row)
    return WorkingHourOut.model_validate(row)


@router.delete("/{wid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_working_hour(
    exp_id: uuid.UUID,
    wid: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    row = await db.get(WorkingHour, wid)
    if row is None or row.experience_id != exp_id:
        raise HTTPException(status_code=404, detail="Working hour not found")
    await db.delete(row)
    await db.commit()
```

- [ ] **Step 4: Mount the router**

In `app/api/v1/router.py`, add:

```python
from app.api.v1.endpoints.working_hours import router as working_hours_router
api_v1_router.include_router(
    working_hours_router,
    prefix="/doctors/me/experiences/{exp_id}/working-hours",
    tags=["working-hours"],
)
```

- [ ] **Step 5: Run the full suite, then commit**

Run: `pytest -v`
Expected: all tests pass.

```bash
git add app/api/v1/endpoints/working_hours.py app/api/v1/router.py tests/api/v1/test_working_hours.py
git commit -m "feat(api): add working-hours endpoints"
```

---

### Task B12: Documentation and `.env.example`

**Files:**
- Modify: `acute-api/.env.example`
- Create: `acute-api/doc/v1/auth.md`, `doctors.md`, `hospitals.md`, `catalog.md`
- Modify: `acute-api/doc/README.md` (add links to new docs)

- [ ] **Step 1: Add JWT secret to `.env.example`**

Append to `.env.example`:

```env
# JWT session signing (use a long random value in each environment)
JWT_SECRET=change-me-to-a-long-random-string
JWT_EXP_DAYS=30
```

- [ ] **Step 2: Write `doc/v1/auth.md`**

Document `POST /auth/login`: request `{access_token}`, response `{token, token_type, is_new, onboarding_needed, profile_completion}`, `401` on failed verification, `502` on MSG91 outage. Mirror the structure of `doc/v1/otp.md` (Overview, Endpoints, Request/Response tables, Error Responses, curl example).

- [ ] **Step 3: Write `doc/v1/doctors.md`**

Document `GET /doctors/me`, `PATCH /doctors/me`, and all `/doctors/me/{educations,specialities,experiences}` and `.../experiences/{id}/working-hours` routes: methods, request bodies (field tables from the B4/B6–B11 schemas), response shapes, the `profile_completion` (0–100, five 20% sections) and `sections` map, `401`/`404`/`422` semantics. State that all routes require `Authorization: Bearer <token>`.

- [ ] **Step 4: Write `doc/v1/hospitals.md` and `doc/v1/catalog.md`**

`hospitals.md`: `GET /hospitals?q=` (contains search) and `POST /hospitals` (shared master, `created_by` recorded), auth required. `catalog.md`: `GET /catalog/degrees?q=` and `GET /catalog/specialities?q=` (prefix search, seeded lists).

- [ ] **Step 5: Link new docs in `doc/README.md`** and commit

```bash
git add .env.example doc/v1/auth.md doc/v1/doctors.md doc/v1/hospitals.md doc/v1/catalog.md doc/README.md
git commit -m "docs(api): document onboarding endpoints and JWT env"
```

---

## Self-Review Notes

- **Spec coverage:** auth/JWT (B1, B3, B5), data model + migration + seed (B2), completion (B4), personal info (B4 PATCH), education (B8), speciality (B9), experience + hospital link (B10), working hours (B11), shared hospital master (B7), catalog pickers (B6), docs (B12). All spec sections map to a task.
- **Type consistency:** `compute_completion` returns `(int, dict[str,bool])`, consumed identically in B4 and B5; `EducationOut/ExperienceOut/...` defined in B4 and reused by name in B8/B10/B11; ownership helper pattern (`_owned`) consistent across sub-resources.
- **Note for executor:** conftest creates tables with `Base.metadata.create_all` (fast, no seed). Tests that need catalog rows insert them directly (see B6). The Alembic seed is verified separately in B2 Step 7 against Postgres.
