-- Performance fix: templates.school_id and tasks.template_id are filtered on
-- every single classroom load (school_provider.dart) and walked by the
-- private.user_owns_school / user_can_edit_school RLS subqueries on every
-- read and write, but neither column has an index (the original CREATE TABLE
-- statements for these tables predate the supabase/migrations/ directory, so
-- this could never be confirmed from migration history). Likely contributors
-- to the slow-query count observed alongside the realtime reconnect-storm
-- incident on 2026-06-30.
create index if not exists idx_templates_school_id on public.templates (school_id);
create index if not exists idx_tasks_template_id on public.tasks (template_id);
