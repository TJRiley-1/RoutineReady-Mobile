-- Allow any non-display org member (not just the school owner) to edit a
-- classroom's schedule data. Additive: new helper + new permissive write
-- policies. Existing owner/read policies are untouched.

-- Helper: true if the current user owns the school OR is a non-display member
-- of the school's org. Mirrors private.user_owns_school style/grants.
create or replace function private.user_can_edit_school(p_school_id uuid)
returns boolean
language sql
stable security definer
set search_path to 'public'
as $function$
  SELECT EXISTS (
    SELECT 1 FROM schools WHERE id = p_school_id AND owner_id = auth.uid()
  ) OR EXISTS (
    SELECT 1 FROM org_members om
    JOIN schools s ON s.org_id = om.org_id
    WHERE s.id = p_school_id
      AND om.user_id = auth.uid()
      AND om.role <> 'display'
  );
$function$;

revoke execute on function private.user_can_edit_school(uuid) from public;
grant execute on function private.user_can_edit_school(uuid) to authenticated;

-- active_timeline
create policy "Editors insert timeline" on public.active_timeline
  for insert with check (private.user_can_edit_school(school_id));
create policy "Editors update timeline" on public.active_timeline
  for update using (private.user_can_edit_school(school_id))
  with check (private.user_can_edit_school(school_id));
create policy "Editors delete timeline" on public.active_timeline
  for delete using (private.user_can_edit_school(school_id));

-- templates
create policy "Editors insert templates" on public.templates
  for insert with check (private.user_can_edit_school(school_id));
create policy "Editors update templates" on public.templates
  for update using (private.user_can_edit_school(school_id))
  with check (private.user_can_edit_school(school_id));
create policy "Editors delete templates" on public.templates
  for delete using (private.user_can_edit_school(school_id));

-- display_settings
create policy "Editors insert display settings" on public.display_settings
  for insert with check (private.user_can_edit_school(school_id));
create policy "Editors update display settings" on public.display_settings
  for update using (private.user_can_edit_school(school_id))
  with check (private.user_can_edit_school(school_id));
create policy "Editors delete display settings" on public.display_settings
  for delete using (private.user_can_edit_school(school_id));

-- custom_themes
create policy "Editors insert custom themes" on public.custom_themes
  for insert with check (private.user_can_edit_school(school_id));
create policy "Editors update custom themes" on public.custom_themes
  for update using (private.user_can_edit_school(school_id))
  with check (private.user_can_edit_school(school_id));
create policy "Editors delete custom themes" on public.custom_themes
  for delete using (private.user_can_edit_school(school_id));

-- weekly_schedules
create policy "Editors insert weekly schedules" on public.weekly_schedules
  for insert with check (private.user_can_edit_school(school_id));
create policy "Editors update weekly schedules" on public.weekly_schedules
  for update using (private.user_can_edit_school(school_id))
  with check (private.user_can_edit_school(school_id));
create policy "Editors delete weekly schedules" on public.weekly_schedules
  for delete using (private.user_can_edit_school(school_id));

-- tasks (keyed by template_id -> templates.school_id)
create policy "Editors insert tasks" on public.tasks
  for insert with check (
    template_id in (select id from templates where private.user_can_edit_school(school_id))
  );
create policy "Editors update tasks" on public.tasks
  for update using (
    template_id in (select id from templates where private.user_can_edit_school(school_id))
  ) with check (
    template_id in (select id from templates where private.user_can_edit_school(school_id))
  );
create policy "Editors delete tasks" on public.tasks
  for delete using (
    template_id in (select id from templates where private.user_can_edit_school(school_id))
  );
