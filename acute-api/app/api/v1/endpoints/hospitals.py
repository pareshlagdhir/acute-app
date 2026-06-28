from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.hospital import Hospital
from app.schemas.hospital import HospitalCreate, HospitalOut

router = APIRouter()


@router.get("", response_model=list[HospitalOut], summary="Search shared hospital/clinic master")
async def search_hospitals(
    q: str | None = None,
    db: AsyncSession = Depends(get_db),
    _: Doctor = Depends(get_current_doctor),
):
    stmt = select(Hospital).order_by(Hospital.name).limit(50)
    if q:
        stmt = stmt.where(Hospital.name.ilike(f"%{q}%"))
    rows = (await db.execute(stmt)).scalars().all()
    return [HospitalOut.model_validate(r) for r in rows]


@router.post("", response_model=HospitalOut, status_code=status.HTTP_201_CREATED, summary="Add a hospital/clinic")
async def create_hospital(
    body: HospitalCreate,
    db: AsyncSession = Depends(get_db),
    doctor: Doctor = Depends(get_current_doctor),
):
    hospital = Hospital(**body.model_dump(), created_by=doctor.id)
    db.add(hospital)
    await db.commit()
    await db.refresh(hospital)
    return HospitalOut.model_validate(hospital)
