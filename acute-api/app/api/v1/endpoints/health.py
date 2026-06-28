from fastapi import APIRouter

from app.core.config import settings

router = APIRouter()


@router.get("", summary="Health check")
async def health() -> dict:
    return {"status": "ok", "version": settings.VERSION}
