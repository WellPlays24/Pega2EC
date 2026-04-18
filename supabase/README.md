# Supabase

Migraciones SQL y recursos de base de datos para `Pega2EC`.

## Orden inicial

1. `20260418111000_initial_core_schema.sql`
2. `20260418114000_monetization_and_audit.sql`
3. `20260418121000_chat_and_moderation.sql`
4. `20260418124000_seed_ecuador_locations.sql`
5. `20260418130000_seed_app_settings.sql`
6. `20260418133000_initial_rls_policies.sql`

## Alcance de la primera migracion

- extensiones base
- enums del MVP
- funcion de `updated_at`
- catalogos de provincia y canton
- usuarios, perfiles, preferencias y datos privados
- media, validacion manual, wallets y configuracion global

## Alcance de la segunda migracion

- compras de puntos
- compras de desbloqueo de datos privados
- solicitudes de retiro
- bitacora de auditoria admin

## Alcance de la tercera migracion

- conversaciones y mensajes 1 a 1
- reportes con evidencia
- sanciones administrativas

## Alcance de la cuarta migracion

- seed inicial de provincias de Ecuador
- seed inicial de cantones de Ecuador

## Alcance de la quinta migracion

- seed inicial de configuraciones del MVP
- precios base y reglas operativas parametrizables

## Alcance de la sexta migracion

- funciones helper para usuario actual y roles
- RLS inicial sobre tablas principales
- politicas base para lectura propia, administracion y catalogos publicos

## Pendiente para siguientes migraciones

- refinamientos de RLS segun flujos finales del backend
