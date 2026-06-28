import uuid

from httpx import AsyncClient


async def _make_hospital(client, headers) -> str:
    resp = await client.post(
        "/api/v1/hospitals", json={"name": "City Hospital", "type": "hospital"}, headers=headers
    )
    return resp.json()["id"]


async def test_add_update_delete_experience(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    hospital_id = await _make_hospital(client, h)

    created = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": hospital_id, "designation": "Consultant", "is_current": True},
        headers=h,
    )
    assert created.status_code == 201
    assert created.json()["hospital"]["name"] == "City Hospital"
    exp_id = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["experience"] is True

    updated = await client.patch(
        f"/api/v1/doctors/me/experiences/{exp_id}",
        json={"designation": "Senior Consultant"},
        headers=h,
    )
    assert updated.json()["designation"] == "Senior Consultant"

    assert (await client.delete(f"/api/v1/doctors/me/experiences/{exp_id}", headers=h)).status_code == 204


async def test_experience_rejects_unknown_hospital(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    resp = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": str(uuid.uuid4())},
        headers=auth_headers(doctor),
    )
    assert resp.status_code == 422
