# Data Model MVP

## Objetivo

Definir el modelo relacional inicial del MVP de `Pega2EC` para convertirlo luego en migraciones SQL sobre `Supabase Postgres`.

## Principios

1. separar datos publicos, privados y de auditoria
2. registrar toda operacion de puntos y desbloqueos como transaccion
3. evitar borrar historiales criticos
4. usar estados y trazabilidad en validacion, compras, chats y moderacion
5. mantener precios y reglas de negocio parametrizables

## Convenciones

- PK: `id uuid primary key`
- fechas: `timestamptz`
- referencias a usuarios de negocio: `app_user_id uuid`
- referencias a `auth.users`: `auth_user_id uuid`
- campos monetarios en puntos: `integer`
- coordenadas: `numeric(9,6)`
- configuraciones flexibles: `jsonb`

## Enums Recomendados

### `user_role`

- `member`
- `support`
- `moderator`
- `superadmin`

### `account_status`

- `pending_review`
- `approved`
- `rejected`
- `suspended`
- `banned_permanent`

### `verification_status`

- `pending`
- `approved`
- `rejected`

### `media_type`

- `profile_photo`
- `gallery_photo`
- `national_id_photo`
- `report_evidence`
- `chat_image`

### `media_review_status`

- `pending`
- `approved`
- `rejected`

### `private_data_type`

- `real_name`
- `phone`
- `instagram`
- `birth_date`

### `purchase_status`

- `pending`
- `paid`
- `expired`
- `cancelled`
- `refunded`

### `wallet_type`

- `spendable`
- `earned`

### `wallet_transaction_type`

- `points_purchase`
- `private_data_unlock_purchase`
- `private_data_unlock_income`
- `chat_open_purchase`
- `chat_open_income`
- `chat_image_purchase`
- `chat_image_income`
- `promotion_bonus`
- `event_create_purchase`
- `event_join_purchase`
- `event_income`
- `withdrawal_request`
- `withdrawal_completed`
- `withdrawal_rejected`
- `paid_unban_purchase`
- `admin_adjustment`
- `refund`

### `wallet_transaction_direction`

- `credit`
- `debit`

### `chat_status`

- `active`
- `expired`
- `closed_by_sanction`

### `chat_message_type`

- `text`
- `image`
- `system`

### `report_reason_type`

- `harassment`
- `threats`
- `impersonation`
- `non_consensual_content`
- `fraud`
- `insults`
- `event_misconduct`
- `other`

### `report_status`

- `open`
- `in_review`
- `resolved`
- `dismissed`

### `sanction_type`

- `warning`
- `temporary_ban`
- `permanent_ban`
- `paid_unban`

### `withdrawal_status`

- `requested`
- `processing`
- `completed`
- `rejected`

## Tablas MVP

### 1. `app_users`

Identidad principal del negocio.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| auth_user_id | uuid | unique, referencia logica a `auth.users.id` |
| role | user_role | default `member` |
| account_status | account_status | estado general de la cuenta |
| phone | varchar(20) | unique, obligatorio, formato Ecuador |
| email | varchar(255) | nullable |
| national_id | varchar(20) | unique, obligatorio |
| is_phone_verified | boolean | default false |
| is_email_verified | boolean | default false |
| last_login_at | timestamptz | nullable |
| approved_at | timestamptz | nullable |
| rejected_at | timestamptz | nullable |
| rejected_reason | text | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Indices y restricciones:

- unique(`auth_user_id`)
- unique(`phone`)
- unique(`national_id`)
- index(`account_status`)
- index(`role`)

### 2. `user_profiles`

Perfil publico visible a usuarios autenticados.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | unique, FK -> `app_users.id` |
| username | varchar(30) | unique, editable |
| birth_date | date | usada para edad visible |
| bio | varchar(500) | descripcion libre |
| province_id | uuid | FK -> `provinces.id` |
| canton_id | uuid | FK -> `cantons.id` |
| exact_lat | numeric(9,6) | privada |
| exact_lng | numeric(9,6) | privada |
| is_hidden | boolean | default false |
| profile_photo_media_id | uuid | nullable, FK -> `user_media.id` |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Indices y restricciones:

- unique(`app_user_id`)
- unique(`username`)
- index(`province_id`)
- index(`canton_id`)
- index(`is_hidden`)

### 3. `user_profile_preferences`

