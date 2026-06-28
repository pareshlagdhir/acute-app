import datetime as dt

from app.models.doctor import Doctor
from app.models.education import DoctorEducation
from app.models.experience import DoctorExperience
from app.models.speciality import DoctorSpeciality
from app.models.working_hours import WorkingHour
from app.services.profile import compute_completion


def test_empty_profile_is_zero() -> None:
    pct, sections = compute_completion(Doctor(mobile="91x"))
    assert pct == 0
    assert sections == {
        "personal": False, "education": False, "speciality": False,
        "experience": False, "working_hours": False,
    }


def test_each_section_adds_twenty() -> None:
    d = Doctor(mobile="91x", first_name="A", last_name="B")
    d.educations = [DoctorEducation(degree="MBBS", registration_number="R1")]
    d.specialities = [DoctorSpeciality(name="Cardiology")]
    exp = DoctorExperience(hospital_id=None)
    exp.working_hours = [WorkingHour(day_of_week=0, start_time=dt.time(9), end_time=dt.time(17))]
    d.experiences = [exp]
    pct, sections = compute_completion(d)
    assert pct == 100
    assert all(sections.values())
