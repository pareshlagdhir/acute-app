import pytest
import respx
import httpx
from httpx import AsyncClient


MSG91_VERIFY_URL = "https://control.msg91.com/api/v5/widget/verifyAccessToken"


async def test_otp_verify_returns_200_on_valid_token(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "Mobile verified successfully.", "mobile": "91XXXXXXXXXX"})
        )
        response = await client.post("/api/v1/otp/verify", json={"access_token": "valid.jwt.token"})
    assert response.status_code == 200


async def test_otp_verify_returns_verified_true_on_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "Mobile verified successfully.", "mobile": "91XXXXXXXXXX"})
        )
        data = (await client.post("/api/v1/otp/verify", json={"access_token": "valid.jwt.token"})).json()
    assert data["verified"] is True
    assert "mobile" in data


async def test_otp_verify_returns_verified_false_on_failure(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "Token expired or invalid."})
        )
        response = await client.post("/api/v1/otp/verify", json={"access_token": "bad.jwt.token"})
    assert response.status_code == 200
    assert response.json()["verified"] is False


async def test_otp_verify_rejects_missing_access_token(client: AsyncClient) -> None:
    response = await client.post("/api/v1/otp/verify", json={})
    assert response.status_code == 422


async def test_otp_verify_content_type_is_json(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "mobile": "91XXXXXXXXXX"})
        )
        response = await client.post("/api/v1/otp/verify", json={"access_token": "tok"})
    assert "application/json" in response.headers["content-type"]


async def test_otp_verify_msg91_down_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(MSG91_VERIFY_URL).mock(side_effect=httpx.ConnectError("unreachable"))
        response = await client.post("/api/v1/otp/verify", json={"access_token": "tok"})
    assert response.status_code == 502
