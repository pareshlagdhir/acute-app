from fastapi import APIRouter

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.catalog import router as catalog_router
from app.api.v1.endpoints.doctors import router as doctors_router
from app.api.v1.endpoints.educations import router as educations_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.hospitals import router as hospitals_router
from app.api.v1.endpoints.otp import router as otp_router
from app.api.v1.endpoints.experiences import router as experiences_router
from app.api.v1.endpoints.specialities import router as specialities_router
from app.api.v1.endpoints.working_hours import router as working_hours_router

api_v1_router = APIRouter()

api_v1_router.include_router(health_router, prefix="/health", tags=["health"])
api_v1_router.include_router(otp_router, prefix="/otp", tags=["otp"])
api_v1_router.include_router(doctors_router, prefix="/doctors", tags=["doctors"])
api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_v1_router.include_router(catalog_router, prefix="/catalog", tags=["catalog"])
api_v1_router.include_router(hospitals_router, prefix="/hospitals", tags=["hospitals"])
api_v1_router.include_router(
    educations_router, prefix="/doctors/me/educations", tags=["educations"]
)
api_v1_router.include_router(
    specialities_router, prefix="/doctors/me/specialities", tags=["specialities"]
)
api_v1_router.include_router(
    experiences_router, prefix="/doctors/me/experiences", tags=["experiences"]
)
api_v1_router.include_router(
    working_hours_router,
    prefix="/doctors/me/experiences/{exp_id}/working-hours",
    tags=["working-hours"],
)
