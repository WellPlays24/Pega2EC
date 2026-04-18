from fastapi import APIRouter

from app.core.config import get_settings
from app.schemas.meta import AppMetaResponse

router = APIRouter()


@router.get("/app", response_model=AppMetaResponse)
def get_app_meta() -> AppMetaResponse:
    settings = get_settings()
    return AppMetaResponse(
        app_name=settings.app_name,
        environment=settings.app_env,
        api_prefix=settings.api_prefix,
        sms_provider=settings.sms_provider,
        email_provider=settings.email_provider,
        kushki_sandbox=settings.kushki_sandbox,
    )
