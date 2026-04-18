from pydantic import BaseModel


class AppMetaResponse(BaseModel):
    app_name: str
    environment: str
    api_prefix: str
    sms_provider: str
    email_provider: str
    kushki_sandbox: bool
