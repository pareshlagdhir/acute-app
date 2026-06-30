import httpx
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.auth import LoginResponse
from app.schemas.otp import (
    OTPResendRequest,
    OTPSendRequest,
    OTPSendResponse,
    OTPVerifyRequest,
)
from app.services.msg91 import MSG91Service
from app.services.profile import compute_completion

router = APIRouter()


@router.post("/send", response_model=OTPSendResponse, summary="Send an OTP via MSG91")
async def send_otp(body: OTPSendRequest) -> OTPSendResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.send_otp(body.mobile)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except MSG91RequestError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
    return OTPSendResponse(sent=True)


@router.post("/verify", response_model=LoginResponse, summary="Verify OTP and issue a session")
async def verify_otp(
    body: OTPVerifyRequest, db: AsyncSession = Depends(get_db)
) -> LoginResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.verify_otp(body.mobile, body.otp)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except OTPVerificationError as exc:
            raise HTTPException(status_code=401, detail=str(exc)) from exc

    existing = (
        await db.execute(select(Doctor).where(Doctor.mobile == body.mobile))
    ).scalar_one_or_none()
    is_new = existing is None
    doctor = existing or Doctor(mobile=body.mobile)
    if is_new:
        db.add(doctor)
        await db.commit()
        await db.refresh(doctor)

    pct, _ = compute_completion(doctor)
    return LoginResponse(
        token=create_access_token(str(doctor.id)),
        is_new=is_new,
        onboarding_needed=pct < 100,
        profile_completion=pct,
    )


@router.post("/resend", response_model=OTPSendResponse, summary="Resend an OTP via MSG91")
async def resend_otp(body: OTPResendRequest) -> OTPSendResponse:
    retrytype = "voice" if body.voice else "text"
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.resend_otp(body.mobile, retrytype)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except MSG91RequestError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
    return OTPSendResponse(sent=True)
