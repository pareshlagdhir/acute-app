from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_doctor
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.doctor import DoctorMeResponse, DoctorUpdate
from app.services.profile import compute_completion

router = APIRouter()


def _serialize(doctor: Doctor) -> DoctorMeResponse:
    pct, sections = compute_completion(doctor)
    return DoctorMeResponse.model_validate(
        {
            "id": doctor.id,
            "mobile": doctor.mobile,
            "first_name": doctor.first_name,
            "middle_name": doctor.middle_name,
            "last_name": doctor.last_name,
            "email": doctor.email,
            "educations": doctor.educations,
            "specialities": doctor.specialities,
            "experiences": doctor.experiences,
            "profile_completion": pct,
            "sections": sections,
        }
    )


@router.get("/me", response_model=DoctorMeResponse, summary="Current doctor profile + completion")
async def get_me(doctor: Doctor = Depends(get_current_doctor)) -> DoctorMeResponse:
    return _serialize(doctor)


@router.patch("/me", response_model=DoctorMeResponse, summary="Update personal information")
async def update_me(
    body: DoctorUpdate,
    doctor: Doctor = Depends(get_current_doctor),
    db: AsyncSession = Depends(get_db),
) -> DoctorMeResponse:
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(doctor, field, value)
    await db.commit()
    await db.refresh(doctor)
    return _serialize(doctor)
