-- RoutineReady staff super-admin: staff accounts (@routineready.co.uk/.app) can
-- read every org's classrooms and edit any classroom's schedule, without needing
-- per-org membership. Additive read policies + staff bypass in user_can_edit_school.

-- Is the current user a RoutineReady staff account (by verified email domain)?
create or replace function private.is_routineready_staff()
returns boolean
language sql
stable security definer
set search_path to 'public'
as $function$
  SELECT lower(coalesce(auth.jwt() ->> 'email', '')) LIKE '%@routineready.co.uk'
      OR lower(coalesce(auth.jwt() ->> 'email', '')) LIKE '%@routineready.app';
$function$;

revoke execute on function private.is_routineready_staff() from public;
grant execute on function private.is_routineready_staff() to authenticated;

-- Edit bypass: staff can edit any school's schedule data (extends the existing
-- owner / non-display-member rule).
create or replace function private.user_can_edit_school(p_school_id uuid)
returns boolean
language sql
stable security definer
set search_path to 'public'
as $function$
  SELECT private.is_routineready_staff()
  OR EXISTS (
    SELECT 1 FROM schools WHERE id = p_school_id AND owner_id = auth.uid()
  ) OR EXISTS (
    SELECT 1 FROM org_members om
    JOIN schools s ON s.org_id = om.org_id
    WHERE s.id = p_school_id
      AND om.user_id = auth.uid()
      AND om.role <> 'display'
  );
$function$;

-- Staff read bypass (additive SELECT policies) so the all-orgs picker + editor
-- can load any org's data.
create policy "Staff read all organizations" on public.organizations
  for select using (private.is_routineready_staff());
create policy "Staff read all schools" on public.schools
  for select using (private.is_routineready_staff());
create policy "Staff read all timeline" on public.active_timeline
  for select using (private.is_routineready_staff());
create policy "Staff read all templates" on public.templates
  for select using (private.is_routineready_staff());
create policy "Staff read all tasks" on public.tasks
  for select using (private.is_routineready_staff());
create policy "Staff read all display settings" on public.display_settings
  for select using (private.is_routineready_staff());
create policy "Staff read all custom themes" on public.custom_themes
  for select using (private.is_routineready_staff());
create policy "Staff read all weekly schedules" on public.weekly_schedules
  for select using (private.is_routineready_staff());
