from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = Field(default="Pega2EC API", alias="APP_NAME")
    app_env: str = Field(default="development", alias="APP_ENV")
    api_prefix: str = Field(default="/api/v1", alias="API_PREFIX")
    debug: bool = Field(default=True, alias="DEBUG")
    frontend_origin: str = Field(default="http://localhost:3000", alias="FRONTEND_ORIGIN")

    supabase_url: str = Field(default="", alias="SUPABASE_URL")
    supabase_anon_key: str = Field(default="", alias="SUPABASE_ANON_KEY")
    supabase_service_role_key: str = Field(default="", alias="SUPABASE_SERVICE_ROLE_KEY")
    supabase_jwt_secret: str = Field(default="", alias="SUPABASE_JWT_SECRET")
    supabase_schema: str = Field(default="public", alias="SUPABASE_SCHEMA")
    supabase_timeout_seconds: float = Field(default=20.0, alias="SUPABASE_TIMEOUT_SECONDS")

    kushki_public_key: str = Field(default="", alias="KUSHKI_PUBLIC_KEY")
    kushki_private_key: str = Field(default="", alias="KUSHKI_PRIVATE_KEY")
    kushki_sandbox: bool = Field(default=True, alias="KUSHKI_SANDBOX")

    sms_provider: str = Field(default="stub", alias="SMS_PROVIDER")
    email_provider: str = Field(default="stub", alias="EMAIL_PROVIDER")

    verification_bucket: str = Field(default="verifications", alias="VERIFICATION_BUCKET")
    profile_media_bucket: str = Field(default="profiles", alias="PROFILE_MEDIA_BUCKET")


@lru_cache
def get_settings() -> Settings:
    return Settings()
