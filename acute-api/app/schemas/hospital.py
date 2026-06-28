import uuid
from typing import Literal

from pydantic import BaseModel, ConfigDict


class HospitalCreate(BaseModel):
    name: str
    type: Literal["hospital", "clinic"] = "hospital"
    city: str | None = None
    address: str | None = None


class HospitalOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
    type: str
    city: str | None
    address: str | None