Preferencias y criterios de pareja del formulario.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | unique, FK -> `app_users.id` |
| interested_in_genders | jsonb | lista seleccionable |
| relationship_intentions | jsonb | serio, casual, amistad, etc |
| wants_children | boolean | nullable |
| min_preferred_age | integer | nullable |
| max_preferred_age | integer | nullable |
| preferred_province_ids | jsonb | nullable |
| preferred_canton_ids | jsonb | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Nota: este bloque puede normalizarse despues si necesitas filtros muy avanzados. Para MVP, `jsonb` reduce complejidad.

### 4. `user_private_data`

Datos privados y sensibles nunca expuestos directamente en tablas publicas.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | unique, FK -> `app_users.id` |
| real_first_name | varchar(100) | obligatorio |
| real_middle_name | varchar(100) | nullable |
| real_last_name_father | varchar(100) | obligatorio |
| real_last_name_mother | varchar(100) | obligatorio |
| real_phone | varchar(20) | obligatorio |
| instagram_handle | varchar(100) | nullable |
| birth_date_exact | date | obligatorio |
| bank_name | varchar(120) | nullable |
| bank_account_type | varchar(50) | nullable |
| bank_account_number | varchar(60) | nullable |
| bank_account_holder_name | varchar(200) | nullable |
| bank_account_holder_national_id | varchar(20) | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

### 5. `user_private_data_offers`

Define si cada dato privado esta a la venta y bajo que precio.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | FK -> `app_users.id` |
| data_type | private_data_type | tipo de dato vendido |
| is_enabled | boolean | default false |
| price_points_snapshot | integer | precio actual parametrizado |
| duration_hours | integer | default 24 |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Indices y restricciones:

- unique(`app_user_id`, `data_type`)
- index(`is_enabled`)

### 6. `user_media`

Repositorio de referencias a archivos en Supabase Storage.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | FK -> `app_users.id` |
| media_type | media_type | |
| bucket_name | varchar(100) | nombre de bucket |
| storage_path | text | ruta del archivo |
| mime_type | varchar(120) | |
| file_size_bytes | bigint | nullable |
| review_status | media_review_status | default `pending` |
| reviewed_by_admin_id | uuid | nullable, FK -> `app_users.id` |
| reviewed_at | timestamptz | nullable |
| rejection_reason | text | nullable |
| created_at | timestamptz | default now() |

Indices:

- index(`app_user_id`, `media_type`)
- index(`review_status`)

### 7. `user_verification_requests`

Solicitud de verificacion manual de identidad.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | FK -> `app_users.id` |
| national_id_photo_media_id | uuid | FK -> `user_media.id` |
| profile_photo_media_id | uuid | FK -> `user_media.id` |
| status | verification_status | default `pending` |
| review_notes | text | nullable |
| reviewed_by_admin_id | uuid | nullable, FK -> `app_users.id` |
| reviewed_at | timestamptz | nullable |
| created_at | timestamptz | default now() |

Indices:

- index(`app_user_id`)
- index(`status`)

### 8. `wallets`

Saldo resumido por usuario. Se alimenta desde `wallet_transactions`.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | unique, FK -> `app_users.id` |
| spendable_points_balance | integer | default 0 |
| earned_points_balance | integer | default 0 |
| lifetime_points_purchased | integer | default 0 |
| lifetime_points_spent | integer | default 0 |
| lifetime_points_earned | integer | default 0 |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

### 9. `wallet_transactions`

Libro principal de puntos y movimientos.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | FK -> `app_users.id` |
| wallet_type | wallet_type | `spendable` o `earned` |
| transaction_type | wallet_transaction_type | |
| direction | wallet_transaction_direction | |
| amount_points | integer | siempre positivo |
| balance_after | integer | saldo luego del movimiento |
| reference_table | varchar(80) | tabla origen |
| reference_id | uuid | id origen |
| metadata | jsonb | nullable |
| created_at | timestamptz | default now() |

Indices:

- index(`app_user_id`, `created_at desc`)
- index(`transaction_type`)
- index(`reference_table`, `reference_id`)

### 10. `point_purchase_orders`

