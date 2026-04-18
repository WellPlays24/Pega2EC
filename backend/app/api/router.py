from fastapi import APIRouter

from app.api.routes.admin_verifications import router as admin_verifications_router
from app.api.routes.health import router as health_router
from app.api.routes.meta import router as meta_router
from app.api.routes.registrations import router as registrations_router

api_router = APIRouter()
api_router.include_router(registrations_router, prefix="/registrations", tags=["registrations"])
api_router.include_router(
    admin_verifications_router,
    prefix="/admin/verifications",
    tags=["admin-verifications"],
)
api_router.include_router(health_router, prefix="/health", tags=["health"])
api_router.include_router(meta_router, prefix="/meta", tags=["meta"])
