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