Compra externa de puntos con Kushki o modo sandbox/manual.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| buyer_user_id | uuid | FK -> `app_users.id` |
| purchased_points | integer | |
| subtotal_usd | numeric(10,2) | |
| tax_iva_usd | numeric(10,2) | |
| total_usd | numeric(10,2) | |
| payment_provider | varchar(40) | `kushki` o `manual_sandbox` |
| provider_reference | varchar(120) | nullable |
| status | purchase_status | |
| receipt_url | text | nullable |
| metadata | jsonb | nullable |
| created_at | timestamptz | default now() |
| paid_at | timestamptz | nullable |

Indices:

- index(`buyer_user_id`)
- index(`status`)
- index(`provider_reference`)

### 11. `private_data_purchases`

Compra de acceso temporal a un dato privado.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| buyer_user_id | uuid | FK -> `app_users.id` |
| seller_user_id | uuid | FK -> `app_users.id` |
| offer_id | uuid | FK -> `user_private_data_offers.id` |
| data_type | private_data_type | snapshot del tipo comprado |
| points_paid | integer | |
| seller_points_share | integer | 35% |
| platform_points_share | integer | resto |
| starts_at | timestamptz | |
| expires_at | timestamptz | |
| status | purchase_status | |
| created_at | timestamptz | default now() |

Indices:

- index(`buyer_user_id`, `expires_at`)
- index(`seller_user_id`, `created_at desc`)
- index(`offer_id`)

Regla:

- el usuario no recompra el mismo dato mientras haya un registro `paid` no expirado para esa combinacion `buyer_user_id + seller_user_id + data_type`

### 12. `chat_threads`

Conversaciones 1 a 1 habilitadas por pago.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| initiator_user_id | uuid | FK -> `app_users.id` |
| recipient_user_id | uuid | FK -> `app_users.id` |
| opened_purchase_id | uuid | nullable, FK logica a compra de apertura |
| status | chat_status | |
| last_message_at | timestamptz | nullable |
| initiator_last_message_at | timestamptz | nullable |
| recipient_last_message_at | timestamptz | nullable |
| expires_at | timestamptz | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Indices y restricciones:

- index(`initiator_user_id`)
- index(`recipient_user_id`)
- index(`status`)

Regla:

- `expires_at` se recalcula con la ultima interaccion valida de ambas partes

### 13. `chat_messages`

Mensajes del chat.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| chat_thread_id | uuid | FK -> `chat_threads.id` |
| sender_user_id | uuid | FK -> `app_users.id` |
| message_type | chat_message_type | |
| text_body | text | nullable |
| media_id | uuid | nullable, FK -> `user_media.id` |
| points_cost | integer | default 0 |
| is_deleted_for_sender | boolean | default false |
| created_at | timestamptz | default now() |

Indices:

- index(`chat_thread_id`, `created_at`)
- index(`sender_user_id`, `created_at desc`)

### 14. `reports`

Reportes entre usuarios con evidencia obligatoria.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| reporter_user_id | uuid | FK -> `app_users.id` |
| reported_user_id | uuid | FK -> `app_users.id` |
| reason_type | report_reason_type | |
| free_text | text | nullable |
| status | report_status | default `open` |
| reviewed_by_admin_id | uuid | nullable, FK -> `app_users.id` |
| resolution_notes | text | nullable |
| created_at | timestamptz | default now() |
| reviewed_at | timestamptz | nullable |

Indices:

- index(`reporter_user_id`, `created_at desc`)
- index(`reported_user_id`, `created_at desc`)
- index(`status`)

### 15. `report_evidence`

Capturas adjuntas al reporte.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| report_id | uuid | FK -> `reports.id` |
| media_id | uuid | FK -> `user_media.id` |
| created_at | timestamptz | default now() |

Restriccion recomendada:

- al menos una evidencia por reporte, validada desde backend

### 16. `sanctions`

Historial de sanciones aplicadas por moderacion.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| target_user_id | uuid | FK -> `app_users.id` |
| sanction_type | sanction_type | |
| reason_type | report_reason_type | nullable |
| reason_details | text | nullable |
| starts_at | timestamptz | |
| ends_at | timestamptz | nullable |
| is_permanent | boolean | default false |
| can_pay_unban | boolean | default false |
| unban_cost_points | integer | nullable |
| applied_by_admin_id | uuid | FK -> `app_users.id` |
| related_report_id | uuid | nullable, FK -> `reports.id` |
| created_at | timestamptz | default now() |

Indices:

- index(`target_user_id`, `created_at desc`)
- index(`is_permanent`)

### 17. `withdrawal_requests`

