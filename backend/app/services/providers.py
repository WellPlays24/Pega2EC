from dataclasses import dataclass

from app.core.config import Settings


@dataclass(frozen=True)
class ProviderStatus:
    sms_provider: str
    email_provider: str
    payments_mode: str


def describe_providers(settings: Settings) -> ProviderStatus:
    payments_mode = "sandbox" if settings.kushki_sandbox else "live"
    return ProviderStatus(
        sms_provider=settings.sms_provider,
        email_provider=settings.email_provider,
        payments_mode=payments_mode,
    )
