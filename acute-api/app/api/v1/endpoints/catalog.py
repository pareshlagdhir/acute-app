from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.catalog import DegreeCatalog, SpecialityCatalog
from app.schemas.catalog import CatalogItem

router = APIRouter()


async def _search(db: AsyncSession, model, q: str | None) -> list[CatalogItem]:
    stmt = select(model).order_by(model.name).limit(50)
    if q:
        stmt = stmt.where(model.name.ilike(f"{q}%"))
    rows = (await db.execute(stmt)).scalars().all()
    return [CatalogItem.model_validate(r) for r in rows]


@router.get("/degrees", response_model=list[CatalogItem], summary="Search degree catalog")
async def degrees(q: str | None = None, db: AsyncSession = Depends(get_db)):
    return await _search(db, DegreeCatalog, q)


@router.get("/specialities", response_model=list[CatalogItem], summary="Search speciality catalog")
async def specialities(q: str | None = None, db: AsyncSession = Depends(get_db)):
    return await _search(db, SpecialityCatalog, q)
