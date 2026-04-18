# MVP Overview

## Objetivo

Construir la primera version web de Pega2EC para Ecuador, con registro validado manualmente, perfiles monetizables, puntos, desbloqueo temporal de datos y chat 1 a 1 pagado.

## Alcance MVP

### Usuarios

- registro por telefono con correo opcional
- validacion manual de identidad con cedula y foto de perfil
- acceso solo despues de aprobacion admin
- alias unico editable
- perfil visible solo para usuarios autenticados
- descripcion libre de maximo 500 caracteres
- filtros por provincia, canton, edad, intereses y preferencias

### Monetizacion

- compra de `Pega2Points`
- precios parametrizables por superadmin
- promociones temporales parametrizables
- desbloqueo por 24 horas de:
  - nombre real
  - telefono
  - instagram
  - fecha de nacimiento
- cada usuario decide que datos pone a la venta
- reparto de ganancias: 35% al propietario del dato o interaccion
- billetera separada:
  - gasto
  - ganancias

### Chat

- apertura de chat 1 a 1 pagada
- mensajes de texto ilimitados una vez abierto
- envio de imagen con costo por imagen
- cierre del chat si pasan 3 dias sin interaccion de ambas partes
- historial persistente para auditoria admin

### Moderacion

- reportes con evidencia obligatoria
- moderadores y superadmins pueden sancionar
- auditoria completa de acciones administrativas
- baneos temporales, permanentes y desbaneo pagado segun reglas parametrizadas

### Panel Admin

- validacion o rechazo de usuarios
- configuracion de precios y promociones
- gestion de perfiles, fotos, chats y reportes
- dashboard financiero inicial
- auditoria de accesos, compras, retiros y sanciones

## Fase 2

- eventos pagados
- aprobacion admin de eventos
- codigos QR/alfanumericos unicos por asistente
- chat grupal por evento
- reembolsos automaticos por cancelacion

## Reglas sensibles

- solo mayores de 18 anos
- numero y cedula unicos por cuenta
- ubicacion exacta privada; solo provincia y canton son visibles
- admins pueden ver chats, cedulas, fotos y evidencia de reportes
- cuentas con rechazo reciben notificacion por email y SMS con motivo
- baneo permanente bloquea nuevo registro con misma cedula, telefono o correo
