from httpx import AsyncClient


async def test_degrees_seeded_and_searchable(client: AsyncClient) -> None:
    # conftest creates fresh tables but does NOT run the Alembic seed; insert one.
    from app.models.catalog import DegreeCatalog
    from app.db.session import get_db
    from app.main import app

    gen = app.dependency_overrides[get_db]()
    session = await gen.__anext__()
    session.add(DegreeCatalog(name="MBBS"))
    session.add(DegreeCatalog(name="MD"))
    await session.commit()

    resp = await client.get("/api/v1/catalog/degrees", params={"q": "mb"})
    assert resp.status_code == 200
    names = [r["name"] for r in resp.json()]
    assert names == ["MBBS"]
