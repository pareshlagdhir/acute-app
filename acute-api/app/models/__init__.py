from app.models.catalog import DegreeCatalog, SpecialityCatalog
from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.models.experience import DoctorExperience
from app.models.hospital import Hospital
from app.models.speciality import DoctorSpeciality
from app.models.working_hours import WorkingHour

__all__ = [
    "DegreeCatalog",
    "SpecialityCatalog",
    "Doctor",
    "DoctorEducation",
    "DoctorExperience",
    "Hospital",
    "DoctorSpeciality",
    "WorkingHour",
]
