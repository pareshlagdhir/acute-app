from httpx import AsyncClient


async def _experience(client, headers) -> str:
    hosp = await client.post(
        "/api/v1/hospitals", json={"name": "Care Clinic", "type": "clinic"}, headers=headers
    )
    exp = await client.post(
        "/api/v1/doctors/me/experiences",
        json={"hospital_id": hosp.json()["id"]},
        headers=headers,
    )
    return exp.json()["id"]


async def test_add_list_delete_working_hours(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    exp_id = await _experience(client, h)

    created = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours",
        json={"day_of_week": 0, "start_time": "09:00:00", "end_time": "13:00:00"},
        headers=h,
    )
    assert created.status_code == 201
    wid = created.json()["id"]

    me = await client.get("/api/v1/doctors/me", headers=h)
    assert me.json()["sections"]["working_hours"] is True
    assert me.json()["profile_completion"] == 40  # experience + working_hours

    listed = await client.get(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours", headers=h
    )
    assert len(listed.json()) == 1

    assert (
        await client.delete(
            f"/api/v1/doctors/me/experiences/{exp_id}/working-hours/{wid}", headers=h
        )
    ).status_code == 204


async def test_rejects_end_before_start(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    exp_id = await _experience(client, h)
    resp = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours",
        json={"day_of_week": 0, "start_time": "17:00:00", "end_time": "09:00:00"},
        headers=h,
    )
    assert resp.status_code == 422


async def test_day_of_week_out_of_range(client: AsyncClient, make_doctor, auth_headers) -> None:
    doctor = await make_doctor()
    h = auth_headers(doctor)
    exp_id = await _experience(client, h)
    resp = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_id}/working-hours",
        json={"day_of_week": 7, "start_time": "09:00:00", "end_time": "13:00:00"},
        headers=h,
    )
    assert resp.status_code == 422


async def test_cross_doctor_working_hours_404(client: AsyncClient, make_doctor, auth_headers) -> None:
    # Create doctor A and their experience + working-hour
    doctor_a = await make_doctor(mobile="911111111111")
    h_a = auth_headers(doctor_a)
    exp_a_id = await _experience(client, h_a)

    created_wh = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_a_id}/working-hours",
        json={"day_of_week": 0, "start_time": "09:00:00", "end_time": "13:00:00"},
        headers=h_a,
    )
    assert created_wh.status_code == 201
    wh_a_id = created_wh.json()["id"]

    # Create doctor B
    doctor_b = await make_doctor(mobile="912222222222")
    h_b = auth_headers(doctor_b)

    # Doctor B tries to GET working-hours list
    get_resp = await client.get(
        f"/api/v1/doctors/me/experiences/{exp_a_id}/working-hours",
        headers=h_b,
    )
    assert get_resp.status_code == 404

    # Doctor B tries to POST to doctor A's experience
    post_resp = await client.post(
        f"/api/v1/doctors/me/experiences/{exp_a_id}/working-hours",
        json={"day_of_week": 1, "start_time": "09:00:00", "end_time": "13:00:00"},
        headers=h_b,
    )
    assert post_resp.status_code == 404

    # Doctor B tries to DELETE doctor A's working-hour
    delete_resp = await client.delete(
        f"/api/v1/doctors/me/experiences/{exp_a_id}/working-hours/{wh_a_id}",
        headers=h_b,
    )
    assert delete_resp.status_code == 404
