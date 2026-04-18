from datetime import date, datetime
from uuid import UUID

from pydantic import Field, field_validator, model_validator

from app.schemas.common import ApiSchema


class RegistrationProfilePayload(ApiSchema):
    username: str = Field(min_length=3, max_length=30)
    birth_date: date
    bio: str | None = Field(default=None, max_length=500)
    province_code: str
    canton_code: str
    exact_lat: float | None = None
    exact_lng: float | None = None

    @field_validator("username")
    @classmethod
    def normalize_username(cls, value: str) -> str:
        return value.lower()


class RegistrationPreferencesPayload(ApiSchema):
    interested_in_genders: list[str] = Field(default_factory=list)
    relationship_intentions: list[str] = Field(default_factory=list)
    wants_children: bool | None = None
    min_preferred_age: int | None = None
    max_preferred_age: int | None = None
    preferred_province_codes: list[str] = Field(default_factory=list)
    preferred_canton_codes: list[str] = Field(default_factory=list)

    @model_validator(mode="after")
    def validate_age_range(self) -> "RegistrationPreferencesPayload":
        if self.min_preferred_age and self.min_preferred_age < 18:
            raise ValueError("min_preferred_age must be at least 18")
        if self.max_preferred_age and self.max_preferred_age < 18:
            raise ValueError("max_preferred_age must be at least 18")
        if (
            self.min_preferred_age is not None
            and self.max_preferred_age is not None
            and self.min_preferred_age > self.max_preferred_age
        ):
            raise ValueError("min_preferred_age cannot be greater than max_preferred_age")
        return self


class RegistrationPrivateDataPayload(ApiSchema):
    real_first_name: str
    real_middle_name: str | None = None
    real_last_name_father: str
    real_last_name_mother: str
    real_phone: str
    instagram_handle: str | None = None
    birth_date_exact: date
    sell_real_name: bool = False
    sell_phone: bool = False
    sell_instagram: bool = False
    sell_birth_date: bool = False


class RegistrationVerificationMediaPayload(ApiSchema):
    national_id_storage_path: str
    national_id_mime_type: str
    profile_photo_storage_path: str
    profile_photo_mime_type: str


class RegistrationCreateRequest(ApiSchema):
    phone: str
    email: str | None = None
    national_id: str = Field(min_length=10, max_length=10)
    profile: RegistrationProfilePayload
    preferences: RegistrationPreferencesPayload
    private_data: RegistrationPrivateDataPayload
    verification_media: RegistrationVerificationMediaPayload


class RegistrationCreateResponse(ApiSchema):
    app_user_id: UUID
    verification_request_id: UUID
    account_status: str
    message: str


class VerificationListItem(ApiSchema):
    verification_request_id: UUID
    app_user_id: UUID
    username: str
    phone: str
    national_id: str
    status: str
    created_at: datetime
    profile_photo_storage_path: str
    national_id_storage_path: str


class VerificationReviewRequest(ApiSchema):
    admin_user_id: UUID
    approved: bool
    review_notes: str = Field(min_length=5, max_length=1000)


class VerificationReviewResponse(ApiSchema):
    verification_request_id: UUID
    app_user_id: UUID
    verification_status: str
    account_status: str
    review_notes: str
