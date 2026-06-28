import uuid
from datetime import time

from sqlalchemy import ForeignKey, Integer, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class WorkingHour(Base):
    __tablename__ = "working_hours"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    experience_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctor_experiences.id", ondelete="CASCADE"), index=True
    )
    day_of_week: Mapped[int] = mapped_column(Integer)  # 0=Mon .. 6=Sun
    start_time: Mapped[time] = mapped_column(Time)
    end_time: Mapped[time] = mapped_column(Time)

    experience: Mapped["DoctorExperience"] = relationship(  # noqa: F821
        back_populates="working_hours"
    )
