insert into public.app_settings (setting_key, setting_value, description)
values
  (
    'point_price_usd',
    '1.00'::jsonb,
    'Precio base en USD por cada Pega2Point.'
  ),
  (
    'tax_iva_percent',
    '15'::jsonb,
    'Porcentaje de IVA aplicado a compras de puntos.'
  ),
  (
    'seller_revenue_share_percent',
    '35'::jsonb,
    'Porcentaje de puntos acreditados al usuario vendedor.'
  ),
  (
    'daily_report_limit',
    '10'::jsonb,
    'Cantidad maxima de reportes permitidos por usuario al dia.'
  ),
  (
    'withdrawal_block_points',
    '100'::jsonb,
    'Cantidad minima y multiplo requerido para solicitar retiros.'
  ),
  (
    'chat_inactivity_days',
    '3'::jsonb,
    'Dias maximos sin interaccion bilateral antes de expirar un chat.'
  ),
  (
    'chat_image_price_points',
    '1'::jsonb,
    'Costo en puntos por enviar una imagen en chat.'
  ),
  (
    'profile_extra_photos_limit',
    '3'::jsonb,
    'Cantidad maxima de fotos extra permitidas por perfil.'
  ),
  (
    'private_data_unlock_duration_hours',
    '24'::jsonb,
    'Duracion en horas del acceso a datos privados desbloqueados.'
  ),
  (
    'private_data_prices',
    '{
      "real_name": 5,
      "phone": 20,
      "instagram": 5,
      "birth_date": 5
    }'::jsonb,
    'Precios iniciales por tipo de dato privado desbloqueable.'
  ),
  (
    'chat_open_price_points',
    '10'::jsonb,
    'Costo inicial para abrir un chat 1 a 1.'
  ),
  (
    'paid_unban_price_points',
    '100'::jsonb,
    'Costo inicial del desbaneo pagado cuando la sancion lo permita.'
  ),
  (
    'promotion_rules',
    '{
      "enabled": false,
      "campaigns": []
    }'::jsonb,
    'Configuracion inicial de promociones temporales sobre puntos.'
  ),
  (
    'event_settings',
    '{
      "enabled": false,
      "default_creator_cost_points": 5,
      "default_attendance_revenue_share_percent": 35
    }'::jsonb,
    'Configuracion inicial reservada para la fase de eventos.'
  )
on conflict (setting_key) do update
set
  setting_value = excluded.setting_value,
  description = excluded.description,
  updated_at = now();
