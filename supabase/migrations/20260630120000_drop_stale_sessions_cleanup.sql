-- display_sessions was dropped in 20260624150500_drop_display_sessions.sql
-- but the cron job and cleanup function that referenced it were not removed,
-- causing a "relation does not exist" error every 5 minutes.
SELECT cron.unschedule('cleanup-stale-sessions');
DROP FUNCTION IF EXISTS public.cleanup_stale_sessions();
