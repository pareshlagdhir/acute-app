from unittest.mock import AsyncMock, MagicMock, patch

from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession

from app.db.base import Base
from app.db.session import SessionLocal, engine, get_db


def test_engine_is_async():
    assert isinstance(engine, AsyncEngine)


def test_base_has_metadata():
    assert hasattr(Base, "metadata")


async def test_get_db_yields_async_session():
    mock_session = AsyncMock(spec=AsyncSession)
    mock_ctx = MagicMock()
    mock_ctx.__aenter__ = AsyncMock(return_value=mock_session)
    mock_ctx.__aexit__ = AsyncMock(return_value=False)
    with patch("app.db.session.SessionLocal", return_value=mock_ctx):
        gen = get_db()
        session = await gen.__anext__()
        assert session is mock_session
        await gen.aclose()
