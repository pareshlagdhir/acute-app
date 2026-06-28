from redis.asyncio import Redis

from app.db.redis import get_redis


async def test_get_redis_yields_async_client():
    gen = get_redis()
    client = await gen.__anext__()
    assert isinstance(client, Redis)
    await gen.aclose()
