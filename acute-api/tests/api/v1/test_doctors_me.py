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


async def test_patch_me_updates_personal_info(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)

    resp = await client.patch(
        "/api/v1/doctors/me",
        json={"first_name": "Priya", "last_name": "Sharma", "email": "priya.sharma@example.com"},
        headers=h,
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["first_name"] == "Priya"
    assert body["last_name"] == "Sharma"
    assert body["email"] == "priya.sharma@example.com"
    assert body["sections"]["personal"] is True
    assert body["profile_completion"] == 20
