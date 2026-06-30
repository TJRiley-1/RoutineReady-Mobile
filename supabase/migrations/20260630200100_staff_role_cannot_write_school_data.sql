-- Security fix: private.user_can_edit_school() granted write access to any
-- org member with role <> 'display', which includes role = 'staff'. But the
-- Flutter client tells staff users "Staff sessions don't save changes"
-- (display_settings_modal.dart) and gates all writes client-side only
-- (isSessionOnlyMode / _skipDbWrites in school_provider.dart). A staff-role
-- session calling the Supabase REST API directly could persist edits to
-- active_timeline, templates, display_settings, custom_themes,
-- weekly_schedules, and tasks despite that promise.
--
-- Narrow the write-eligible roles to teacher/school_admin (and keep the
-- owner_id legacy path + platform-staff bypass unchanged).

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
      AND om.role IN ('teacher', 'school_admin')
  );
$function$;
