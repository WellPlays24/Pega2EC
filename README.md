# Pega2EC

Proyecto base para la primera version web de Pega2EC, construido con `Flutter Web`, `FastAPI`, `Supabase` y `Docker`.

## Estructura

```text
.
|- Backend/     API, reglas de negocio e integraciones
|- Frontend/    Aplicacion Flutter Web
|- docs/        Requisitos funcionales y decisiones de arquitectura
|- docker-compose.yml
```

## Stack

- Frontend: `Flutter Web`
- Backend: `FastAPI`
- Auth/DB/Storage: `Supabase`
- Pagos: `Kushki` (sandbox/manual al inicio)
- Infra local: `Docker Compose`

## Estado actual

Esta base inicial deja listo:

- frontend y backend en carpetas separadas
- API inicial con healthcheck y configuracion tipada
- frontend Flutter con landing modular
- archivos `Dockerfile`, `docker-compose.yml` y variables de entorno de ejemplo
- documentacion funcional inicial del MVP

## Inicio rapido

### Backend

```bash
cd Backend
python -m venv .venv
.venv\Scripts\activate
pip install -e .[dev]
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend

```bash
cd Frontend
flutter pub get
flutter run -d chrome
```

### Docker

```bash
docker compose up --build
```

## Siguientes pasos recomendados

1. modelar la base de datos del MVP en Supabase/Postgres
2. integrar autenticacion y storage de Supabase
3. definir proveedor de SMS
4. integrar pagos sandbox con Kushki o adaptador manual temporal
5. construir flujo de registro, validacion manual y panel admin

## Prompt De Continuidad

Usa este prompt en otra PC, despues de clonar el repositorio y abrirlo en la raiz del proyecto:

```markdown
Continúa este proyecto desde el estado actual del repositorio sin asumir nada fuera de lo que ya está implementado.

Contexto del proyecto:
- Nombre: `Pega2EC`
- Arquitectura:
  - `frontend/`: Flutter Web
  - `backend/`: FastAPI
  - `supabase/`: migraciones SQL
  - `docs/`: documentación funcional y técnica
- Stack:
  - Frontend: Flutter Web
  - Backend: Python + FastAPI
  - DB/Auth/Storage: Supabase
  - Pagos: Kushki
  - Infra local: Docker

Reglas de negocio ya definidas:
- Solo Ecuador
- Solo mayores de 18 años
- Validación manual con cédula y foto de perfil
- Sin aprobación admin no pueden iniciar sesión
- Alias único editable
- Teléfono y cédula únicos
- Ubicación exacta privada; públicamente solo provincia/cantón
- Los usuarios pueden vender ciertos datos personales:
  - nombre real
  - teléfono
  - instagram
  - fecha de nacimiento
- El acceso a esos datos dura 24 horas
- Moneda interna: `Pega2Points`
- 35% de las compras de datos/interacciones va al dueño del perfil
- Wallet separada:
  - saldo de gasto
  - saldo de ganancias
- Chat 1 a 1 pagado
- Imagen en chat cuesta 1 punto
- Si pasan 3 días sin interacción de ambas partes, el chat expira
- Reportes con evidencia obligatoria
- Moderación manual por admin/moderador
- Eventos quedan para fase posterior

Estado actual implementado en el repo:
1. Base del frontend creada en Flutter Web con landing inicial.
2. Base del backend creada en FastAPI.
3. Documentación creada:
   - `docs/mvp-overview.md`
   - `docs/architecture.md`
   - `docs/legal-consent-draft.md`
   - `docs/data-model-mvp.md`
4. Migraciones Supabase creadas:
   - `supabase/migrations/20260418111000_initial_core_schema.sql`
   - `supabase/migrations/20260418114000_monetization_and_audit.sql`
   - `supabase/migrations/20260418121000_chat_and_moderation.sql`
   - `supabase/migrations/20260418124000_seed_ecuador_locations.sql`
   - `supabase/migrations/20260418130000_seed_app_settings.sql`
   - `supabase/migrations/20260418133000_initial_rls_policies.sql`
5. Backend con integración inicial hacia Supabase REST ya implementada.
6. Backend con módulo inicial de registro y revisión admin ya implementado.
7. Endpoints ya creados:
   - `POST /api/v1/registrations`
   - `GET /api/v1/admin/verifications`
   - `POST /api/v1/admin/verifications/{verification_request_id}/review`
8. Tests backend actuales pasando.

Limitaciones actuales que debes respetar y tener presentes:
- Aún no hay subida binaria real a Supabase Storage desde backend.
- El endpoint de registro actualmente trabaja con `storage_path` y `mime_type`, no con archivos reales.
- Aún no hay login real implementado.
- Aún no hay UI conectada a backend para registro/admin.
- Aún no hay integración real de Kushki.
- Aún no hay panel admin funcional en frontend.

Tu forma de trabajar:
1. Primero inspecciona el repositorio actual para confirmar el estado real del código.
2. No asumas que todo está perfecto; valida estructura, rutas, dependencias y consistencia.
3. No rehagas arquitectura ya definida salvo que detectes un problema real.
4. Haz cambios mínimos y correctos.
5. Mantén frontend y backend separados.
6. Usa `apply_patch` para editar archivos.
7. No hagas commits ni pushes a menos que yo lo pida explícitamente.

Siguiente objetivo recomendado:
- Implementar la subida real de archivos a Supabase Storage en el backend y cerrar el flujo de registro end-to-end.

Orden sugerido:
1. Revisar backend actual y configuración de Supabase.
2. Implementar servicio de upload a Supabase Storage.
3. Adaptar `POST /api/v1/registrations` para aceptar archivos reales o un flujo compatible.
4. Agregar validaciones necesarias.
5. Probar y corregir.
6. Luego, si todo queda bien, continuar con el frontend de registro.

Empieza inspeccionando el repositorio y dime exactamente:
1. qué ya está implementado,
2. qué está incompleto,
3. cuál es el cambio mínimo correcto para cerrar el flujo de registro real.
```
