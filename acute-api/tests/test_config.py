from app.core.config import settings


def test_database_url_is_async_postgres():
    assert settings.DATABASE_URL.startswith("postgresql+asyncpg://")
    assert "acute-db" in settings.DATABASE_URL
    assert "acute-user" in settings.DATABASE_URL


def test_redis_url_present():
    assert settings.REDIS_URL.startswith("redis://")