Solicitud de retiro de puntos ganados a cuenta bancaria.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| app_user_id | uuid | FK -> `app_users.id` |
| requested_points | integer | recomendado: 100 por bloque |
| bank_name | varchar(120) | snapshot |
| bank_account_type | varchar(50) | snapshot |
| bank_account_number | varchar(60) | snapshot |
| bank_account_holder_name | varchar(200) | snapshot |
| bank_account_holder_national_id | varchar(20) | snapshot |
| status | withdrawal_status | |
| requested_at | timestamptz | default now() |
| processed_at | timestamptz | nullable |
| notes | text | nullable |

Indices:

- index(`app_user_id`, `requested_at desc`)
- index(`status`)

Nota:

- aunque operativamente el retiro parezca simple, el modelo debe dejarlo como solicitud trazable

### 18. `admin_audit_logs`

Bitacora de acciones sensibles del panel administrativo.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| admin_user_id | uuid | FK -> `app_users.id` |
| action_type | varchar(80) | ejemplo: `approve_verification`, `ban_user` |
| target_table | varchar(80) | |
| target_id | uuid | |
| details | jsonb | nullable |
| created_at | timestamptz | default now() |

Indices:

- index(`admin_user_id`, `created_at desc`)
- index(`target_table`, `target_id`)

### 19. `app_settings`

Configuracion global parametrizable por superadmin.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| setting_key | varchar(80) | unique |
| setting_value | jsonb | |
| description | text | nullable |
| updated_by_admin_id | uuid | nullable, FK -> `app_users.id` |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

Claves iniciales sugeridas:

- `point_price_usd`
- `seller_revenue_share_percent`
- `daily_report_limit`
- `chat_open_price_points`
- `chat_image_price_points`
- `paid_unban_price_points`
- `profile_extra_photos_limit`
- `private_data_prices`
- `promotion_rules`

### 20. `provinces`

Catalogo de provincias de Ecuador.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| code | varchar(10) | unique |
| name | varchar(120) | unique |
| created_at | timestamptz | default now() |

### 21. `cantons`

Catalogo de cantones de Ecuador.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid | PK |
| province_id | uuid | FK -> `provinces.id` |
| code | varchar(20) | unique |
| name | varchar(120) | |
| created_at | timestamptz | default now() |

Indices:

- index(`province_id`)
- unique(`province_id`, `name`)

## Relaciones Principales

- `app_users` 1:1 `user_profiles`
- `app_users` 1:1 `user_private_data`
- `app_users` 1:1 `wallets`
- `app_users` 1:N `user_media`
- `app_users` 1:N `user_verification_requests`
- `app_users` 1:N `wallet_transactions`
- `app_users` 1:N `point_purchase_orders`
- `app_users` 1:N `private_data_purchases` como comprador y vendedor
- `app_users` 1:N `reports` como reportante y reportado
- `app_users` 1:N `sanctions`
- `chat_threads` 1:N `chat_messages`
- `reports` 1:N `report_evidence`
- `provinces` 1:N `cantons`

## Restricciones De Negocio Importantes

1. no permitir `username` duplicado
2. no permitir `phone` duplicado
3. no permitir `national_id` duplicado
4. no permitir acceso al sistema si `account_status != approved`
5. no permitir reporte sin evidencia
6. no permitir recompra de mismo dato mientras la compra anterior siga activa
7. no permitir retiro si `earned_points_balance < 100`
8. no permitir mas de 3 fotos extra aprobadas por perfil en MVP
9. no permitir nuevo registro con cédula, teléfono o correo de una cuenta con baneo permanente

## Orden Recomendado De Migraciones

1. enums
2. catalogos: `provinces`, `cantons`
3. `app_users`
4. `user_profiles`
5. `user_profile_preferences`
6. `user_private_data`
7. `user_media`
8. `user_verification_requests`
9. `wallets`
10. `wallet_transactions`
11. `point_purchase_orders`
12. `user_private_data_offers`
13. `private_data_purchases`
14. `chat_threads`
15. `chat_messages`
16. `reports`
17. `report_evidence`
18. `sanctions`
19. `withdrawal_requests`
20. `admin_audit_logs`
21. `app_settings`

## Siguiente Paso

Convertir este documento en migraciones SQL para Supabase, empezando por:

1. enums
2. catalogos
3. `app_users`
4. `user_profiles`
5. `wallets`
6. `user_private_data`
7. `user_private_data_offers`
