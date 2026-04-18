from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.core.dependencies import (
    get_registration_repository,
    get_registration_service,
    get_supabase_admin_client,
)
from app.core.errors import ConflictError, IntegrationError, NotFoundError
from app.schemas.registration import (
    VerificationListItem,
    VerificationReviewRequest,
    VerificationReviewResponse,
)
from app.services.supabase_admin import SupabaseAdminClient

router = APIRouter()


@router.get("", response_model=list[VerificationListItem])
def list_verification_requests(
    client: Annotated[SupabaseAdminClient, Depends(get_supabase_admin_client)],
    status_filter: str | None = Query(default=None, alias="status"),
    limit: int = Query(default=20, ge=1, le=100),
) -> list[VerificationListItem]:
    service = get_registration_service(get_registration_repository(client))
    try:
        return service.list_verification_requests(status=status_filter, limit=limit)
    except IntegrationError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc)) from exc


@router.post("/{verification_request_id}/review", response_model=VerificationReviewResponse)
def review_verification_request(
    verification_request_id: UUID,
    request: VerificationReviewRequest,
    client: Annotated[SupabaseAdminClient, Depends(get_supabase_admin_client)],
) -> VerificationReviewResponse:
    service = get_registration_service(get_registration_repository(client))
    try:
        return service.review_verification_request(
            verification_request_id,
            admin_user_id=request.admin_user_id,
            approved=request.approved,
            review_notes=request.review_notes,
        )
    except NotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
    except ConflictError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    except IntegrationError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc)) from exc
