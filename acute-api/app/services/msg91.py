import logging

import httpx

from app.core.config import settings
from app.core.exceptions import MSG91UnavailableError
from app.schemas.otp import OTPVerifyResponse

logger = logging.getLogger("app.msg91")


class MSG91Service:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self._client = client

    async def verify_otp_token(self, access_token: str) -> OTPVerifyResponse:
        if not settings.MSG91_AUTHKEY or settings.MSG91_AUTHKEY == "your_msg91_authkey_here":
            # Without a real dashboard auth key MSG91 cannot validate the access
            # token, so every login is rejected and the OTP stays "unverified"
            # in the MSG91 logs. Surface this loudly rather than silently 401.
            logger.error(
                "MSG91_AUTHKEY is unset/placeholder; verifyAccessToken will never "
                "succeed. Set a real auth key in acute-api/.env."
            )

        payload = {
            "authkey": settings.MSG91_AUTHKEY,
            "access-token": access_token,
        }
        try:
            resp = await self._client.post(settings.MSG91_VERIFY_URL, json=payload)
            resp.raise_for_status()
            data = resp.json()
        except httpx.HTTPStatusError as exc:
            raise MSG91UnavailableError(str(exc)) from exc
        except httpx.TransportError as exc:
            raise MSG91UnavailableError(str(exc)) from exc

        success = data.get("type") == "success"
        if not success:
            # `data` carries MSG91's own reason (e.g. invalid authkey, expired
            # token). Logged without the raw token/authkey so it is safe.
            logger.warning(
                "MSG91 verifyAccessToken did not succeed: type=%s message=%s",
                data.get("type"),
                data.get("message"),
            )
        return OTPVerifyResponse(
            verified=success,
            mobile=data.get("mobile"),
            message=data.get("message"),
        )
