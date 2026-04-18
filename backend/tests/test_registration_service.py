from datetime import date, datetime
from uuid import uuid4

from app.schemas.registration import RegistrationCreateRequest
from app.services.registration import RegistrationService


class FakeRegistrationRepository:
    def __init__(self) -> None:
        self.created_payload: dict | None = None

    def create_registration(self, payload: dict) -> dict:
        self.created_payload = payload
        return {
            "app_user_id": uuid4(),
            "verification_request_id": uuid4(),
            "account_status": "pending_review",
        }

    def list_verification_requests(self, status: str | None, limit: int) -> list[dict]:
        return [
            {
                "id": uuid4(),
                "app_user_id": uuid4(),
                "status": status or "pending",
                "created_at": datetime(2026, 4, 18, 12, 0, 0),
                "user_profiles": {"username": "mary2345"},
                "app_users": {"phone": "0991234567", "national_id": "1234567890"},
                "profile_photo": {"storage_path": "profiles/mary/profile.jpg"},
                "national_id_photo": {"storage_path": "verifications/mary/id.jpg"},
            }
        ]

    def review_verification_request(
        self,
        request_id,
        *,
        admin_user_id,
        approved,
        review_notes,
    ) -> dict:
        return {
            "verification_request_id": request_id,
            "app_user_id": uuid4(),
            "verification_status": "approved" if approved else "rejected",
            "account_status": "approved" if approved else "rejected",
            "review_notes": review_notes,
        }


def build_request() -> RegistrationCreateRequest:
    return RegistrationCreateRequest.model_validate(
        {
            "phone": "0991234567",
            "email": "mary@example.com",
            "national_id": "1234567890",
            "profile": {
                "username": "Mary2345",
                "birth_date": date(1998, 1, 10),
                "bio": "Perfil validado de prueba",
                "province_code": "ec-p",
                "canton_code": "ec-p-006",
                "exact_lat": -0.180653,
                "exact_lng": -78.467834,
            },
            "preferences": {
                "interested_in_genders": ["male"],
                "relationship_intentions": ["serious"],
                "min_preferred_age": 25,
                "max_preferred_age": 40,
            },
            "private_data": {
                "real_first_name": "Maria",
                "real_last_name_father": "Perez",
                "real_last_name_mother": "Lopez",
                "real_phone": "0991234567",
                "birth_date_exact": date(1998, 1, 10),
                "sell_real_name": True,
                "sell_phone": True,
            },
            "verification_media": {
                "national_id_storage_path": "verifications/maria/id-front.jpg",
                "national_id_mime_type": "image/jpeg",
                "profile_photo_storage_path": "profiles/maria/main.jpg",
                "profile_photo_mime_type": "image/jpeg",
            },
        }
    )


def test_create_registration_builds_expected_payload() -> None:
    repository = FakeRegistrationRepository()
    service = RegistrationService(repository=repository)

    response = service.create_registration(build_request())

    assert response.account_status == "pending_review"
    assert repository.created_payload is not None
    assert repository.created_payload["app_user"]["phone"] == "0991234567"
    assert repository.created_payload["profile"]["username"] == "mary2345"
    assert len(repository.created_payload["private_data_offers"]) == 4


def test_list_verification_requests_maps_response() -> None:
    service = RegistrationService(repository=FakeRegistrationRepository())

    rows = service.list_verification_requests(status="pending", limit=10)

    assert len(rows) == 1
    assert rows[0].username == "mary2345"
    assert rows[0].status == "pending"
