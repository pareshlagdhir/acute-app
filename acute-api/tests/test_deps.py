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
