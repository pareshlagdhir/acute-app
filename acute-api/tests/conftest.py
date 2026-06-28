import uuid
from collections.abc import AsyncGenerator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

import app.models  # noqa: F401  (register tables)
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
