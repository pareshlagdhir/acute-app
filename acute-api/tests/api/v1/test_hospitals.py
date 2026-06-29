from httpx import AsyncClient


async def test_create_then_search_hospital(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    created = await client.post(
        "/api/v1/hospitals",
        json={"name": "Apollo Clinic", "type": "clinic", "city": "Pune"},
        headers=h,
    )
    assert created.status_code == 201
    found = await client.get("/api/v1/hospitals", params={"q": "apollo"}, headers=h)
    assert found.status_code == 200
    assert found.json()[0]["name"] == "Apollo Clinic"


async def test_hospitals_require_auth(client: AsyncClient) -> None:
    assert (await client.get("/api/v1/hospitals")).status_code == 401
