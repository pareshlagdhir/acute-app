import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.schemas.education import EducationCreate, EducationOut, EducationUpdate

router = APIRouter()


async def _owned(db: AsyncSession, doctor: Doctor, edu_id: uuid.UUID) -> DoctorEducation:
    edu = await db.get(DoctorEducation, edu_id)
    if edu is None or edu.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Education not found")
    return edu


@router.post("", response_model=EducationOut, status_code=status.HTTP_201_CREATED)
async def add_education(
    body: EducationCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = DoctorEducation(doctor_id=doctor.id, **body.model_dump())
    db.add(edu)
    await db.commit()
    await db.refresh(edu)
    return EducationOut.model_validate(edu)


@router.patch("/{edu_id}", response_model=EducationOut)
async def update_education(
    edu_id: uuid.UUID,
    body: EducationUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = await _owned(db, doctor, edu_id)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(edu, field, value)
    await db.commit()
    await db.refresh(edu)
    return EducationOut.model_validate(edu)


@router.delete("/{edu_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_education(
    edu_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    edu = await _owned(db, doctor, edu_id)
    await db.delete(edu)
    await db.commit()
