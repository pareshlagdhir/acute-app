import datetime as dt
import uuid

from pydantic import BaseModel, ConfigDict

from app.schemas.working_hours import WorkingHourOut


class HospitalRef(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    type: str
    city: str | None


class ExperienceCreate(BaseModel):
    hospital_id: uuid.UUID
    designation: str | None = None
    start_date: dt.date | None = None
    end_date: dt.date | None = None
    is_current: bool = False


class ExperienceUpdate(BaseModel):
    hospital_id: uuid.UUID | None = None
    designation: str | None = None
    start_date: dt.date | None = None
    end_date: dt.date | None = None
    is_current: bool | None = None


class ExperienceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    designation: str | None
    start_date: dt.date | None
    end_date: dt.date | None
    is_current: bool
    hospital: HospitalRef
    working_hours: list[WorkingHourOut]
