from httpx import AsyncClient


async def test_get_me_returns_profile_with_completion(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor(first_name="Asha", last_name="Rao")
    resp = await client.get("/api/v1/doctors/me", headers=auth_headers(doctor))
    assert resp.status_code == 200
    body = resp.json()
    assert body["mobile"] == doctor.mobile
    assert body["profile_completion"] == 20  # personal complete only
    assert body["sections"]["personal"] is True
    assert body["educations"] == []
