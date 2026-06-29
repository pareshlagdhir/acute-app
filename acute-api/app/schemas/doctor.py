import uuid

from pydantic import BaseModel, ConfigDict, EmailStr

from app.schemas.education import EducationOut
from app.schemas.experience import ExperienceOut
from app.schemas.speciality import SpecialityOut


class DoctorUpdate(BaseModel):
    first_name: str | None = None
    middle_name: str | None = None
    last_name: str | None = None
    email: EmailStr | None = None


class DoctorMeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    mobile: str
    first_name: str | None
    middle_name: str | None
    last_name: str | None
    email: str | None
    educations: list[EducationOut]
    specialities: list[SpecialityOut]
    experiences: list[ExperienceOut]
    profile_completion: int
    sections: dict[str, bool]
