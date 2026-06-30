import httpx
import respx
from httpx import AsyncClient

from app.core.config import settings

SEND_URL = settings.MSG91_OTP_SEND_URL
VERIFY_URL = settings.MSG91_OTP_VERIFY_URL
RETRY_URL = settings.MSG91_OTP_RETRY_URL

MOBILE = "919876543210"


# --- send ---
async def test_send_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "request_id": "r1"})
        )
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 200
    assert resp.json()["sent"] is True


async def test_send_msg91_error_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "invalid template"})
        )
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 502


async def test_send_msg91_down_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(side_effect=httpx.ConnectError("down"))
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 502


async def test_send_rejects_bad_mobile(client: AsyncClient) -> None:
    resp = await client.post("/api/v1/otp/send", json={"mobile": "0123"})
    assert resp.status_code == 422


# --- verify (merged login) ---
async def test_verify_new_doctor_creates_record_and_token(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "OTP verified success"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["is_new"] is True
    assert body["onboarding_needed"] is True
    assert body["profile_completion"] == 0
    assert body["token"]


async def test_verify_existing_doctor_is_not_new(client: AsyncClient, make_doctor) -> None:
    await make_doctor(mobile=MOBILE)
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 200
    assert resp.json()["is_new"] is False


async def test_verify_wrong_otp_returns_401(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "OTP expired"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "0000"})
    assert resp.status_code == 401


async def test_verify_msg91_down_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(side_effect=httpx.ConnectError("down"))
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 502


async def test_verify_rejects_missing_otp(client: AsyncClient) -> None:
    resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE})
    assert resp.status_code == 422


# --- resend ---
async def test_resend_text_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "retry send successfully"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE})
    assert resp.status_code == 200
    assert resp.json()["sent"] is True


async def test_resend_voice_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE, "voice": True})
    assert resp.status_code == 200


async def test_resend_error_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "Mobile number empty"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE})
    assert resp.status_code == 502
