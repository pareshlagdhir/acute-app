from httpx import AsyncClient


async def test_add_list_update_delete_education(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor(first_name="A", last_name="B")
    h = auth_headers(doctor)

    created = await client.post(
        "/api/v1/doctors/me/educations",
        json={"degree": "MBBS", "registration_number": "REG-1"},
        headers=h,
    )
    assert created.status_code == 201
    edu_id = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["education"] is True
    assert me.json()["profile_completion"] == 40  # personal + education

    updated = await client.patch(
        f"/api/v1/doctors/me/educations/{edu_id}",
        json={"institution": "AIIMS"},
        headers=h,
    )
    assert updated.json()["institution"] == "AIIMS"

    deleted = await client.delete(f"/api/v1/doctors/me/educations/{edu_id}", headers=h)
    assert deleted.status_code == 204


async def test_cannot_touch_other_doctors_education(client: AsyncClient, make_doctor, auth_headers) -> None:
    owner = await make_doctor(mobile="911111111111")
    other = await make_doctor(mobile="912222222222")
    created = await client.post(
        "/api/v1/doctors/me/educations",
        json={"degree": "MD", "registration_number": "R2"},
        headers=auth_headers(owner),
    )
    edu_id = created.json()["id"]
    resp = await client.delete(
        f"/api/v1/doctors/me/educations/{edu_id}", headers=auth_headers(other)
    )
    assert resp.status_code == 404
