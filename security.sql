-- =====================================================================
-- Agriculture Information System  -  security.sql
-- Run AFTER schema.sql and reports.sql.
--
-- Roles (table app_role, stored in profile.role_id):
--   1 = Administrator  read, create, update, DELETE everything,
--                      manage lookup tables and user roles, read audit log
--   2 = Staff          read, create, update (no delete)
--   3 = Viewer         read only (dashboard, lists, reports)
--
-- How it works
--   * Users log in with Supabase Auth. Passwords are hashed (bcrypt) by
--     Supabase in auth.users; this project never stores a password.
--   * Every request from the browser carries the user's JWT, so auth.uid()
--     tells PostgreSQL who is asking. The policies below use it.
--   * The browser only has the PUBLIC anon key. Without a login, the anon
--     role gets no rows at all. No secrets are written in this file.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Helper: role of the logged-in user (NULL if not logged in / no profile).
-- SECURITY DEFINER so it can read profile without triggering profile's own
-- RLS policies (that would loop forever).
-- ---------------------------------------------------------------------
create function current_role_id() returns smallint
language sql stable security definer set search_path = public as $$
  select role_id from profile where user_id = auth.uid();
$$;


-- ---------------------------------------------------------------------
-- 1. Turn on Row Level Security for EVERY table
-- ---------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'app_role', 'crop_category', 'season', 'soil_type', 'irrigation_type',
    'planting_status', 'quality_grade', 'harvest_remark', 'buyer_type',
    'input_type', 'unit_of_measure',
    'profile', 'audit_log',
    'farmer', 'farm', 'crop', 'planting', 'harvest',
    'buyer', 'sale', 'input_item', 'input_usage'
  ] loop
    -- (The table owner, used by the SQL Editor and by SECURITY DEFINER
    --  triggers, is not subject to RLS. API users always are.)
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;


-- ---------------------------------------------------------------------
-- 2. Lookup tables: every role can read; only Administrator can change
-- ---------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'app_role', 'crop_category', 'season', 'soil_type', 'irrigation_type',
    'planting_status', 'quality_grade', 'harvest_remark', 'buyer_type',
    'input_type', 'unit_of_measure'
  ] loop
    execute format($f$
      create policy "%1$s: all roles read" on %1$I
        for select to authenticated
        using (current_role_id() is not null)$f$, t);
    execute format($f$
      create policy "%1$s: admin insert" on %1$I
        for insert to authenticated
        with check (current_role_id() = 1)$f$, t);
    execute format($f$
      create policy "%1$s: admin update" on %1$I
        for update to authenticated
        using (current_role_id() = 1) with check (current_role_id() = 1)$f$, t);
    execute format($f$
      create policy "%1$s: admin delete" on %1$I
        for delete to authenticated
        using (current_role_id() = 1)$f$, t);
  end loop;
end $$;


-- ---------------------------------------------------------------------
-- 3. Data tables
--      SELECT  Administrator, Staff, Viewer
--      INSERT  Administrator, Staff
--      UPDATE  Administrator, Staff
--      DELETE  Administrator only
-- ---------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'farmer', 'farm', 'crop', 'planting', 'harvest',
    'buyer', 'sale', 'input_item', 'input_usage'
  ] loop
    execute format($f$
      create policy "%1$s: all roles read" on %1$I
        for select to authenticated
        using (current_role_id() in (1, 2, 3))$f$, t);
    execute format($f$
      create policy "%1$s: admin and staff insert" on %1$I
        for insert to authenticated
        with check (current_role_id() in (1, 2))$f$, t);
    execute format($f$
      create policy "%1$s: admin and staff update" on %1$I
        for update to authenticated
        using (current_role_id() in (1, 2)) with check (current_role_id() in (1, 2))$f$, t);
    execute format($f$
      create policy "%1$s: admin delete" on %1$I
        for delete to authenticated
        using (current_role_id() = 1)$f$, t);
  end loop;
end $$;


-- ---------------------------------------------------------------------
-- 4. Profiles
--    Everyone can read their OWN profile (to know their role).
--    Administrator can read all profiles and change names / roles.
--    Profiles are created by the trigger handle_new_user(), never by the app,
--    and removed when the auth user is deleted, so there is no insert/delete policy.
-- ---------------------------------------------------------------------
create policy "profile: read own, admin reads all" on profile
  for select to authenticated
  using (user_id = auth.uid() or current_role_id() = 1);

create policy "profile: admin update" on profile
  for update to authenticated
  using (current_role_id() = 1) with check (current_role_id() = 1);


-- ---------------------------------------------------------------------
-- 5. Audit log: Administrator can read. Nobody can write directly; rows
--    are added only by the SECURITY DEFINER trigger write_audit_log().
-- ---------------------------------------------------------------------
create policy "audit_log: admin read" on audit_log
  for select to authenticated
  using (current_role_id() = 1);


-- ---------------------------------------------------------------------
-- 6. Privileges (defence in depth on top of RLS)
--    Supabase grants a lot to "anon" by default. Remove it all, so a
--    visitor who is not logged in cannot even see that the tables exist.
-- ---------------------------------------------------------------------
revoke all on all tables    in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke execute on all functions in schema public from public, anon;

-- Logged-in users: normal table access (RLS above decides which rows / actions).
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
revoke insert, update, delete on audit_log from authenticated;   -- read only, via RLS
revoke insert, delete on profile from authenticated;             -- managed by triggers

-- Functions logged-in users may call (reports, dashboard, role helper).
grant execute on function
  current_role_id(),
  dashboard_totals(),
  rpt_farmers_farms(date, date),
  rpt_crops_per_farm(date, date),
  rpt_planting_status_summary(date, date),
  rpt_planting_by_status(date, date, smallint),
  rpt_harvest_records(date, date, smallint),
  rpt_harvest_per_crop(date, date),
  rpt_harvest_per_season(date, date),
  rpt_farmer_production(date, date),
  rpt_sales_per_period(date, date, text),
  rpt_input_usage_per_farm(date, date),
  rpt_production_by_location(date, date)
to authenticated;

-- Trigger functions are never called directly from the API.
revoke execute on function
  set_audit_fields(), write_audit_log(), check_planting_rules(), check_farm_rules(),
  check_harvest_rules(), check_sale_rules(), check_input_usage_rules(),
  handle_new_user(), check_profile_rules()
from authenticated;

-- Future objects created in public should not be open to anon either.
alter default privileges in schema public revoke all on tables    from anon;
alter default privileges in schema public revoke all on sequences from anon;
alter default privileges in schema public revoke execute on functions from public, anon;


-- ---------------------------------------------------------------------
-- 7. ONE-TIME SETUP: make your first Administrator
--    (Create the user first in Supabase > Authentication > Users.)
--    The SQL Editor runs as the database owner, so this is allowed.
--
--   update profile set role_id = 1 where email = 'admin@example.com';
--   update profile set role_id = 2 where email = 'staff@example.com';
--   -- everyone else stays a Viewer (role 3) until an Administrator changes it
-- ---------------------------------------------------------------------
