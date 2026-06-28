import httpx
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import MSG91UnavailableError
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.auth import LoginRequest, LoginResponse
from app.services.msg91 import MSG91Service
from app.services.profile import compute_completion

router = APIRouter()


@router.post("/login", response_model=LoginResponse, summary="Exchange MSG91 token for a session")
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)) -> LoginResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            result = await svc.verify_otp_token(body.access_token)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc

    if not result.verified or not result.mobile:
        raise HTTPException(status_code=401, detail="OTP verification failed")

    existing = (
        await db.execute(select(Doctor).where(Doctor.mobile == result.mobile))
    ).scalar_one_or_none()
    is_new = existing is None
    doctor = existing or Doctor(mobile=result.mobile)
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
