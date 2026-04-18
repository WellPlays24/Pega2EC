do $$
begin
  if not exists (select 1 from pg_type where typname = 'purchase_status') then
    create type public.purchase_status as enum (
      'pending',
      'paid',
      'expired',
      'cancelled',
      'refunded'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'payment_provider_type') then
    create type public.payment_provider_type as enum (
      'kushki',
      'manual_sandbox',
      'manual_admin'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'audit_action_type') then
    create type public.audit_action_type as enum (
      'approve_verification',
      'reject_verification',
      'approve_media',
      'reject_media',
      'update_setting',
      'manual_points_adjustment',
      'approve_withdrawal',
      'reject_withdrawal',
      'view_chat',
      'review_report',
      'apply_sanction',
      'remove_sanction',
      'other'
    );
  end if;
end
$$;

create table if not exists public.point_purchase_orders (
  id uuid primary key default gen_random_uuid(),
  buyer_user_id uuid not null references public.app_users(id) on delete cascade,
  purchased_points integer not null,
  subtotal_usd numeric(10,2) not null,
  tax_iva_usd numeric(10,2) not null,
  total_usd numeric(10,2) not null,
  payment_provider public.payment_provider_type not null,
  provider_reference varchar(120),
  status public.purchase_status not null default 'pending',
  receipt_url text,
  metadata jsonb,
  created_at timestamptz not null default now(),
  paid_at timestamptz,
  constraint point_purchase_orders_points_positive_chk check (purchased_points > 0),
  constraint point_purchase_orders_subtotal_nonnegative_chk check (subtotal_usd >= 0),
  constraint point_purchase_orders_tax_nonnegative_chk check (tax_iva_usd >= 0),
  constraint point_purchase_orders_total_nonnegative_chk check (total_usd >= 0),
  constraint point_purchase_orders_total_amount_chk check (total_usd = subtotal_usd + tax_iva_usd)
);

create index if not exists point_purchase_orders_buyer_user_idx
  on public.point_purchase_orders (buyer_user_id, created_at desc);
create index if not exists point_purchase_orders_status_idx
  on public.point_purchase_orders (status);
create index if not exists point_purchase_orders_provider_reference_idx
  on public.point_purchase_orders (provider_reference);

create table if not exists public.private_data_purchases (
  id uuid primary key default gen_random_uuid(),
  buyer_user_id uuid not null references public.app_users(id) on delete cascade,
  seller_user_id uuid not null references public.app_users(id) on delete cascade,
  offer_id uuid not null references public.user_private_data_offers(id) on delete restrict,
  data_type public.private_data_type not null,
  points_paid integer not null,
  seller_points_share integer not null,
  platform_points_share integer not null,
  starts_at timestamptz not null,
  expires_at timestamptz not null,
  status public.purchase_status not null default 'paid',
  created_at timestamptz not null default now(),
  constraint private_data_purchases_points_paid_positive_chk check (points_paid > 0),
  constraint private_data_purchases_seller_share_nonnegative_chk check (seller_points_share >= 0),
  constraint private_data_purchases_platform_share_nonnegative_chk check (platform_points_share >= 0),
  constraint private_data_purchases_points_split_chk check (
    points_paid = seller_points_share + platform_points_share
  ),
  constraint private_data_purchases_expiration_chk check (expires_at > starts_at),
  constraint private_data_purchases_buyer_seller_diff_chk check (buyer_user_id <> seller_user_id)
);

create index if not exists private_data_purchases_buyer_expires_idx
  on public.private_data_purchases (buyer_user_id, expires_at desc);
create index if not exists private_data_purchases_seller_created_idx
  on public.private_data_purchases (seller_user_id, created_at desc);
create index if not exists private_data_purchases_offer_idx
  on public.private_data_purchases (offer_id);
create index if not exists private_data_purchases_status_idx
  on public.private_data_purchases (status);

create table if not exists public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null references public.app_users(id) on delete cascade,
  requested_points integer not null,
  bank_name varchar(120) not null,
  bank_account_type varchar(50) not null,
  bank_account_number varchar(60) not null,
  bank_account_holder_name varchar(200) not null,
  bank_account_holder_national_id varchar(20) not null,
  status public.withdrawal_status not null default 'requested',
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint withdrawal_requests_points_block_chk check (requested_points > 0 and requested_points % 100 = 0),
  constraint withdrawal_requests_holder_national_id_chk check (
    bank_account_holder_national_id ~ '^[0-9]{10}$'
  )
);

create index if not exists withdrawal_requests_app_user_idx
  on public.withdrawal_requests (app_user_id, requested_at desc);
create index if not exists withdrawal_requests_status_idx
  on public.withdrawal_requests (status);

create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid not null references public.app_users(id) on delete cascade,
  action_type public.audit_action_type not null,
  target_table varchar(80) not null,
  target_id uuid,
  details jsonb,
  created_at timestamptz not null default now()
);

create index if not exists admin_audit_logs_admin_user_idx
  on public.admin_audit_logs (admin_user_id, created_at desc);
create index if not exists admin_audit_logs_target_idx
  on public.admin_audit_logs (target_table, target_id);
create index if not exists admin_audit_logs_action_type_idx
  on public.admin_audit_logs (action_type);

create or replace trigger trg_withdrawal_requests_set_updated_at
before update on public.withdrawal_requests
for each row execute function public.set_updated_at();
