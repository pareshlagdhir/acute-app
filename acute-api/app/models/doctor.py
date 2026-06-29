import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Doctor(Base):
    __tablename__ = "doctors"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    mobile: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    first_name: Mapped[str | None] = mapped_column(String(100))
    middle_name: Mapped[str | None] = mapped_column(String(100))
    last_name: Mapped[str | None] = mapped_column(String(100))
    email: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    educations: Mapped[list["DoctorEducation"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )
    specialities: Mapped[list["DoctorSpeciality"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )
    experiences: Mapped[list["DoctorExperience"]] = relationship(
        back_populates="doctor", cascade="all, delete-orphan", lazy="selectin"
    )

    from app.models.education import DoctorEducation  # noqa: E402,F401
    from app.models.experience import DoctorExperience  # noqa: E402,F401
    from app.models.speciality import DoctorSpeciality  # noqa: E402,F401
