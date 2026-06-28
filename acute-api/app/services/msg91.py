import httpx

from app.core.config import settings
from app.core.exceptions import MSG91UnavailableError
from app.schemas.otp import OTPVerifyResponse


class MSG91Service:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self._client = client

    async def verify_otp_token(self, access_token: str) -> OTPVerifyResponse:
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
        return OTPVerifyResponse(
            verified=success,
            mobile=data.get("mobile"),
            message=data.get("message"),
        )
