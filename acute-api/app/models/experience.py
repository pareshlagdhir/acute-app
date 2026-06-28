import uuid
from datetime import date

from sqlalchemy import Boolean, Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DoctorExperience(Base):
    __tablename__ = "doctor_experiences"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    doctor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctors.id", ondelete="CASCADE"), index=True
    )
    hospital_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("hospitals.id"), index=True)
    designation: Mapped[str | None] = mapped_column(String(120))
    start_date: Mapped[date | None] = mapped_column(Date)
    end_date: Mapped[date | None] = mapped_column(Date)
    is_current: Mapped[bool] = mapped_column(Boolean, default=False)

    doctor: Mapped["Doctor"] = relationship(back_populates="experiences")  # noqa: F821
    hospital: Mapped["Hospital"] = relationship(lazy="selectin")  # noqa: F821
    working_hours: Mapped[list["WorkingHour"]] = relationship(
        back_populates="experience", cascade="all, delete-orphan", lazy="selectin"
    )

    from app.models.working_hours import WorkingHour  # noqa: E402,F401
