from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol
from uuid import UUID

from app.core.errors import ConflictError
from app.schemas.registration import (
    RegistrationCreateRequest,
    RegistrationCreateResponse,
    VerificationListItem,
    VerificationReviewResponse,
)


class RegistrationRepository(Protocol):
    def create_registration(self, payload: dict) -> dict: ...

    def list_verification_requests(self, status: str | None, limit: int) -> list[dict]: ...

    def review_verification_request(
        self,
        request_id: UUID,
        *,
        admin_user_id: UUID,
        approved: bool,
        review_notes: str,
    ) -> dict: ...


@dataclass(slots=True)
class RegistrationService:
    repository: RegistrationRepository

    def create_registration(self, request: RegistrationCreateRequest) -> RegistrationCreateResponse:
        if request.profile.birth_date != request.private_data.birth_date_exact:
            raise ConflictError("birth_date and birth_date_exact must match during registration")

        payload = {
            "profile_photo_media": {
                "app_user_id": None,
                "media_type": "profile_photo",
                "bucket_name": "profiles",
                "storage_path": request.verification_media.profile_photo_storage_path,
                "mime_type": request.verification_media.profile_photo_mime_type,
                "review_status": "pending",
            },
            "national_id_media": {
                "app_user_id": None,
                "media_type": "national_id_photo",
                "bucket_name": "verifications",
                "storage_path": request.verification_media.national_id_storage_path,
                "mime_type": request.verification_media.national_id_mime_type,
                "review_status": "pending",
            },
            "app_user": {
                "phone": request.phone,
                "email": request.email,
                "national_id": request.national_id,
                "account_status": "pending_review",
            },
            "profile": {
                "username": request.profile.username,
                "birth_date": request.profile.birth_date.isoformat(),
                "bio": request.profile.bio,
                "province_id": self._code_reference(request.profile.province_code),
                "canton_id": self._code_reference(request.profile.canton_code),
                "exact_lat": request.profile.exact_lat,
                "exact_lng": request.profile.exact_lng,
            },
            "preferences": {
                "interested_in_genders": request.preferences.interested_in_genders,
                "relationship_intentions": request.preferences.relationship_intentions,
                "wants_children": request.preferences.wants_children,
                "min_preferred_age": request.preferences.min_preferred_age,
                "max_preferred_age": request.preferences.max_preferred_age,
                "preferred_province_ids": request.preferences.preferred_province_codes,
                "preferred_canton_ids": request.preferences.preferred_canton_codes,
            },
            "private_data": {
                "real_first_name": request.private_data.real_first_name,
                "real_middle_name": request.private_data.real_middle_name,
                "real_last_name_father": request.private_data.real_last_name_father,
                "real_last_name_mother": request.private_data.real_last_name_mother,
                "real_phone": request.private_data.real_phone,
                "instagram_handle": request.private_data.instagram_handle,
                "birth_date_exact": request.private_data.birth_date_exact.isoformat(),
            },
            "private_data_offers": [
                self._build_offer("real_name", request.private_data.sell_real_name),
                self._build_offer("phone", request.private_data.sell_phone),
                self._build_offer("instagram", request.private_data.sell_instagram),
                self._build_offer("birth_date", request.private_data.sell_birth_date),
            ],
        }
        result = self.repository.create_registration(payload)
        return RegistrationCreateResponse(
            app_user_id=result["app_user_id"],
            verification_request_id=result["verification_request_id"],
            account_status=result["account_status"],
            message="Registro recibido. Tu cuenta quedara pendiente de revision manual.",
        )

    def list_verification_requests(
        self,
        status: str | None,
        limit: int,
    ) -> list[VerificationListItem]:
        rows = self.repository.list_verification_requests(status=status, limit=limit)
        return [
            VerificationListItem(
                verification_request_id=row["id"],
                app_user_id=row["app_user_id"],
                username=row["user_profiles"]["username"],
                phone=row["app_users"]["phone"],
                national_id=row["app_users"]["national_id"],
                status=row["status"],
                created_at=row["created_at"],
                profile_photo_storage_path=row["profile_photo"]["storage_path"],
                national_id_storage_path=row["national_id_photo"]["storage_path"],
            )
            for row in rows
        ]

    def review_verification_request(
        self,
        request_id: UUID,
        *,
        admin_user_id: UUID,
        approved: bool,
        review_notes: str,
    ) -> VerificationReviewResponse:
        result = self.repository.review_verification_request(
            request_id,
            admin_user_id=admin_user_id,
            approved=approved,
            review_notes=review_notes,
        )
        return VerificationReviewResponse(**result)

    @staticmethod
    def _build_offer(data_type: str, enabled: bool) -> dict:
        default_prices = {
            "real_name": 5,
            "phone": 20,
            "instagram": 5,
            "birth_date": 5,
        }
        return {
            "data_type": data_type,
            "is_enabled": enabled,
            "price_points_snapshot": default_prices[data_type],
            "duration_hours": 24,
        }

    @staticmethod
    def _code_reference(code: str) -> str:
        # PostgREST accepts FK references directly, but the real lookup by code will be resolved
        # in the repository/backend layer in the next iteration.
        return code
