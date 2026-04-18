from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.dependencies import (
    get_registration_repository,
    get_registration_service,
    get_supabase_admin_client,
)
from app.core.errors import ConflictError, IntegrationError
from app.schemas.registration import RegistrationCreateRequest, RegistrationCreateResponse
from app.services.supabase_admin import SupabaseAdminClient

router = APIRouter()


@router.post("", response_model=RegistrationCreateResponse, status_code=status.HTTP_201_CREATED)
def create_registration(
    request: RegistrationCreateRequest,
    client: Annotated[SupabaseAdminClient, Depends(get_supabase_admin_client)],
) -> RegistrationCreateResponse:
    service = get_registration_service(get_registration_repository(client))
    try:
        return service.create_registration(request)
    except ConflictError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    except IntegrationError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc)) from exc
