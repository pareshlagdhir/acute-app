import logging

import httpx

from app.core.config import settings
from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)

logger = logging.getLogger("app.msg91")


class MSG91Service:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self._client = client

    async def send_otp(self, mobile: str) -> None:
        params = {
            "template_id": settings.MSG91_OTP_TEMPLATE_ID,
            "mobile": mobile,
            "authkey": settings.MSG91_AUTHKEY,
        }
        data = await self._request("POST", settings.MSG91_OTP_SEND_URL, params=params)
        if data.get("type") != "success":
            logger.warning("MSG91 send failed: %s", data.get("message"))
            raise MSG91RequestError(data.get("message") or "OTP send failed")

    async def verify_otp(self, mobile: str, otp: str) -> None:
        params = {"otp": otp, "mobile": mobile}
        headers = {"authkey": settings.MSG91_AUTHKEY}
        data = await self._request(
            "GET", settings.MSG91_OTP_VERIFY_URL, params=params, headers=headers
        )
        if data.get("type") != "success":
            logger.warning("MSG91 verify failed: %s", data.get("message"))
            raise OTPVerificationError(data.get("message") or "OTP verification failed")

    async def resend_otp(self, mobile: str, retrytype: str) -> None:
        params = {
            "authkey": settings.MSG91_AUTHKEY,
            "retrytype": retrytype,
            "mobile": mobile,
        }
        data = await self._request("GET", settings.MSG91_OTP_RETRY_URL, params=params)
        if data.get("type") != "success":
            logger.warning("MSG91 resend failed: %s", data.get("message"))
            raise MSG91RequestError(data.get("message") or "OTP resend failed")

    async def _request(
        self,
        method: str,
        url: str,
        *,
        params: dict[str, str],
        headers: dict[str, str] | None = None,
    ) -> dict:
        try:
            resp = await self._client.request(method, url, params=params, headers=headers)
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as exc:
            raise MSG91UnavailableError(str(exc)) from exc
        except httpx.TransportError as exc:
            raise MSG91UnavailableError(str(exc)) from exc
