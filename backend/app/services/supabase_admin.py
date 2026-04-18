from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import UUID

import httpx

from app.core.config import Settings
from app.core.errors import ConflictError, IntegrationError, NotFoundError


class SupabaseAdminClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        if not settings.supabase_url or not settings.supabase_service_role_key:
            raise IntegrationError("Supabase credentials are not configured")

        headers = {
            "apikey": settings.supabase_service_role_key,
            "Authorization": f"Bearer {settings.supabase_service_role_key}",
            "Content-Type": "application/json",
            "Accept-Profile": settings.supabase_schema,
            "Content-Profile": settings.supabase_schema,
        }
        self._client = httpx.Client(
            base_url=f"{settings.supabase_url}/rest/v1",
            headers=headers,
            timeout=settings.supabase_timeout_seconds,
        )

    def close(self) -> None:
        self._client.close()

    def select(
        self,
        table: str,
        *,
        select: str = "*",
        filters: dict[str, str] | None = None,
        order: str | None = None,
        limit: int | None = None,
    ) -> list[dict[str, Any]]:
        params: dict[str, str] = {"select": select}
        if filters:
            params.update(filters)
        if order:
            params["order"] = order
        if limit is not None:
            params["limit"] = str(limit)
        response = self._client.get(f"/{table}", params=params)
        return self._handle_response(response)

    def insert(self, table: str, payload: dict[str, Any]) -> dict[str, Any]:
        response = self._client.post(
            f"/{table}",
            params={"select": "*"},
            headers={"Prefer": "return=representation"},
            json=payload,
        )
        rows = self._handle_response(response)
        if not rows:
            raise IntegrationError(f"Supabase insert returned no rows for {table}")
        return rows[0]

    def update(
        self,
        table: str,
        *,
        payload: dict[str, Any],
        filters: dict[str, str],
    ) -> list[dict[str, Any]]:
        response = self._client.patch(
            f"/{table}",
            params={"select": "*", **filters},
            headers={"Prefer": "return=representation"},
            json=payload,
        )
        return self._handle_response(response)

    def _handle_response(self, response: httpx.Response) -> list[dict[str, Any]]:
        if response.status_code in {200, 201}:
            data = response.json()
            if isinstance(data, list):
                return data
            return [data]

        if response.status_code == 409:
            raise ConflictError(response.text)

        raise IntegrationError(
            f"Supabase request failed with status {response.status_code}: {response.text}"
        )


class SupabaseRegistrationRepository:
    def __init__(self, client: SupabaseAdminClient) -> None:
        self._client = client

    def create_registration(self, payload: dict[str, Any]) -> dict[str, Any]:
        app_user = self._client.insert("app_users", payload["app_user"])
        app_user_id = app_user["id"]

        profile_photo_media = self._client.insert(
            "user_media",
            {**payload["profile_photo_media"], "app_user_id": app_user_id},
        )
        national_id_media = self._client.insert(
            "user_media",
            {**payload["national_id_media"], "app_user_id": app_user_id},
        )

        province_id = self._resolve_catalog_id("provinces", payload["profile"]["province_code"])
        canton_id = self._resolve_catalog_id("cantons", payload["profile"]["canton_code"])

        self._client.insert(
            "user_profiles",
            {
                "app_user_id": app_user_id,
                "username": payload["profile"]["username"],
                "birth_date": payload["profile"]["birth_date"],
                "bio": payload["profile"]["bio"],
                "province_id": province_id,
                "canton_id": canton_id,
                "exact_lat": payload["profile"]["exact_lat"],
                "exact_lng": payload["profile"]["exact_lng"],
                "profile_photo_media_id": profile_photo_media["id"],
            },
        )
        self._client.insert(
            "user_profile_preferences",
            {**payload["preferences"], "app_user_id": app_user_id},
        )
        self._client.insert(
            "user_private_data",
            {**payload["private_data"], "app_user_id": app_user_id},
        )
        self._client.insert("wallets", {"app_user_id": app_user_id})

        for offer in payload["private_data_offers"]:
            self._client.insert(
                "user_private_data_offers",
                {**offer, "app_user_id": app_user_id},
            )

        verification_request = self._client.insert(
            "user_verification_requests",
            {
                "app_user_id": app_user_id,
                "national_id_photo_media_id": national_id_media["id"],
                "profile_photo_media_id": profile_photo_media["id"],
            },
        )

        return {
            "app_user_id": app_user_id,
            "verification_request_id": verification_request["id"],
            "account_status": app_user["account_status"],
        }

    def _resolve_catalog_id(self, table: str, code: str) -> str:
        rows = self._client.select(table, filters={"code": f"eq.{code}"}, limit=1)
        if not rows:
            raise NotFoundError(f"Catalog code not found in {table}: {code}")
        return rows[0]["id"]

    def list_verification_requests(self, status: str | None, limit: int) -> list[dict[str, Any]]:
        filters: dict[str, str] = {}
        if status:
            filters["status"] = f"eq.{status}"

        rows = self._client.select(
            "user_verification_requests",
            select=(
                "id,app_user_id,status,created_at,"
                "app_users!inner(phone,national_id),"
                "user_profiles!inner(username),"
                "profile_photo:user_media!user_verification_requests_profile_photo_media_id_fkey(storage_path),"
                "national_id_photo:user_media!user_verification_requests_national_id_photo_media_id_fkey(storage_path)"
            ),
            filters=filters,
            order="created_at.desc",
            limit=limit,
        )
        return rows

    def review_verification_request(
        self,
        request_id: UUID,
        *,
        admin_user_id: UUID,
        approved: bool,
        review_notes: str,
    ) -> dict[str, Any]:
        existing_rows = self._client.select(
            "user_verification_requests",
            filters={"id": f"eq.{request_id}"},
            limit=1,
        )
        if not existing_rows:
            raise NotFoundError("Verification request not found")

        verification_request = existing_rows[0]
        app_user_id = verification_request["app_user_id"]
        timestamp = datetime.now(UTC).isoformat()
        verification_status = "approved" if approved else "rejected"
        account_status = "approved" if approved else "rejected"

        updated_verification = self._client.update(
            "user_verification_requests",
            payload={
                "status": verification_status,
                "review_notes": review_notes,
                "reviewed_by_admin_id": str(admin_user_id),
                "reviewed_at": timestamp,
            },
            filters={"id": f"eq.{request_id}"},
        )[0]

        user_payload: dict[str, Any] = {
            "account_status": account_status,
            "approved_at": timestamp if approved else None,
            "rejected_at": None if approved else timestamp,
            "rejected_reason": None if approved else review_notes,
        }
        self._client.update(
            "app_users",
            payload=user_payload,
            filters={"id": f"eq.{app_user_id}"},
        )

        self._client.insert(
            "admin_audit_logs",
            {
                "admin_user_id": str(admin_user_id),
                "action_type": "approve_verification" if approved else "reject_verification",
                "target_table": "user_verification_requests",
                "target_id": str(request_id),
                "details": {
                    "app_user_id": app_user_id,
                    "review_notes": review_notes,
                },
            },
        )

        return {
            "verification_request_id": updated_verification["id"],
            "app_user_id": UUID(app_user_id),
            "verification_status": verification_status,
            "account_status": account_status,
            "review_notes": review_notes,
        }
