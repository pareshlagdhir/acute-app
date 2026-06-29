import uuid

from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DoctorEducation(Base):
    __tablename__ = "doctor_educations"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    doctor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("doctors.id", ondelete="CASCADE"), index=True
    )
    degree: Mapped[str] = mapped_column(String(100))
    registration_number: Mapped[str] = mapped_column(String(100))
    institution: Mapped[str | None] = mapped_column(String(255))
    year_of_completion: Mapped[int | None] = mapped_column(Integer)

    doctor: Mapped["Doctor"] = relationship(back_populates="educations")  # noqa: F821
