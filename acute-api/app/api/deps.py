import uuid

import jwt
from fastapi import Depends, Header, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.doctor import Doctor


async def get_current_doctor(
    authorization: str | None = Header(default=None),
    db: AsyncSession = Depends(get_db),
) -> Doctor:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.split(" ", 1)[1]
    try:
        subject = decode_access_token(token)
        doctor_id = uuid.UUID(subject)
    except (jwt.InvalidTokenError, ValueError) as exc:
        raise HTTPException(status_code=401, detail="Invalid token") from exc
    doctor = await db.get(Doctor, doctor_id)
    if doctor is None:
        raise HTTPException(status_code=401, detail="Unknown doctor")
    await db.refresh(doctor)
    return doctor
