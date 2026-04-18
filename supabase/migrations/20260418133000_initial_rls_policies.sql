create or replace function public.current_app_user_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select id
  from public.app_users
  where auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_user_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.app_users
  where auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_user_role() in ('moderator', 'superadmin', 'support'), false);
$$;

create or replace function public.is_moderation_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_user_role() in ('moderator', 'superadmin'), false);
$$;

create or replace function public.is_superadmin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_user_role() = 'superadmin', false);
$$;

create or replace function public.is_approved_authenticated_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.app_users
    where auth_user_id = auth.uid()
      and account_status = 'approved'
  );
$$;

alter table public.provinces enable row level security;
alter table public.cantons enable row level security;
alter table public.app_users enable row level security;
alter table public.user_profiles enable row level security;
alter table public.user_profile_preferences enable row level security;
alter table public.user_private_data enable row level security;
alter table public.user_private_data_offers enable row level security;
alter table public.user_media enable row level security;
alter table public.user_verification_requests enable row level security;
alter table public.wallets enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.point_purchase_orders enable row level security;
alter table public.private_data_purchases enable row level security;
alter table public.withdrawal_requests enable row level security;
alter table public.chat_threads enable row level security;
alter table public.chat_messages enable row level security;
alter table public.reports enable row level security;
alter table public.report_evidence enable row level security;
alter table public.sanctions enable row level security;
alter table public.admin_audit_logs enable row level security;
alter table public.app_settings enable row level security;

create policy provinces_select_public
on public.provinces
for select
to anon, authenticated
using (true);

create policy cantons_select_public
on public.cantons
for select
to anon, authenticated
using (true);

create policy app_users_select_self
on public.app_users
for select
to authenticated
using (id = public.current_app_user_id());

create policy app_users_update_self
on public.app_users
for update
to authenticated
using (id = public.current_app_user_id())
with check (id = public.current_app_user_id());

create policy app_users_admin_select_all
on public.app_users
for select
to authenticated
using (public.is_admin_user());

create policy user_profiles_select_visible_authenticated
on public.user_profiles
for select
to authenticated
using (
  (
    exists (
      select 1
      from public.app_users owner_user
      where owner_user.id = user_profiles.app_user_id
        and owner_user.account_status = 'approved'
    )
    and is_hidden = false
    and public.is_approved_authenticated_user()
  )
  or app_user_id = public.current_app_user_id()
  or public.is_admin_user()
);

create policy user_profiles_insert_self
on public.user_profiles
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_profiles_update_self
on public.user_profiles
for update
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user())
with check (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_profile_preferences_select_self
on public.user_profile_preferences
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_profile_preferences_insert_self
on public.user_profile_preferences
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_profile_preferences_update_self
on public.user_profile_preferences
for update
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user())
with check (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_private_data_select_self
on public.user_private_data
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_private_data_insert_self
on public.user_private_data
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_private_data_update_self
on public.user_private_data
for update
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user())
with check (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_private_data_offers_select_enabled
on public.user_private_data_offers
for select
to authenticated
using (
  (
    is_enabled = true
    and public.is_approved_authenticated_user()
    and exists (
      select 1
      from public.user_profiles profile
      join public.app_users owner_user on owner_user.id = profile.app_user_id
      where profile.app_user_id = user_private_data_offers.app_user_id
        and profile.is_hidden = false
        and owner_user.account_status = 'approved'
    )
  )
  or app_user_id = public.current_app_user_id()
  or public.is_admin_user()
);

create policy user_private_data_offers_insert_self
on public.user_private_data_offers
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_private_data_offers_update_self
on public.user_private_data_offers
for update
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user())
with check (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_media_select_self
on public.user_media
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_media_insert_self
on public.user_media
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_media_update_self_or_admin
on public.user_media
for update
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user())
with check (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_verification_requests_select_self
on public.user_verification_requests
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy user_verification_requests_insert_self
on public.user_verification_requests
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy user_verification_requests_update_admin
on public.user_verification_requests
for update
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

create policy wallets_select_self
on public.wallets
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy wallet_transactions_select_self
on public.wallet_transactions
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy point_purchase_orders_select_self
on public.point_purchase_orders
for select
to authenticated
using (buyer_user_id = public.current_app_user_id() or public.is_admin_user());

create policy private_data_purchases_select_participants
on public.private_data_purchases
for select
to authenticated
using (
  buyer_user_id = public.current_app_user_id()
  or seller_user_id = public.current_app_user_id()
  or public.is_admin_user()
);

create policy withdrawal_requests_select_self
on public.withdrawal_requests
for select
to authenticated
using (app_user_id = public.current_app_user_id() or public.is_admin_user());

create policy withdrawal_requests_insert_self
on public.withdrawal_requests
for insert
to authenticated
with check (app_user_id = public.current_app_user_id());

create policy withdrawal_requests_update_admin
on public.withdrawal_requests
for update
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

create policy chat_threads_select_participants
on public.chat_threads
for select
to authenticated
using (
  initiator_user_id = public.current_app_user_id()
  or recipient_user_id = public.current_app_user_id()
  or public.is_admin_user()
);

create policy chat_messages_select_participants
on public.chat_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.chat_threads thread
    where thread.id = chat_messages.chat_thread_id
      and (
        thread.initiator_user_id = public.current_app_user_id()
        or thread.recipient_user_id = public.current_app_user_id()
        or public.is_admin_user()
      )
  )
);

create policy reports_select_own_or_admin
on public.reports
for select
to authenticated
using (
  reporter_user_id = public.current_app_user_id()
  or reported_user_id = public.current_app_user_id()
  or public.is_moderation_admin_user()
);

create policy reports_insert_self
on public.reports
for insert
to authenticated
with check (reporter_user_id = public.current_app_user_id());

create policy reports_update_moderation_admin
on public.reports
for update
to authenticated
using (public.is_moderation_admin_user())
with check (public.is_moderation_admin_user());

create policy report_evidence_select_by_report_visibility
on public.report_evidence
for select
to authenticated
using (
  exists (
    select 1
    from public.reports report
    where report.id = report_evidence.report_id
      and (
        report.reporter_user_id = public.current_app_user_id()
        or report.reported_user_id = public.current_app_user_id()
        or public.is_moderation_admin_user()
      )
  )
);

create policy report_evidence_insert_reporter
on public.report_evidence
for insert
to authenticated
with check (
  exists (
    select 1
    from public.reports report
    where report.id = report_evidence.report_id
      and report.reporter_user_id = public.current_app_user_id()
  )
);

create policy sanctions_select_target_or_admin
on public.sanctions
for select
to authenticated
using (
  target_user_id = public.current_app_user_id()
  or public.is_moderation_admin_user()
);

create policy sanctions_insert_moderation_admin
on public.sanctions
for insert
to authenticated
with check (public.is_moderation_admin_user());

create policy sanctions_update_moderation_admin
on public.sanctions
for update
to authenticated
using (public.is_moderation_admin_user())
with check (public.is_moderation_admin_user());

create policy admin_audit_logs_select_admin
on public.admin_audit_logs
for select
to authenticated
using (public.is_admin_user());

create policy admin_audit_logs_insert_admin
on public.admin_audit_logs
for insert
to authenticated
with check (public.is_admin_user());

create policy app_settings_select_admin
on public.app_settings
for select
to authenticated
using (public.is_admin_user());

create policy app_settings_update_superadmin
on public.app_settings
for update
to authenticated
using (public.is_superadmin_user())
with check (public.is_superadmin_user());
