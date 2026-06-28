import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.models.speciality import DoctorSpeciality
from app.schemas.speciality import SpecialityCreate, SpecialityOut

router = APIRouter()


@router.post("", response_model=SpecialityOut, status_code=status.HTTP_201_CREATED)
async def add_speciality(
    body: SpecialityCreate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    row = DoctorSpeciality(doctor_id=doctor.id, name=body.name)
    db.add(row)
    await db.commit()
    await db.refresh(row)
    return SpecialityOut.model_validate(row)


@router.delete("/{spec_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_speciality(
    spec_id: uuid.UUID,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
):
    row = await db.get(DoctorSpeciality, spec_id)
    if row is None or row.doctor_id != doctor.id:
        raise HTTPException(status_code=404, detail="Speciality not found")
    await db.delete(row)
    await db.commit()
