import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.experience import DoctorExperience
from app.models.working_hours import WorkingHour
from app.schemas.working_hours import WorkingHourCreate, WorkingHourOut

router = APIRouter()


async def _owned_experience(db: AsyncSession, doctor: Doctor, exp_id: uuid.UUID) -> DoctorExperience:
    exp = await db.get(DoctorExperience, exp_id)
    if exp is None or exp.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Experience not found")
    return exp


@router.get("", response_model=list[WorkingHourOut])
async def list_working_hours(
    exp_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    rows = (
        await db.execute(select(WorkingHour).where(WorkingHour.experience_id == exp_id))
    ).scalars().all()
    return [WorkingHourOut.model_validate(r) for r in rows]


@router.post("", response_model=WorkingHourOut, status_code=status.HTTP_201_CREATED)
async def add_working_hour(
    exp_id: uuid.UUID,
    body: WorkingHourCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    row = WorkingHour(experience_id=exp_id, **body.model_dump())
    db.add(row)
    await db.commit()
    await db.refresh(row)
    return WorkingHourOut.model_validate(row)


@router.delete("/{wid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_working_hour(
    exp_id: uuid.UUID,
    wid: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    await _owned_experience(db, doctor, exp_id)
    row = await db.get(WorkingHour, wid)
    if row is None or row.experience_id != exp_id:
        raise HTTPException(status_code=404, detail="Working hour not found")
    await db.delete(row)
    await db.commit()
