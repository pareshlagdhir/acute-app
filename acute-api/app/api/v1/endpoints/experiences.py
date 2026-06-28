import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.experience import DoctorExperience
from app.models.hospital import Hospital
from app.schemas.experience import ExperienceCreate, ExperienceOut, ExperienceUpdate

router = APIRouter()


async def _owned(db: AsyncSession, doctor: Doctor, exp_id: uuid.UUID) -> DoctorExperience:
    exp = await db.get(DoctorExperience, exp_id)
    if exp is None or exp.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Experience not found")
    return exp


@router.post("", response_model=ExperienceOut, status_code=status.HTTP_201_CREATED)
async def add_experience(
    body: ExperienceCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    if await db.get(Hospital, body.hospital_id) is None:
        raise HTTPException(status_code=422, detail="Unknown hospital_id")
    exp = DoctorExperience(doctor_id=doctor.id, **body.model_dump())
    db.add(exp)
    await db.commit()
    await db.refresh(exp)
    return ExperienceOut.model_validate(exp)


@router.patch("/{exp_id}", response_model=ExperienceOut)
async def update_experience(
    exp_id: uuid.UUID,
    body: ExperienceUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    exp = await _owned(db, doctor, exp_id)
    data = body.model_dump(exclude_unset=True)
    if "hospital_id" in data and await db.get(Hospital, data["hospital_id"]) is None:
        raise HTTPException(status_code=422, detail="Unknown hospital_id")
    for field, value in data.items():
        setattr(exp, field, value)
    await db.commit()
    await db.refresh(exp)
    return ExperienceOut.model_validate(exp)


@router.delete("/{exp_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_experience(
    exp_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    exp = await _owned(db, doctor, exp_id)
    await db.delete(exp)
    await db.commit()
