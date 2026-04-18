do $$
begin
  if not exists (select 1 from pg_type where typname = 'chat_status') then
    create type public.chat_status as enum (
      'active',
      'expired',
      'closed_by_sanction'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'chat_message_type') then
    create type public.chat_message_type as enum (
      'text',
      'image',
      'system'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'report_reason_type') then
    create type public.report_reason_type as enum (
      'harassment',
      'threats',
      'impersonation',
      'non_consensual_content',
      'fraud',
      'insults',
      'event_misconduct',
      'other'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'report_status') then
    create type public.report_status as enum (
      'open',
      'in_review',
      'resolved',
      'dismissed'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'sanction_type') then
    create type public.sanction_type as enum (
      'warning',
      'temporary_ban',
      'permanent_ban',
      'paid_unban'
    );
  end if;
end
$$;

create table if not exists public.chat_threads (
  id uuid primary key default gen_random_uuid(),
  initiator_user_id uuid not null references public.app_users(id) on delete cascade,
  recipient_user_id uuid not null references public.app_users(id) on delete cascade,
  opened_purchase_id uuid,
  status public.chat_status not null default 'active',
  last_message_at timestamptz,
  initiator_last_message_at timestamptz,
  recipient_last_message_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chat_threads_users_diff_chk check (initiator_user_id <> recipient_user_id)
);

create index if not exists chat_threads_initiator_idx
  on public.chat_threads (initiator_user_id, created_at desc);
create index if not exists chat_threads_recipient_idx
  on public.chat_threads (recipient_user_id, created_at desc);
create index if not exists chat_threads_status_idx
  on public.chat_threads (status);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  chat_thread_id uuid not null references public.chat_threads(id) on delete cascade,
  sender_user_id uuid not null references public.app_users(id) on delete cascade,
  message_type public.chat_message_type not null,
  text_body text,
  media_id uuid references public.user_media(id) on delete set null,
  points_cost integer not null default 0,
  is_deleted_for_sender boolean not null default false,
  created_at timestamptz not null default now(),
  constraint chat_messages_points_cost_nonnegative_chk check (points_cost >= 0),
  constraint chat_messages_text_required_chk check (
    (message_type = 'text' and text_body is not null and char_length(trim(text_body)) > 0 and media_id is null)
    or (message_type = 'image' and media_id is not null)
    or (message_type = 'system')
  )
);

create index if not exists chat_messages_thread_created_idx
  on public.chat_messages (chat_thread_id, created_at);
create index if not exists chat_messages_sender_created_idx
  on public.chat_messages (sender_user_id, created_at desc);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid not null references public.app_users(id) on delete cascade,
  reported_user_id uuid not null references public.app_users(id) on delete cascade,
  reason_type public.report_reason_type not null,
  free_text text,
  status public.report_status not null default 'open',
  reviewed_by_admin_id uuid references public.app_users(id) on delete set null,
  resolution_notes text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  constraint reports_users_diff_chk check (reporter_user_id <> reported_user_id)
);

create index if not exists reports_reporter_created_idx
  on public.reports (reporter_user_id, created_at desc);
create index if not exists reports_reported_created_idx
  on public.reports (reported_user_id, created_at desc);
create index if not exists reports_status_idx
  on public.reports (status);

create table if not exists public.report_evidence (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  media_id uuid not null references public.user_media(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint report_evidence_unique_media_per_report unique (report_id, media_id)
);

create index if not exists report_evidence_report_idx
  on public.report_evidence (report_id);

create table if not exists public.sanctions (
  id uuid primary key default gen_random_uuid(),
  target_user_id uuid not null references public.app_users(id) on delete cascade,
  sanction_type public.sanction_type not null,
  reason_type public.report_reason_type,
  reason_details text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  is_permanent boolean not null default false,
  can_pay_unban boolean not null default false,
  unban_cost_points integer,
  applied_by_admin_id uuid not null references public.app_users(id) on delete cascade,
  related_report_id uuid references public.reports(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint sanctions_unban_cost_nonnegative_chk check (unban_cost_points is null or unban_cost_points >= 0),
  constraint sanctions_period_chk check (
    is_permanent = true
    or ends_at is null
    or ends_at > starts_at
  )
);

create index if not exists sanctions_target_created_idx
  on public.sanctions (target_user_id, created_at desc);
create index if not exists sanctions_permanent_idx
  on public.sanctions (is_permanent);
create index if not exists sanctions_related_report_idx
  on public.sanctions (related_report_id);

create or replace trigger trg_chat_threads_set_updated_at
before update on public.chat_threads
for each row execute function public.set_updated_at();
