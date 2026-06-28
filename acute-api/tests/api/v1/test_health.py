import pytest
from httpx import AsyncClient


async def test_health_returns_200(client: AsyncClient) -> None:
    response = await client.get("/api/v1/health")
    assert response.status_code == 200


async def test_health_content_type_is_json(client: AsyncClient) -> None:
    response = await client.get("/api/v1/health")
    assert "application/json" in response.headers["content-type"]


async def test_health_status_field_is_ok(client: AsyncClient) -> None:
    response = await client.get("/api/v1/health")
    assert response.json()["status"] == "ok"


async def test_health_response_schema(client: AsyncClient) -> None:
    data = (await client.get("/api/v1/health")).json()
    assert "status" in data
    assert "version" in data
