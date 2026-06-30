-- Security fix: schools.is_active (the platform-staff subscription-pause flag
-- read by subscription_locked_screen.dart) was reachable through the
-- "Users update own school" policy, which only checks owner_id = auth.uid()
-- with no column restriction. Any classroom owner could call
-- supabase.from('schools').update({is_active: true}) directly via the REST
-- API / client SDK and re-enable a display RoutineReady staff had paused for
-- non-payment, completely bypassing the lock screen.
--
-- Two independent layers, matching the audit's defense-in-depth recommendation:
-- 1. Column-level grant: authenticated users keep UPDATE on their own school's
--    metadata, but lose the privilege to touch is_active/org_id/owner_id at all.
-- 2. Trigger guard: belt-and-braces in case a future broad GRANT slips back in.

revoke update on public.schools from authenticated;
grant update (school_name, class_name, teacher_name, device_name) on public.schools to authenticated;

create or replace function private.guard_school_is_active()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.is_active is distinct from old.is_active
     and auth.role() <> 'service_role'
     and not private.is_routineready_staff() then
    raise exception 'only platform staff may change schools.is_active';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_schools_guard_is_active on public.schools;
create trigger trg_schools_guard_is_active
  before update on public.schools
  for each row execute function private.guard_school_is_active();

revoke all on function private.guard_school_is_active() from public;
