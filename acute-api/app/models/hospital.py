import uuid

from sqlalchemy import String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Hospital(Base):
    __tablename__ = "hospitals"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(255), index=True)
    type: Mapped[str] = mapped_column(String(20), default="hospital")  # hospital | clinic
    city: Mapped[str | None] = mapped_column(String(120))
    address: Mapped[str | None] = mapped_column(String(500))
    created_by: Mapped[uuid.UUID | None] = mapped_column(Uuid(), default=None)
