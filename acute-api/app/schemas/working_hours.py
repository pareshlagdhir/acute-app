import datetime as dt
import uuid

from pydantic import BaseModel, ConfigDict, model_validator


class WorkingHourBase(BaseModel):
    day_of_week: int  # 0=Mon .. 6=Sun
    start_time: dt.time
    end_time: dt.time

    @model_validator(mode="after")
    def _check(self) -> "WorkingHourBase":
        if not 0 <= self.day_of_week <= 6:
            raise ValueError("day_of_week must be 0..6")
        if self.end_time <= self.start_time:
            raise ValueError("end_time must be after start_time")
        return self


class WorkingHourCreate(WorkingHourBase):
    pass


class WorkingHourOut(WorkingHourBase):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
