# Arquitectura Inicial

## Decision tecnica

- `Flutter Web` para la interfaz publica y administrativa
- `FastAPI` para API y reglas de negocio
- `Supabase Auth` para autenticacion base
- `Supabase Postgres` para datos transaccionales
- `Supabase Storage` para fotos, cedulas y evidencias
- `Kushki` para pagos reales y modo sandbox/manual en desarrollo

## Carpetas

### `Backend/`

- `app/core`: configuracion y dependencias comunes
- `app/api`: routers HTTP
- `app/services`: logica de dominio e integraciones
- `app/schemas`: contratos de entrada y salida
- `app/models`: base para entidades persistentes

### `Frontend/`

- `lib/src/app`: bootstrap y shell de la app
- `lib/src/core`: config global y tema
- `lib/src/features`: modulos funcionales

## Criterios de escalabilidad

- configuracion centralizada y tipada
- separacion temprana entre wallet de gasto y wallet de ganancias
- backend preparado para permisos por rol
- modulos de integracion aislados para `Supabase`, `Kushki`, `SMS` y notificaciones
- frontend organizado por features para extender a app movil despues

## Integraciones previstas

- `Supabase Auth`: usuarios y JWT
- `Supabase Storage`: fotos de perfil, galerias, cedulas, capturas
- `Kushki`: compra de puntos y comprobantes
- `SMS Provider`: pendiente de seleccion
- `Email Provider`: configurable por adaptador
