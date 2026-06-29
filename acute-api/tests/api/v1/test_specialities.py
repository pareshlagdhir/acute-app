from httpx import AsyncClient


async def test_add_and_delete_speciality(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    created = await client.post(
        "/api/v1/doctors/me/specialities", json={"name": "Cardiology"}, headers=h
    )
    assert created.status_code == 201
    sid = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["speciality"] is True

    assert (await client.delete(f"/api/v1/doctors/me/specialities/{sid}", headers=h)).status_code == 204
