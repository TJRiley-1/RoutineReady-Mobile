-- Per-classroom on/off switch for subscription control. RoutineReady staff
-- toggle this when a school's display subscription starts/lapses. Existing
-- classrooms default to active so nothing is interrupted.
ALTER TABLE schools
  ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
