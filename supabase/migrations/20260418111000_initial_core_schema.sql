create extension if not exists pgcrypto;
create extension if not exists citext;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('member', 'support', 'moderator', 'superadmin');
  end if;

  if not exists (select 1 from pg_type where typname = 'account_status') then
    create type public.account_status as enum (
      'pending_review',
      'approved',
      'rejected',
      'suspended',
      'banned_permanent'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'verification_status') then
    create type public.verification_status as enum ('pending', 'approved', 'rejected');
  end if;

  if not exists (select 1 from pg_type where typname = 'media_type') then
    create type public.media_type as enum (
      'profile_photo',
      'gallery_photo',
      'national_id_photo',
      'report_evidence',
      'chat_image'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'media_review_status') then
    create type public.media_review_status as enum ('pending', 'approved', 'rejected');
  end if;

  if not exists (select 1 from pg_type where typname = 'private_data_type') then
    create type public.private_data_type as enum ('real_name', 'phone', 'instagram', 'birth_date');
  end if;

  if not exists (select 1 from pg_type where typname = 'wallet_type') then
    create type public.wallet_type as enum ('spendable', 'earned');
  end if;

  if not exists (select 1 from pg_type where typname = 'wallet_transaction_type') then
    create type public.wallet_transaction_type as enum (
      'points_purchase',
      'private_data_unlock_purchase',
      'private_data_unlock_income',
      'chat_open_purchase',
      'chat_open_income',
      'chat_image_purchase',
      'chat_image_income',
      'promotion_bonus',
      'event_create_purchase',
      'event_join_purchase',
      'event_income',
      'withdrawal_request',
      'withdrawal_completed',
      'withdrawal_rejected',
      'paid_unban_purchase',
      'admin_adjustment',
      'refund'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'wallet_transaction_direction') then
    create type public.wallet_transaction_direction as enum ('credit', 'debit');
  end if;

  if not exists (select 1 from pg_type where typname = 'withdrawal_status') then
    create type public.withdrawal_status as enum ('requested', 'processing', 'completed', 'rejected');
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.provinces (
  id uuid primary key default gen_random_uuid(),
  code varchar(10) not null unique,
  name varchar(120) not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.cantons (
  id uuid primary key default gen_random_uuid(),
  province_id uuid not null references public.provinces(id) on delete restrict,
  code varchar(20) not null unique,
  name varchar(120) not null,
  created_at timestamptz not null default now(),
  constraint cantons_province_name_key unique (province_id, name)
);

create index if not exists cantons_province_id_idx on public.cantons (province_id);

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete cascade,
  role public.user_role not null default 'member',
  account_status public.account_status not null default 'pending_review',
  phone varchar(20) not null unique,
  email citext,
  national_id varchar(20) not null unique,
  is_phone_verified boolean not null default false,
  is_email_verified boolean not null default false,
  last_login_at timestamptz,
  approved_at timestamptz,
  rejected_at timestamptz,
  rejected_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint app_users_phone_ec_format_chk check (phone ~ '^\+?593[0-9]{9}$|^09[0-9]{8}$'),
  constraint app_users_national_id_format_chk check (national_id ~ '^[0-9]{10}$')
);

create index if not exists app_users_account_status_idx on public.app_users (account_status);
create index if not exists app_users_role_idx on public.app_users (role);
create unique index if not exists app_users_email_unique_idx on public.app_users (email) where email is not null;

create table if not exists public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null unique references public.app_users(id) on delete cascade,
  username citext not null unique,
  birth_date date not null,
  bio varchar(500),
  province_id uuid not null references public.provinces(id) on delete restrict,
  canton_id uuid not null references public.cantons(id) on delete restrict,
  exact_lat numeric(9,6),
  exact_lng numeric(9,6),
  is_hidden boolean not null default false,
  profile_photo_media_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_profiles_username_len_chk check (char_length(username::text) between 3 and 30),
  constraint user_profiles_bio_len_chk check (bio is null or char_length(bio) <= 500),
  constraint user_profiles_lat_chk check (exact_lat is null or exact_lat between -90 and 90),
  constraint user_profiles_lng_chk check (exact_lng is null or exact_lng between -180 and 180)
);

create index if not exists user_profiles_province_id_idx on public.user_profiles (province_id);
create index if not exists user_profiles_canton_id_idx on public.user_profiles (canton_id);
create index if not exists user_profiles_is_hidden_idx on public.user_profiles (is_hidden);

create table if not exists public.user_profile_preferences (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null unique references public.app_users(id) on delete cascade,
  interested_in_genders jsonb not null default '[]'::jsonb,
  relationship_intentions jsonb not null default '[]'::jsonb,
  wants_children boolean,
  min_preferred_age integer,
  max_preferred_age integer,
  preferred_province_ids jsonb,
  preferred_canton_ids jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_profile_preferences_min_age_chk check (min_preferred_age is null or min_preferred_age >= 18),
  constraint user_profile_preferences_max_age_chk check (max_preferred_age is null or max_preferred_age >= 18),
  constraint user_profile_preferences_age_range_chk check (
    min_preferred_age is null
    or max_preferred_age is null
    or min_preferred_age <= max_preferred_age
  )
);

