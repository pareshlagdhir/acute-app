from fastapi import APIRouter, HTTPException
import httpx

from app.core.exceptions import MSG91UnavailableError
from app.schemas.otp import OTPVerifyRequest, OTPVerifyResponse
from app.services.msg91 import MSG91Service

router = APIRouter()


@router.post("/verify", response_model=OTPVerifyResponse, summary="Verify MSG91 OTP widget token")
async def verify_otp(body: OTPVerifyRequest) -> OTPVerifyResponse:
    async with httpx.AsyncClient() as client:
        svc = MSG91Service(client)
        try:
            return await svc.verify_otp_token(body.access_token)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail=f"MSG91 unreachable: {exc}") from exc
