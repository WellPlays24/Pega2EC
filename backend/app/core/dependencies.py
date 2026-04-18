from collections.abc import Generator
from typing import Annotated

from fastapi import Depends

from app.core.config import Settings, get_settings
from app.services.registration import RegistrationRepository, RegistrationService
from app.services.supabase_admin import SupabaseAdminClient, SupabaseRegistrationRepository


def get_app_settings() -> Settings:
    return get_settings()


def get_supabase_admin_client(
    settings: Annotated[Settings, Depends(get_app_settings)],
) -> Generator[SupabaseAdminClient, None, None]:
    client = SupabaseAdminClient(settings=settings)
    try:
        yield client
    finally:
        client.close()


def get_registration_repository(
    client: SupabaseAdminClient,
) -> RegistrationRepository:
    return SupabaseRegistrationRepository(client=client)


def get_registration_service(
    repository: RegistrationRepository,
) -> RegistrationService:
    return RegistrationService(repository=repository)
