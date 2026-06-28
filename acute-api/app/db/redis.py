from collections.abc import AsyncGenerator

from redis.asyncio import Redis

from app.core.config import settings


async def get_redis() -> AsyncGenerator[Redis, None]:
    """Yield an async Redis client built from settings.REDIS_URL, closing it after use."""
    client = Redis.from_url(settings.REDIS_URL, decode_responses=True)
    try:
        yield client
    finally:
        await client.aclose()
