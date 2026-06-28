from fastapi import FastAPI

from app.api.v1.router import api_v1_router
from app.core.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.include_router(api_v1_router, prefix=settings.API_V1_STR)
