import uuid

from pydantic import BaseModel, ConfigDict


class SpecialityCreate(BaseModel):
    name: str


class SpecialityOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    name: str
