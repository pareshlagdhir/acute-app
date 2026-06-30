import httpx
import pytest
import respx

from app.core.config import settings
from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)
from app.services.msg91 import MSG91Service


@pytest.fixture
async def svc():
    async with httpx.AsyncClient() as client:
        yield MSG91Service(client)


async def test_send_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "request_id": "abc"})
        )
        await svc.send_otp("919876543210")  # no exception == pass


async def test_send_otp_error_raises_request_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "invalid template"})
        )
        with pytest.raises(MSG91RequestError):
            await svc.send_otp("919876543210")


async def test_send_otp_transport_error_raises_unavailable(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(side_effect=httpx.ConnectError("down"))
        with pytest.raises(MSG91UnavailableError):
            await svc.send_otp("919876543210")


async def test_verify_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "OTP verified success"})
        )
        await svc.verify_otp("919876543210", "1234")


async def test_verify_otp_error_raises_verification_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "OTP expired"})
        )
        with pytest.raises(OTPVerificationError):
            await svc.verify_otp("919876543210", "0000")


async def test_resend_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "retry send successfully"})
        )
        await svc.resend_otp("919876543210", "text")


async def test_resend_otp_error_raises_request_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "Mobile number empty"})
        )
        with pytest.raises(MSG91RequestError):
            await svc.resend_otp("919876543210", "voice")
