-- These tables hold exactly one row per school. There was no constraint
-- enforcing that, so the app's select-then-insert save pattern could race and
-- create duplicate rows (after which .maybeSingle() on load would throw and
-- wedge all future saves). Add unique indexes on school_id so the app can use
-- atomic upsert(onConflict: 'school_id') instead. No duplicates currently exist.
CREATE UNIQUE INDEX IF NOT EXISTS active_timeline_school_id_key
  ON active_timeline (school_id);
CREATE UNIQUE INDEX IF NOT EXISTS display_settings_school_id_key
  ON display_settings (school_id);
CREATE UNIQUE INDEX IF NOT EXISTS weekly_schedules_school_id_key
  ON weekly_schedules (school_id);
