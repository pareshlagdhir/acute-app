from app.models.doctor import Doctor

SECTION_WEIGHT = 20


def compute_completion(doctor: Doctor) -> tuple[int, dict[str, bool]]:
    has_working_hours = any(
        len(exp.working_hours) > 0 for exp in doctor.experiences
    )
    sections = {
        "personal": bool(doctor.first_name and doctor.last_name),
        "education": len(doctor.educations) > 0,
        "speciality": len(doctor.specialities) > 0,
        "experience": len(doctor.experiences) > 0,
        "working_hours": has_working_hours,
    }
    pct = sum(SECTION_WEIGHT for done in sections.values() if done)
    return pct, sections