create table if not exists public.user_private_data (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null unique references public.app_users(id) on delete cascade,
  real_first_name varchar(100) not null,
  real_middle_name varchar(100),
  real_last_name_father varchar(100) not null,
  real_last_name_mother varchar(100) not null,
  real_phone varchar(20) not null,
  instagram_handle varchar(100),
  birth_date_exact date not null,
  bank_name varchar(120),
  bank_account_type varchar(50),
  bank_account_number varchar(60),
  bank_account_holder_name varchar(200),
  bank_account_holder_national_id varchar(20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_private_data_real_phone_ec_format_chk check (real_phone ~ '^\+?593[0-9]{9}$|^09[0-9]{8}$'),
  constraint user_private_data_holder_national_id_chk check (
    bank_account_holder_national_id is null
    or bank_account_holder_national_id ~ '^[0-9]{10}$'
  )
);

create table if not exists public.user_private_data_offers (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null references public.app_users(id) on delete cascade,
  data_type public.private_data_type not null,
  is_enabled boolean not null default false,
  price_points_snapshot integer not null,
  duration_hours integer not null default 24,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_private_data_offers_unique_offer unique (app_user_id, data_type),
  constraint user_private_data_offers_price_chk check (price_points_snapshot >= 0),
  constraint user_private_data_offers_duration_chk check (duration_hours > 0)
);

create index if not exists user_private_data_offers_enabled_idx
  on public.user_private_data_offers (is_enabled);

create table if not exists public.user_media (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null references public.app_users(id) on delete cascade,
  media_type public.media_type not null,
  bucket_name varchar(100) not null,
  storage_path text not null,
  mime_type varchar(120) not null,
  file_size_bytes bigint,
  review_status public.media_review_status not null default 'pending',
  reviewed_by_admin_id uuid references public.app_users(id) on delete set null,
  reviewed_at timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),
  constraint user_media_size_chk check (file_size_bytes is null or file_size_bytes >= 0)
);

create index if not exists user_media_app_user_type_idx on public.user_media (app_user_id, media_type);
create index if not exists user_media_review_status_idx on public.user_media (review_status);

alter table public.user_profiles
  add constraint user_profiles_profile_photo_media_id_fkey
  foreign key (profile_photo_media_id)
  references public.user_media(id)
  on delete set null;

create table if not exists public.user_verification_requests (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null references public.app_users(id) on delete cascade,
  national_id_photo_media_id uuid not null references public.user_media(id) on delete restrict,
  profile_photo_media_id uuid not null references public.user_media(id) on delete restrict,
  status public.verification_status not null default 'pending',
  review_notes text,
  reviewed_by_admin_id uuid references public.app_users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists user_verification_requests_app_user_idx
  on public.user_verification_requests (app_user_id);
create index if not exists user_verification_requests_status_idx
  on public.user_verification_requests (status);

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null unique references public.app_users(id) on delete cascade,
  spendable_points_balance integer not null default 0,
  earned_points_balance integer not null default 0,
  lifetime_points_purchased integer not null default 0,
  lifetime_points_spent integer not null default 0,
  lifetime_points_earned integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint wallets_spendable_nonnegative_chk check (spendable_points_balance >= 0),
  constraint wallets_earned_nonnegative_chk check (earned_points_balance >= 0),
  constraint wallets_lifetime_purchased_nonnegative_chk check (lifetime_points_purchased >= 0),
  constraint wallets_lifetime_spent_nonnegative_chk check (lifetime_points_spent >= 0),
  constraint wallets_lifetime_earned_nonnegative_chk check (lifetime_points_earned >= 0)
);

create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  app_user_id uuid not null references public.app_users(id) on delete cascade,
  wallet_type public.wallet_type not null,
  transaction_type public.wallet_transaction_type not null,
  direction public.wallet_transaction_direction not null,
  amount_points integer not null,
  balance_after integer not null,
  reference_table varchar(80),
  reference_id uuid,
  metadata jsonb,
  created_at timestamptz not null default now(),
  constraint wallet_transactions_amount_positive_chk check (amount_points > 0),
  constraint wallet_transactions_balance_nonnegative_chk check (balance_after >= 0)
);

create index if not exists wallet_transactions_app_user_created_at_idx
  on public.wallet_transactions (app_user_id, created_at desc);
create index if not exists wallet_transactions_transaction_type_idx
  on public.wallet_transactions (transaction_type);
create index if not exists wallet_transactions_reference_idx
  on public.wallet_transactions (reference_table, reference_id);

create table if not exists public.app_settings (
  id uuid primary key default gen_random_uuid(),
  setting_key varchar(80) not null unique,
  setting_value jsonb not null,
  description text,
  updated_by_admin_id uuid references public.app_users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace trigger trg_app_users_set_updated_at
before update on public.app_users
for each row execute function public.set_updated_at();

create or replace trigger trg_user_profiles_set_updated_at
before update on public.user_profiles
for each row execute function public.set_updated_at();

create or replace trigger trg_user_profile_preferences_set_updated_at
before update on public.user_profile_preferences
for each row execute function public.set_updated_at();

create or replace trigger trg_user_private_data_set_updated_at
before update on public.user_private_data
for each row execute function public.set_updated_at();

create or replace trigger trg_user_private_data_offers_set_updated_at
before update on public.user_private_data_offers
for each row execute function public.set_updated_at();

create or replace trigger trg_wallets_set_updated_at
before update on public.wallets
for each row execute function public.set_updated_at();

create or replace trigger trg_app_settings_set_updated_at
before update on public.app_settings
for each row execute function public.set_updated_at();
