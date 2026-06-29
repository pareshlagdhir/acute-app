import uuid

from pydantic import BaseModel, ConfigDict


class EducationCreate(BaseModel):
    degree: str
    registration_number: str
    institution: str | None = None
    year_of_completion: int | None = None


class EducationUpdate(BaseModel):
    degree: str | None = None
    registration_number: str | None = None
    institution: str | None = None
    year_of_completion: int | None = None


class EducationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    degree: str
    registration_number: str
    institution: str | None
    year_of_completion: int | None
