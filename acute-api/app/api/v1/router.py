from fastapi import APIRouter

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.doctors import router as doctors_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.otp import router as otp_router

api_v1_router = APIRouter()

api_v1_router.include_router(health_router, prefix="/health", tags=["health"])
api_v1_router.include_router(otp_router, prefix="/otp", tags=["otp"])
api_v1_router.include_router(doctors_router, prefix="/doctors", tags=["doctors"])
api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])
